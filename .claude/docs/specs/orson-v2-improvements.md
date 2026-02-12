# Spec: Orson v2 — Piano di migliorie incrementali

**Data:** 2026-02-12
**Origine:** `CINE/analisi-cine.md` — sezione "COSA CONVIENE FARE DAVVERO"

---

## Obiettivo

Evolvere Orson incrementalmente senza riscrittura. 10 interventi in 3 tier di priorita', dal piu' impattante (performance) al piu' qualitativo.

---

## Architettura attuale (riferimento)

Pipeline: `index.ts` → `capture.ts` (Playwright) → `encode.ts` (FFmpeg) → `audio-mixer.ts`

| Fase | File | Tempo per 1080p30 60s |
|------|------|-----------------------|
| Frame capture (PNG screenshot loop) | `capture.ts:49-72` | ~27s (1800 frame × 15ms) |
| FFmpeg encode (image2pipe PNG → H.264) | `encode.ts:20-63` | ~30-90s |
| Audio processing | `audio-mixer.ts` + `narration_generator.py` | ~10-15s |
| **Totale** | | **~70-130s** |

---

## TIER 1 — Ottimizzazioni performance

### 1.1 Raw frame piping (eliminare PNG)

**Problema:** Ogni frame viene catturato come PNG (`page.screenshot({ type: 'png' })`) — la compressione PNG e' inutile perche' FFmpeg la decomprime subito. Overhead: ~5ms/frame di encode + decode PNG.

**Soluzione:** Usare il CDP (Chrome DevTools Protocol) per catturare frame RGBA grezzi via `Page.captureScreenshot` con formato `raw`, e passarli a FFmpeg come `rawvideo`.

**File da modificare:**
- `capture.ts` — Sostituire `page.screenshot()` con CDP raw capture
- `encode.ts` — Cambiare input format da `image2pipe` (PNG) a `rawvideo` con `-f rawvideo -pix_fmt rgba -s WxH`

**Implementazione `capture.ts`:**
```typescript
// Invece di:
const buffer = await session.page.screenshot({ type: 'png' });

// Fare:
const cdp = await session.page.context().newCDPSession(session.page);
const { data } = await cdp.send('Page.captureScreenshot', {
  format: 'png',  // CDP non supporta raw direttamente
});
// ALTERNATIVA: usare page.screenshot({ type: 'jpeg', quality: 100 })
// che e' ~2x piu' veloce di PNG (niente compressione lossless)
```

**Nota importante:** CDP `Page.captureScreenshot` non supporta formato raw. Le alternative realistiche sono:
1. **JPEG quality 100** — ~2x piu' veloce del PNG, lossless per screenshot (no artefatti visibili). Input FFmpeg: `-f image2pipe -c:v mjpeg`
2. **BMP** — Non compresso, ma Playwright non lo supporta nativamente
3. **CDP raw via compositing** — Richiederebbe low-level access a Skia, troppo complesso

**Raccomandazione:** Usare JPEG 100 come primo step (facile, ~30% speedup su capture), poi valutare raw BMP se serve di piu'.

**Impatto stimato:** ~30% riduzione tempo capture → ~10-15% riduzione totale
**Effort:** Basso (1-2 ore)

---

### 1.2 Hardware encoding detection (NVENC / VA-API / VideoToolbox)

**Problema:** FFmpeg usa sempre `libx264` (CPU software encoding). Su macchine con GPU, hardware encoding e' 3-10x piu' veloce.

**Soluzione:** Probe FFmpeg all'avvio per hardware encoders disponibili, usarli automaticamente.

**File da modificare:**
- `presets.ts` — Aggiungere preset hardware (`h264_nvenc`, `h264_vaapi`, `h264_videotoolbox`)
- `encode.ts` — Aggiungere `detectHardwareEncoder()` che esegue `ffmpeg -encoders` e filtra
- `index.ts` — Passare encoder rilevato a `startEncoder`

**Implementazione `presets.ts`:**
```typescript
export interface HwAccelPreset {
  encoder: string;
  extraArgs: string[];
  quality: string;  // equivalente CRF per hw encoders
}

export const HW_ACCEL_PRESETS: Record<string, HwAccelPreset> = {
  nvenc: {
    encoder: 'h264_nvenc',
    extraArgs: ['-rc', 'constqp', '-qp', '18', '-b:v', '0'],
    quality: '18',
  },
  vaapi: {
    encoder: 'h264_vaapi',
    extraArgs: ['-vaapi_device', '/dev/dri/renderD128', '-qp', '18'],
    quality: '18',
  },
  videotoolbox: {
    encoder: 'h264_videotoolbox',
    extraArgs: ['-q:v', '65'],
    quality: '65',
  },
};
```

**Implementazione detection in `encode.ts`:**
```typescript
import { execSync } from 'child_process';

export function detectHardwareEncoder(): string | null {
  try {
    const encoders = execSync('ffmpeg -encoders 2>/dev/null', { encoding: 'utf-8' });
    if (encoders.includes('h264_nvenc')) return 'nvenc';
    if (encoders.includes('h264_vaapi')) return 'vaapi';
    if (encoders.includes('h264_videotoolbox')) return 'videotoolbox';
  } catch {}
  return null;
}
```

**Impatto stimato:** 3-10x speedup encoding → 40-60% riduzione totale (encoding e' il bottleneck dominante)
**Effort:** Basso-Medio (2-3 ore, bisogna testare su diverse GPU)

---

### 1.3 Rendering parallelo per scene

**Problema:** Le scene vengono renderizzate sequenzialmente in un singolo browser. Ogni scena e' indipendente.

**Soluzione:** Aprire N istanze Playwright (una per scena o pool di worker), rendere in parallelo, concatenare i segmenti con FFmpeg `concat`.

**File da modificare:**
- `capture.ts` — Aggiungere `captureScene()` che rende una singola scena (da timestamp A a B)
- `index.ts` → nuovo file `parallel-render.ts` — Orchestratore che suddivide il lavoro
- `encode.ts` — Aggiungere `concatSegments()` via FFmpeg concat demuxer

**Approccio:**
```
Scene 1 ─→ [Playwright #1] ─→ segment-01.mp4
Scene 2 ─→ [Playwright #2] ─→ segment-02.mp4  (in parallelo)
Scene 3 ─→ [Playwright #3] ─→ segment-03.mp4  (in parallelo)
         ↓
FFmpeg concat ─→ output.mp4
```

**Vincoli:**
- Le transizioni tra scene devono essere gestite (overlap frames)
- Numero worker = `min(numScene, os.cpus().length / 2, 4)` — oltre 4 browser la RAM diventa un problema
- Ogni worker ha la sua istanza Playwright completa (browser + page)
- L'HTML deve supportare rendering di singola scena (navigare al timestamp di inizio scena)

**Implementazione core `parallel-render.ts`:**
```typescript
import { cpus } from 'os';

interface SceneSegment {
  sceneIndex: number;
  startFrame: number;
  endFrame: number;
  outputPath: string;
}

export async function renderParallel(
  htmlPath: string,
  scenes: SceneSegment[],
  opts: CaptureOptions & EncodeOptions,
): Promise<string[]> {
  const maxWorkers = Math.min(scenes.length, Math.floor(cpus().length / 2), 4);
  const pool: Promise<string>[] = [];

  // Process scenes in batches
  for (let i = 0; i < scenes.length; i += maxWorkers) {
    const batch = scenes.slice(i, i + maxWorkers);
    const results = await Promise.all(
      batch.map(scene => renderSceneSegment(htmlPath, scene, opts))
    );
    pool.push(...results);
  }

  return pool;
}
```

**Impatto stimato:** Speedup quasi lineare per capture (2-4x con 2-4 core) → ~30-50% riduzione totale
**Effort:** Medio-Alto (4-6 ore). E' il cambiamento piu' complesso del Tier 1.

---

### 1.4 Preset "draft" per preview rapide

**Problema:** Per iterare velocemente serve un modo di vedere il risultato senza render a qualita' piena.

**Soluzione:** Aggiungere flag `--draft` che usa risoluzione dimezzata + H.264 ultrafast + framerate ridotto.

**File da modificare:**
- `presets.ts` — Aggiungere `DRAFT_PRESET`
- `index.ts` — Gestire flag `--draft`
- `capture.ts` — Nessuna modifica (la risoluzione viene passata da fuori)

**Implementazione in `presets.ts`:**
```typescript
export const DRAFT_OVERRIDES = {
  widthDivisor: 2,    // 1920→960, 1080→540
  heightDivisor: 2,
  fps: 15,            // meta' dei frame
  codec: {
    encoder: 'libx264',
    preset: 'ultrafast',
    crf: 28,           // qualita' piu' bassa ma accettabile
    pixFmt: 'yuv420p',
    extraArgs: [],
    container: 'mp4',
  },
};
```

**Impatto stimato:** ~4-8x speedup totale (meta' frame × meta' pixel × ultrafast encoding)
**Effort:** Basso (1 ora)

---

## TIER 2 — Feature nuove ad alto valore

### 2.1 Batch mode (rendering parametrico)

**Problema:** Generare varianti di un video (diversi testi, colori, formati) richiede esecuzioni manuali separate.

**Soluzione:** Accettare un file JSON/CSV di parametri + un template HTML, generare N video automaticamente.

**File da creare:**
- `batch.ts` — Parser CSV/JSON, sostituzione variabili, orchestrazione render multipli

**Formato input:**
```json
{
  "template": "promo-template.html",
  "variables": [
    { "headline": "50% Off Today", "cta": "Shop Now", "output": "promo-50.mp4" },
    { "headline": "Free Shipping", "cta": "Order Now", "output": "promo-ship.mp4" }
  ]
}
```

**Implementazione:**
1. Leggere template HTML
2. Per ogni riga di variabili: sostituire `{{variable}}` nel template → HTML temporaneo
3. Chiamare `renderHTML()` per ciascuno (potenzialmente parallelo con 1.3)
4. Report finale con risultati

**Comando:** `npx tsx src/index.ts batch <batch-config.json>`

**Impatto:** Abilita casi d'uso enterprise (campagne social, A/B testing video)
**Effort:** Medio (3-4 ore)

---

### 2.2 Asset embedding (immagini, screenshot, loghi)

**Problema:** I video Orson sono solo testo + CSS. Nessun supporto per immagini.

**Soluzione:** Supportare elementi `<img>` nell'HTML generato con embedding base64 o file locali.

**File da modificare:**
- `html-generator.ts` — Aggiungere supporto per blocchi immagine nei scene data
- `composition.ts` — Aggiungere layout con slot immagine (hero-image, logo-bar, screenshot)
- `autogen.ts` — Accettare campo `image` nei content JSON

**Approccio:**
- Le immagini vengono convertite in base64 data URI nell'HTML (self-contained)
- Nuovi layout: `image-left`, `image-right`, `image-bg`, `image-hero`
- Le animazioni esistenti si applicano anche agli `<img>` (fade-in, slide, zoom)

**Impatto:** Sblocca tipologie di video prima impossibili (product showcase, portfolio, demo highlight)
**Effort:** Medio (4-5 ore)

---

### 2.3 Video-in-video (PiP per demo UI)

**Problema:** Mostrare una registrazione demo dentro un video promozionale (picture-in-picture).

**Soluzione:** Supportare un layer `<video>` nell'HTML generato che viene sincronizzato frame-by-frame.

**File da modificare:**
- `html-generator.ts` — Aggiungere supporto per `<video>` element con sincronizzazione
- `capture.ts` — Sincronizzare anche il `<video>` element nel frame loop (via `video.currentTime`)

**Vincoli:**
- Il video PiP deve essere locale (non streaming)
- Playwright puo' controllare `<video>.currentTime` come fa con le CSS animations
- Il video PiP deve essere pre-renderizzato (non ricorsivo)

**Impatto:** Abilita video "meta" (promo che include demo del prodotto)
**Effort:** Medio-Alto (4-6 ore)

---

## TIER 3 — Qualita'

### 3.1 Tipografia avanzata

**Problema:** Nessun controllo su variable fonts, tracking (letter-spacing), leading (line-height) granulare.

**Soluzione:** Estendere il sistema di design tokens e l'HTML generator.

**File da modificare:**
- `html-generator.ts` — Supportare proprieta' CSS avanzate per testo
- `composition.ts` — Aggiungere calcolo auto di tracking/leading basato su dimensione font
- `ux-bridge.ts` — Leggere token tipografici aggiuntivi da Seurat

**Proprieta' da aggiungere:**
- `letter-spacing` (tracking) — auto-negativo per display font grandi
- `line-height` (leading) — basato su rapporto aureo o preset
- `font-variation-settings` — per variable fonts (weight, width, slant)
- `text-wrap: balance` — per bilanciare righe di headline

**Impatto:** Qualita' visiva significativamente superiore sui titoli
**Effort:** Basso-Medio (2-3 ore)

---

### 3.2 Transizioni scene migliori (morphing)

**Problema:** Le transizioni attuali sono cut o fade semplici. Nessun morphing tra layout.

**Soluzione:** Implementare transizioni CSS avanzate che interpolano posizione/dimensione di elementi tra scene consecutive.

**File da modificare:**
- `choreography.ts` — Aggiungere logica di matching elementi tra scene (per nome/tipo)
- `html-generator.ts` — Generare CSS `@keyframes` personalizzati per transizioni morph
- `actions.ts` — Aggiungere nuove transizioni: `morph-layout`, `shared-element`, `cross-dissolve`

**Approccio:**
- Identificare elementi condivisi tra scena N e N+1 (es. headline → headline)
- Generare `@keyframes` che anima `transform`, `opacity`, `clip-path` dall'uno all'altro
- Per elementi senza match: exit standard (scena N) + entrance standard (scena N+1)

**Impatto:** Qualita' percepita molto piu' alta, video meno "slideshow"
**Effort:** Alto (6-8 ore). Richiede calcolo posizioni a priori.

---

### 3.3 Sottotitoli integrati (SRT/VTT nel video non-demo)

**Problema:** I sottotitoli esistono solo in demo mode. I video promozionali non hanno subtitle track.

**Soluzione:** Generare file SRT/VTT dal testo delle scene, con timing sincronizzato.

**File da creare:**
- `subtitles.ts` — Generatore SRT/VTT basato su scene timing

**Implementazione:**
```typescript
export function generateSRT(scenes: SceneTiming[]): string {
  let srt = '';
  let index = 1;
  for (const scene of scenes) {
    srt += `${index}\n`;
    srt += `${formatTime(scene.startMs)} --> ${formatTime(scene.endMs)}\n`;
    srt += `${scene.text}\n\n`;
    index++;
  }
  return srt;
}
```

**Output:** File `.srt` accanto al video, oppure embedded nel MP4 come soft subtitle track (`-c:s mov_text`).

**Impatto:** Accessibilita' migliorata, compatibilita' social media (sottotitoli auto)
**Effort:** Basso (1-2 ore)

---

## Roadmap di implementazione

| # | Intervento | Tier | Effort | Impatto performance | Dipendenze |
|---|-----------|------|--------|-------------------|------------|
| 1 | Draft preset (`--draft`) | T1 | 1h | 4-8x per preview | Nessuna |
| 2 | JPEG 100 capture | T1 | 1-2h | ~10-15% totale | Nessuna |
| 3 | HW encoding detection | T1 | 2-3h | 40-60% totale | Nessuna |
| 4 | Sottotitoli SRT/VTT | T3 | 1-2h | N/A (feature) | Nessuna |
| 5 | Tipografia avanzata | T3 | 2-3h | N/A (qualita') | Nessuna |
| 6 | Batch mode | T2 | 3-4h | N/A (feature) | Nessuna |
| 7 | Asset embedding | T2 | 4-5h | N/A (feature) | Nessuna |
| 8 | Rendering parallelo | T1 | 4-6h | 30-50% totale | #2 consigliato prima |
| 9 | Transizioni morph | T3 | 6-8h | N/A (qualita') | Nessuna |
| 10 | Video-in-video | T2 | 4-6h | N/A (feature) | #7 |

**Ordine raccomandato:** 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10

Logica: prima i quick win a basso effort (#1-5), poi le feature (#6-7), poi le ottimizzazioni complesse (#8), infine la qualita' avanzata (#9-10).

---

## Verifica

Ogni intervento viene verificato con:
1. **Render test:** Video 1080p30 20s con 5 scene
2. **Confronto A/B:** Tempo prima vs dopo (per Tier 1)
3. **Visual check:** Nessuna regressione visiva
4. **Demo mode:** Nessun impatto su demo pipeline

---

## Cosa NON fare

- **Riscrittura in Rust/wgpu** — Sovradimensionata (50-100k LOC per 20-30% gain)
- **Deno runtime** — Complessita' inutile, `tsx` funziona
- **Tauri desktop app** — Scope creep, progetto separato
- **JSX components** — HTML gia' sufficiente e piu' ispezionabile
