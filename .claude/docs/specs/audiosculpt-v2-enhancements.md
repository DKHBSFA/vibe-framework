# Audiosculpt v2 Enhancements

**Data:** 2026-02-03
**Stato:** Completato
**Priorità:** Alta

---

## Sommario

Miglioramenti alla skill audiosculpt basati sull'analisi di `references/audiosculpt-appunti.md`. Ogni proposta è stata valutata per fattibilità (con Strudel) e impatto qualitativo, selezionando le implementazioni ottimali.

---

## Obiettivi

1. **Hook immediato** — Audio che cattura nei primi 3 secondi (social media retention)
2. **UX semplificata** — L'utente sceglie use case, non generi musicali
3. **Compatibilità voiceover** — Musica che non compete con narrazione
4. **TTS Narration** — Voce narrante sincronizzata che legge i testi del video
5. **Transizioni armoniche migliori** — Voice leading pre-calcolato per family tonal
6. **Loop interessanti** — Variazioni automatiche per evitare monotonia

---

## Fase 1: P0 — Impatto immediato

### 1.1 Impact Frame System

**Problema:** I preset attuali hanno `intro` che "entra piano". Per video promo social, l'audio deve colpire al frame 1.

**Soluzione:** Aggiungere fase `impact` (0-3s) prima di `intro` con:
- Elementi ad alta energia immediata
- Sincronizzazione con primo elemento visivo
- Nessun fade-in

#### Schema JSON

```json
{
  "impact_frame": {
    "enabled": true,
    "duration_ms": 3000,
    "audio_offset_ms": -50,
    "sync_to_first_visual": true,

    "layers": {
      "0ms": {
        "role": "attention_grabber",
        "elements": ["sub_hit", "noise_burst"],
        "velocity": 1.0
      },
      "100ms": {
        "role": "genre_signifier",
        "elements": ["signature_sound"],
        "velocity": 0.9
      },
      "500ms": {
        "role": "hook_motif",
        "elements": ["melodic_cell"],
        "velocity": 0.85
      }
    },

    "visual_fade_compensation": {
      "if_visual_fade_in_ms": 500,
      "action": "delay_impact_to_first_opaque"
    }
  }
}
```

#### Implementazione Strudel

```javascript
// Impact phase pattern (0-3s)
const impactPattern = `stack(
  s('RolandTR808_bd').struct('t').gain(1.0).room(0.3),
  s('white').struct('t').lpf(8000).gain(0.7).decay(0.5),
  note('${hookMotif}').s('${leadSound}').delay(0.5).gain(0.85)
)`;

// Timeline con impact
const phases = {
  impact: impactPattern,  // 0-3s
  intro: introPattern,    // 3s-...
  build: buildPattern,
  climax: climaxPattern,
  resolve: resolvePattern
};
```

#### File da modificare

| File | Modifica |
|------|----------|
| `SKILL.md` | Aggiungere sezione "Impact Frame" con regole |
| `presets/soundtrack/*.json` | Aggiungere campo `impact_frame` a ogni preset |
| Generatore (in SKILL.md) | Logica per inserire fase impact prima di intro |

#### Impact Frame per famiglia

| Famiglia | Attention Grabber | Genre Signifier | Hook Motif |
|----------|-------------------|-----------------|------------|
| tonal | Piano chord stab | Orchestral swell | Melodic 4-note cell |
| modal | Pad swell | Reverb shimmer | Drone + single note |
| loop | 808 kick + sub | Synth riser | Arp pattern |
| experimental | Noise burst | Glitch texture | Rhythmic stutter |

---

### 1.2 Parametric Templates

**Problema:** L'utente deve scegliere "jazz" o "electronic" quando vuole "audio per trailer tech 30s".

**Soluzione:** Template parametrici che generano preset appropriati da use case + durata + energia.

#### Template disponibili

| Template ID | Use Cases | Base Style | Varianti durata |
|-------------|-----------|------------|-----------------|
| `tech_promo` | SaaS, startup, app, AI demo | electronic | 15s/30s/60s |
| `epic_trailer` | Film, game, product launch | orchestral | 15s/30s/60s |
| `chill_lifestyle` | Wellness, travel, coffee, fashion | lo-fi / chillwave | 30s/60s |
| `corporate_safe` | B2B, enterprise, fintech | corporate | 30s/60s |
| `hype_social` | Gaming, sports, energy, retail | upbeat / trap | 15s/30s |
| `luxury_minimal` | Beauty, fashion, premium auto | neo-classical / ambient | 30s/60s |

#### Schema Template

```json
{
  "template_id": "tech_promo",
  "display_name": "Tech / Startup Promo",
  "description": "Clean, optimistic electronic for SaaS, apps, AI demos",

  "parameters": {
    "duration": {
      "type": "enum",
      "values": ["15s", "30s", "60s"],
      "default": "30s"
    },
    "energy": {
      "type": "range",
      "min": 0.3,
      "max": 1.0,
      "default": 0.7
    },
    "voiceover": {
      "type": "bool",
      "default": false
    }
  },

  "base_style": "electronic",

  "duration_adaptations": {
    "15s": {
      "arc_strategy": "no_arc",
      "impact_intensity": 1.0,
      "bars": 8,
      "phases": {
        "impact": [0, 2],
        "climax": [2, 7],
        "resolve": [7, 8]
      }
    },
    "30s": {
      "arc_strategy": "compressed",
      "impact_intensity": 0.9,
      "bars": 16,
      "phases": {
        "impact": [0, 2],
        "build": [2, 8],
        "climax": [8, 14],
        "resolve": [14, 16]
      }
    },
    "60s": {
      "arc_strategy": "full",
      "impact_intensity": 0.8,
      "bars": 32,
      "phases": {
        "impact": [0, 2],
        "intro": [2, 8],
        "build": [8, 16],
        "climax": [16, 28],
        "resolve": [28, 32]
      }
    }
  },

  "energy_scaling": {
    "affects": ["velocity_multiplier", "density", "filter_brightness"],
    "formula": {
      "velocity_multiplier": "0.5 + (energy * 0.5)",
      "density": "energy < 0.5 ? 'sparse' : energy < 0.8 ? 'balanced' : 'dense'",
      "filter_brightness": "1000 + (energy * 3000)"
    }
  },

  "voiceover_adaptation": {
    "if_true": {
      "apply_mode": "voiceover_bed",
      "mid_gain_reduction": 0.3
    }
  }
}
```

#### File da creare

| File | Contenuto |
|------|-----------|
| `presets/templates/tech_promo.json` | Template tech/startup |
| `presets/templates/epic_trailer.json` | Template epic/cinematic |
| `presets/templates/chill_lifestyle.json` | Template chill/lo-fi |
| `presets/templates/corporate_safe.json` | Template corporate |
| `presets/templates/hype_social.json` | Template hype/upbeat |
| `presets/templates/luxury_minimal.json` | Template luxury |

#### Nuovi comandi audiosculpt

| Comando | Descrizione |
|---------|-------------|
| `/audiosculpt create --template <id>` | Usa template parametrico |
| `/audiosculpt create --narration` | Abilita narrazione TTS (solo con video-craft) |
| `/audiosculpt add-narration <html>` | Aggiungi narrazione a HTML esistente |

#### Aggiornamenti SKILL.md

Aggiungere sezione "Using Templates":

```markdown
## Using Templates (Recommended for Video Promo)

Instead of choosing a musical style, select a **template** that matches your use case:

| Your need | Template | Command |
|-----------|----------|---------|
| Tech startup promo | `tech_promo` | `/audiosculpt create --template tech_promo --duration 30s` |
| Movie/game trailer | `epic_trailer` | `/audiosculpt create --template epic_trailer --duration 15s` |
| Lifestyle/wellness | `chill_lifestyle` | `/audiosculpt create --template chill_lifestyle --duration 60s` |

Templates auto-configure:
- Arc strategy based on duration
- Impact intensity based on use case
- Voiceover compatibility when flagged
```

---

## Fase 2: P1 — Alta priorità

### 2.1 Voiceover Mode (Dual-Layer Architecture)

**Problema:** Strudel non ha sidechain EQ. La proposta originale (notch 300Hz-3kHz) è inapplicabile.

**Soluzione:** Generare due layer separati che lasciano spazio frequenziale per la voce.

#### Architettura

```
┌─────────────────────────────────────────┐
│  VOICEOVER MODE                         │
├─────────────────────────────────────────┤
│  SUB BED (20-200Hz)                     │
│  - Sub bass, kick low frequencies       │
│  - Gain: 0.8                            │
│  - Sidechain: to kick                   │
├─────────────────────────────────────────┤
│  ████████ VOICEOVER ZONE ████████       │
│  ████████ (200Hz - 4kHz) ████████       │
│  ████████ MUSIC MINIMAL  ████████       │
├─────────────────────────────────────────┤
│  AIR BED (4kHz-12kHz)                   │
│  - Hi-hats, shimmers, high pads         │
│  - Gain: 0.6                            │
├─────────────────────────────────────────┤
│  MID PUNCTUATION (sparse)               │
│  - Melody accents only (not sustained)  │
│  - Gain: 0.25                           │
│  - Rhythm: sparse hits, not continuous  │
└─────────────────────────────────────────┘
```

#### Schema JSON

```json
{
  "voiceover_mode": {
    "enabled": false,

    "layers": {
      "sub_bed": {
        "frequency_focus": "below_200hz",
        "instruments": ["sub_bass", "kick_sub"],
        "gain": 0.8,
        "filter": { "lpf": 200 }
      },
      "air_bed": {
        "frequency_focus": "above_4000hz",
        "instruments": ["hihat", "shimmers", "pad_high"],
        "gain": 0.6,
        "filter": { "hpf": 4000 }
      },
      "mid_punctuation": {
        "frequency_focus": "200hz_4000hz",
        "instruments": ["melody_stabs", "chord_hits"],
        "gain": 0.25,
        "sparse": true,
        "max_events_per_bar": 2
      }
    },

    "excluded_from_voiceover": [
      "sustained_pads_mid",
      "bass_harmonics",
      "vocal_range_melody"
    ]
  }
}
```

#### Implementazione Strudel

```javascript
// Normal mode
const normalPattern = `stack(
  ${bassPattern},
  ${padPattern},
  ${melodyPattern},
  ${drumsPattern}
)`;

// Voiceover mode - split layers
const voiceoverPattern = `stack(
  // Sub bed
  ${bassPattern}.lpf(200).gain(0.8),
  s('RolandTR808_bd').struct('t ~ ~ ~ t ~ ~ ~').lpf(100).gain(0.7),

  // Air bed
  s('RolandTR808_hh').struct('~ t ~ t ~ t ~ t').hpf(4000).gain(0.5),
  ${padPattern}.hpf(4000).gain(0.4),

  // Mid punctuation (sparse)
  ${melodyPattern}.struct('t ~ ~ ~ ~ ~ ~ ~').lpf(4000).hpf(200).gain(0.25)
)`;
```

#### File da modificare

| File | Modifica |
|------|----------|
| `SKILL.md` | Sezione "Voiceover Mode" con regole |
| `presets/soundtrack/*.json` | Aggiungere `voiceover_mode` schema |
| Ogni preset | Definire quali instruments vanno in quale layer |

---

### 2.2 TTS Narration System (Integrazione video-craft)

**Problema:** I video promo hanno spesso una voce narrante che legge i testi mostrati. Attualmente bisogna registrarla manualmente.

**Soluzione:** Generazione automatica di narrazione TTS sincronizzata con le animazioni, integrata nel workflow video-craft.

#### Due Entry Point

```
┌─────────────────────────────────────────────────────────────┐
│  ENTRY POINT A: /video-craft create                         │
│                                                             │
│  Step 6 (YAML) contiene già i testi strutturati:           │
│  scenes[].elements[].text / .title                          │
│                                                             │
│  → Genera narration_brief SENZA parsing                     │
│  → Passa a audiosculpt insieme all'HTML                     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  ENTRY POINT B: /audiosculpt add-narration <html>           │
│                                                             │
│  HTML esistente → Parsing DOM per estrarre:                 │
│  - .el innerText                                            │
│  - animation-delay da CSS                                   │
│  - Tipo elemento da classi CSS                              │
│                                                             │
│  → Genera narration_brief da parsing                        │
└─────────────────────────────────────────────────────────────┘
```

#### Integrazione nel workflow video-craft

**Flusso attuale video-craft:**
```
1. Source (folder/url/manual)
2. Design System (ui-craft)
3. Video Intent
4. Format
5. Style (safe/chaos/hybrid/cocomelon)
6. Speed
7. Generate YAML (con /seo-geo-copy)
8. Review
9. Render → MP4
```

**Flusso con narration:**
```
1-6. (invariati)

7. Generate YAML (con /seo-geo-copy)
   └── Output: YAML con scenes[].elements[].text

8. *** NUOVO: Audio Options ***
   AskUserQuestion:
   - "Add voice narration?"
     ├── Yes, read all text
     ├── Yes, headlines only
     ├── Yes, let me select
     └── No, music only

   Se narration enabled:
   - "Voice?" → en-US-AriaNeural / en-US-GuyNeural / en-GB-SoniaNeural
   - "Narration style?" → enthusiastic / neutral / calm

9. Review YAML + Narration Plan
   Mostra:
   - YAML (come prima)
   - Lista testi che verranno letti con timing
   - Stile musicale selezionato (voiceover_mode auto-enabled)

10. Render
    a) Genera HTML da YAML
    b) Genera narration_brief da YAML
    c) Chiama audiosculpt con:
       - HTML
       - narration_brief
       - voiceover_mode: true (automatico)
    d) audiosculpt:
       - Genera MP3 narrazione (Edge-TTS)
       - Genera music bed (Strudel con voiceover_mode)
       - Calcola ducking timeline
       - Inietta script audio nell'HTML
    e) Playwright cattura frames
    f) FFmpeg encode MP4

11. Output: MP4 con audio completo (narrazione + musica)
```

#### Narration Brief Schema

Generato da video-craft (Entry Point A) o da parsing HTML (Entry Point B):

```json
{
  "narration": {
    "enabled": true,
    "voice": "en-US-AriaNeural",
    "style": "enthusiastic",

    "prosody_defaults": {
      "rate": "-5%",
      "pitch": "+0Hz"
    },

    "emphasis_by_element_type": {
      "heading": { "rate": "-15%", "pitch": "+5Hz", "suffix": "!!" },
      "text": { "rate": "+0%", "pitch": "+0Hz", "suffix": "" },
      "button": { "rate": "-10%", "pitch": "+8Hz", "suffix": "!!" }
    },

    "scenes": [
      {
        "scene_index": 0,
        "scene_name": "Hook",
        "elements": [
          {
            "id": "narr-s0-e0",
            "display_text": "THE FUTURE IS HERE",
            "narration_text": "The future is here!!",
            "element_type": "heading",
            "timing": {
              "appear_ms": 300,
              "animation_duration_ms": 500
            },
            "audio_file": null
          },
          {
            "id": "narr-s0-e1",
            "display_text": "Faster than ever.",
            "narration_text": "Faster than ever.",
            "element_type": "text",
            "timing": {
              "appear_ms": 1200,
              "animation_duration_ms": 400
            },
            "audio_file": null
          }
        ]
      }
    ],

    "summary": {
      "total_items": 12,
      "estimated_speech_duration_ms": 28000,
      "video_duration_ms": 30000
    }
  }
}
```

#### Differenza `display_text` vs `narration_text`

| Campo | Uso | Esempio |
|-------|-----|---------|
| `display_text` | Testo mostrato a schermo (da YAML) | `"50% FASTER"` |
| `narration_text` | Testo letto dalla voce (trasformato) | `"Fifty percent faster!!"` |

**Trasformazioni automatiche:**
- Numeri → parole (`50%` → `fifty percent`)
- Punteggiatura emotiva (`!!` per headlines, `!` per CTA)
- Acronimi espansi se necessario

#### Generazione TTS (Edge-TTS)

**Requisito:** Python con `edge-tts` installato.

```python
# narration_generator.py (generato da Claude, eseguito con Bash)
import edge_tts
import asyncio
import json
from pathlib import Path

async def generate_narration(brief_path: str, output_dir: str):
    with open(brief_path) as f:
        brief = json.load(f)

    narration = brief['narration']
    voice = narration['voice']
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    for scene in narration['scenes']:
        for element in scene['elements']:
            text = element['narration_text']
            element_type = element['element_type']
            emphasis = narration['emphasis_by_element_type'].get(
                element_type,
                narration['prosody_defaults']
            )

            ssml = f"""
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis">
    <voice name="{voice}">
        <prosody rate="{emphasis['rate']}" pitch="{emphasis['pitch']}">
            {text}
        </prosody>
    </voice>
</speak>"""

            output_file = output_path / f"{element['id']}.mp3"
            communicate = edge_tts.Communicate(ssml, voice)
            await communicate.save(str(output_file))

            # Update brief with audio file path
            element['audio_file'] = str(output_file)

    # Save updated brief
    with open(brief_path, 'w') as f:
        json.dump(brief, f, indent=2)

if __name__ == '__main__':
    import sys
    asyncio.run(generate_narration(sys.argv[1], sys.argv[2]))
```

**Esecuzione:**
```bash
python narration_generator.py narration_brief.json ./audio/narration/
```

#### Ducking Timeline

Calcolata dopo generazione MP3 (durate note):

```json
{
  "ducking": {
    "enabled": true,
    "music_gain_normal": 0.5,
    "music_gain_ducked": 0.15,
    "attack_ms": 50,
    "release_ms": 200,

    "events": [
      { "time_ms": 250, "action": "duck", "target_gain": 0.15 },
      { "time_ms": 2300, "action": "release", "target_gain": 0.5 },
      { "time_ms": 3950, "action": "duck", "target_gain": 0.15 },
      { "time_ms": 5700, "action": "release", "target_gain": 0.5 }
    ]
  }
}
```

**Calcolo:**
```
Per ogni narration element:
  duck_start = element.appear_ms - attack_ms
  duck_end = element.appear_ms + element.audio_duration_ms + release_ms
```

#### Implementazione Browser (Web Audio API)

```javascript
// Audio graph
const audioContext = new AudioContext();
const soundtrackGain = audioContext.createGain();
const narrationGain = audioContext.createGain();

// Routing
soundtrackGain.connect(audioContext.destination);
narrationGain.connect(audioContext.destination);

// Gain iniziali
soundtrackGain.gain.value = 0.5;  // Music bed level
narrationGain.gain.value = 1.0;   // Narration full volume

// Preload narration MP3s
const narrationBuffers = new Map();
async function preloadNarration(brief) {
  for (const scene of brief.narration.scenes) {
    for (const el of scene.elements) {
      if (el.audio_file) {
        const response = await fetch(el.audio_file);
        const arrayBuffer = await response.arrayBuffer();
        const audioBuffer = await audioContext.decodeAudioData(arrayBuffer);
        narrationBuffers.set(el.id, {
          buffer: audioBuffer,
          startMs: el.timing.appear_ms
        });
      }
    }
  }
}

// Schedule ducking
function scheduleDucking(ducking, startTime) {
  for (const event of ducking.events) {
    const eventTime = startTime + (event.time_ms / 1000);
    soundtrackGain.gain.linearRampToValueAtTime(
      event.target_gain,
      eventTime
    );
  }
}

// Schedule narration playback
function scheduleNarration(startTime) {
  for (const [id, data] of narrationBuffers) {
    const source = audioContext.createBufferSource();
    source.buffer = data.buffer;
    source.connect(narrationGain);
    source.start(startTime + (data.startMs / 1000));
  }
}

// Play all
async function playWithNarration(brief) {
  await preloadNarration(brief);
  const startTime = audioContext.currentTime + 0.1;

  // Start Strudel music
  await startStrudelMusic();

  // Schedule ducking
  scheduleDucking(brief.ducking, startTime);

  // Schedule narration
  scheduleNarration(startTime);
}
```

#### File Structure per Narration

```
project/
├── video-config.yaml          # YAML video-craft
├── narration_brief.json       # Generato da video-craft
├── audio/
│   ├── narration/
│   │   ├── narr-s0-e0.mp3    # "The future is here!!"
│   │   ├── narr-s0-e1.mp3    # "Faster than ever."
│   │   └── ...
│   └── manifest.json          # Brief aggiornato con durate
└── output/
    ├── video.html             # HTML con audio iniettato
    └── video.mp4              # Video finale
```

#### Voci Edge-TTS raccomandate

| Voice | Lingua | Carattere | Use case |
|-------|--------|-----------|----------|
| `en-US-AriaNeural` | EN-US | Femminile, professionale | Corporate, tech |
| `en-US-GuyNeural` | EN-US | Maschile, energico | Sports, gaming |
| `en-US-JennyNeural` | EN-US | Femminile, calda | Lifestyle, wellness |
| `en-GB-SoniaNeural` | EN-GB | Femminile, elegante | Luxury, fashion |
| `en-AU-NatashaNeural` | EN-AU | Femminile, amichevole | Casual, travel |

#### Tecniche pseudo-emozione Edge-TTS

| Tecnica | Implementazione | Effetto |
|---------|-----------------|---------|
| Doppio punto esclamativo | `"Great!!"` | Energia base |
| Triplo punto esclamativo | `"Amazing!!!"` | Enfasi massima |
| Ellipsis | `"And the result is..."` | Suspense |
| Rate variabile | `-15%` per headline, `+0%` per body | Gerarchia |
| Pitch boost | `+5Hz` per headline | Prominenza |

#### Fallback se Edge-TTS non disponibile

1. **Check:** `which python && pip show edge-tts`
2. **Se manca:** Avvisa utente con istruzioni installazione
3. **Alternativa browser:** `speechSynthesis` API (qualità inferiore)

```javascript
// Fallback browser TTS
if (!edgeTTSAvailable) {
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.voice = speechSynthesis.getVoices()
    .find(v => v.lang.startsWith('en'));
  speechSynthesis.speak(utterance);
}
```

#### Aggiornamenti video-craft SKILL.md

Aggiungere in Step 8 (nuovo):

```markdown
### Step 8: Audio Options

Ask the user about audio:

**Narration:**
- "Add voice narration that reads the on-screen text?"
  - Yes, read all text
  - Yes, headlines only
  - Yes, let me select which elements
  - No, music only

If narration enabled:
- "Which voice?" → Show top 5 voices for detected language
- "Narration style?" → enthusiastic / neutral / calm

**Music:**
- "Add background music?" → Yes (default) / No
- If yes, audiosculpt auto-selects style based on video mode/intent

**Note:** When narration is enabled, music automatically uses
`voiceover_mode` (reduced mid frequencies, ducking during speech).
```

#### Verifiche Narration

- [ ] video-craft genera narration_brief corretto da YAML
- [ ] Edge-TTS genera MP3 per ogni elemento
- [ ] Timing sincronizzato con animazioni CSS
- [ ] Ducking funziona (musica si abbassa durante voce)
- [ ] Fallback browser TTS funziona se edge-tts manca
- [ ] MP4 finale ha audio corretto

---

### 2.3 Pre-computed Voice Leading Tables

**Problema:** `.voicing()` di Strudel non calcola voice leading dinamico tra accordi.

**Soluzione:** Tabelle pre-calcolate con transizioni ottimali per ogni progressione comune.

#### Struttura

```json
{
  "voiceLeadingTables": {
    "family": "tonal",
    "key": "C_major",

    "chords": {
      "Cmaj7": {
        "close": ["C3", "E3", "G3", "B3"],
        "drop2": ["E2", "C3", "G3", "B3"],
        "spread": ["C2", "G3", "B3", "E4"]
      },
      "Dm7": {
        "close": ["D3", "F3", "A3", "C4"],
        "drop2": ["F2", "D3", "A3", "C4"],
        "spread": ["D2", "A3", "C4", "F4"]
      },
      "G7": {
        "close": ["G2", "B2", "D3", "F3"],
        "drop2": ["B1", "G2", "D3", "F3"],
        "spread": ["G1", "D3", "F3", "B3"]
      }
    },

    "transitions": {
      "Cmaj7_to_Dm7": {
        "voicing": "drop2_to_drop2",
        "voice_motion": {
          "bass": "E2 -> F2 (step up)",
          "tenor": "C3 -> D3 (step up)",
          "alto": "G3 -> A3 (step up)",
          "soprano": "B3 -> C4 (step up)"
        },
        "parallel_check": "none",
        "common_tones": 0,
        "smoothness_score": 0.9
      },
      "Dm7_to_G7": {
        "voicing": "drop2_to_drop2",
        "voice_motion": {
          "bass": "F2 -> G2 (step up) OR F2 -> B1 (leap down for stronger bass)",
          "tenor": "D3 -> D3 (common tone)",
          "alto": "A3 -> G3 (step down) OR A3 -> B3 (step up to leading tone)",
          "soprano": "C4 -> B3 (step down)"
        },
        "parallel_check": "none",
        "common_tones": 1,
        "smoothness_score": 0.85
      },
      "G7_to_Cmaj7": {
        "voicing": "drop2_to_drop2",
        "voice_motion": {
          "bass": "B1 -> C2 (step up, leading tone resolution)",
          "tenor": "G2 -> G2 (common tone) OR G2 -> C3 (leap to root)",
          "alto": "D3 -> E3 (step up)",
          "soprano": "F3 -> E3 (step down, 7th resolves down)"
        },
        "parallel_check": "none",
        "common_tones": 1,
        "smoothness_score": 0.95,
        "cadence_type": "authentic"
      }
    }
  }
}
```

#### Progressioni da pre-calcolare

**Per family tonal (priorità):**

| Key | Progression | Use |
|-----|-------------|-----|
| C major | I - vi - IV - V | Pop standard |
| C major | I - V - vi - IV | Pop alternate |
| C major | ii - V - I | Jazz turnaround |
| A minor | i - VI - III - VII | Epic minor |
| G major | I - IV - V - I | Simple |
| D minor | i - iv - V - i | Dramatic |

**Per family loop:**
- Voice leading meno critico (power chords, parallele OK)
- Tabelle semplificate: root + fifth only

#### Implementazione Strudel

```javascript
// Invece di:
chord('<Cmaj7 Dm7 G7 Cmaj7>').voicing()

// Usare note esplicite dalla tabella:
stack(
  // Bass voice
  note('<e2 f2 b1 c2>').s('bass'),
  // Tenor voice
  note('<c3 d3 d3 c3>').s('pad'),
  // Alto voice
  note('<g3 a3 b3 e3>').s('pad'),
  // Soprano voice
  note('<b3 c4 b3 e4>').s('lead')
)
```

#### File da creare

| File | Contenuto |
|------|-----------|
| `presets/voice-leading/tonal-major.json` | Tabelle per chiavi maggiori |
| `presets/voice-leading/tonal-minor.json` | Tabelle per chiavi minori |
| `presets/voice-leading/jazz-extended.json` | Tabelle per accordi jazz (7, 9, 13) |

---

## Fase 3: P2 — Media priorità

### 3.1 Preset Inheritance System

**Problema:** Per creare "jazz con drums elettroniche" bisogna duplicare tutto il preset jazz.

**Soluzione:** Sistema di ereditarietà con override selettivi.

#### Schema

```json
{
  "style": "jazz-electronic",
  "extends": "jazz",

  "modifiers": ["electronic_drums", "synth_bass"],

  "override": {
    "sounds.bass.source": "sawtooth",
    "sounds.bass.lpf": 400,
    "sounds.kick": {
      "source": "bd",
      "bank": "RolandTR808",
      "gain": 0.85
    },
    "sounds.hihat": {
      "source": "hh",
      "bank": "RolandTR808",
      "hpf": 6000
    },
    "temporal.swing": 0.55,
    "patterns.climax.rhythm": "stack(s('RolandTR808_bd').struct('t ~ ~ ~ t ~ ~ ~'), s('RolandTR808_hh').struct('t t t t t t t t').gain(0.6))"
  },

  "keep_from_parent": [
    "harmonic_system",
    "progression",
    "voiceLeading",
    "form"
  ]
}
```

#### Logica di merge

```javascript
function loadPreset(styleName) {
  const preset = readJSON(`presets/soundtrack/${styleName}.json`);

  if (preset.extends) {
    const parent = loadPreset(preset.extends); // Recursive
    return deepMerge(parent, preset.override, {
      keep: preset.keep_from_parent
    });
  }

  return preset;
}
```

#### Modifier library

| Modifier | Cosa cambia |
|----------|-------------|
| `electronic_drums` | Sostituisce drums acustici con TR-808/909 |
| `synth_bass` | Sostituisce bass acustico con sawtooth/square |
| `vintage_tape` | Aggiunge tape saturation, wow/flutter |
| `modern_clean` | Rimuove room/reverb, suono pulito |
| `dark_mode` | Abbassa filtri, più sub, meno highs |
| `bright_mode` | Alza filtri, più presence |

---

### 3.2 Loop Variation System

**Problema:** Loop di 8 bar ripetuto diventa noioso.

**Soluzione:** Variazioni automatiche ogni N cicli.

#### Schema

```json
{
  "loop_config": {
    "base_length_bars": 8,
    "seamless": true,
    "return_to_tonic": true,

    "variations": {
      "every_2_loops": {
        "action": "add_fill",
        "position": "bar_4",
        "pattern": "s('RolandTR808_sd').struct('~ ~ ~ t t t t t').gain(0.7)"
      },
      "every_4_loops": {
        "action": "transpose_melody",
        "semitones": 3
      },
      "every_8_loops": {
        "action": "swap_pattern",
        "target": "rhythm",
        "alternate_with": "rhythm_variation_b"
      }
    },

    "humanization": {
      "velocity_variance": 0.15,
      "timing_drift_ms": 10,
      "apply_to": ["melody", "hihat"]
    }
  }
}
```

#### Implementazione Strudel

```javascript
// Variazioni native Strudel
note("<c4 e4 g4>")
  .every(2, x => x.add(
    s('RolandTR808_sd').struct('~ ~ ~ t t t t t').gain(0.7)
  ))
  .every(4, x => x.transpose(3))
  .every(8, x => x.fast(2))
  .sometimesBy(0.15, x => x.gain(rand.range(0.7, 1.0)))
```

---

## Fase 4: P3 — Bassa priorità

### 4.1 Feel Profiles

**Problema:** Time signature non cattura il "feel" (compound, shuffle, straight).

**Soluzione:** Layer di feel sopra temporal.

```json
{
  "feel_profiles": {
    "straight": {
      "swing": 0.5,
      "accent_pattern": [1, 0.5, 0.7, 0.5],
      "grid": 16
    },
    "shuffle": {
      "swing": 0.62,
      "accent_pattern": [1, 0.3, 0.8, 0.3],
      "grid": 12
    },
    "compound": {
      "swing": 0.5,
      "accent_pattern": [1, 0.4, 0.4, 1, 0.4, 0.4],
      "grid": 12,
      "grouping": [3, 3]
    },
    "halftime": {
      "swing": 0.5,
      "accent_pattern": [1, 0.3, 0.5, 0.3, 0.9, 0.3, 0.5, 0.3],
      "grid": 16,
      "snare_on": [5]
    }
  }
}
```

### 4.2 Soft Orchestration Constraints

**Problema:** Regole rigide bloccano pattern validi.

**Soluzione:** Constraints come warning, non errori.

```json
{
  "spectral_guidelines": {
    "sub_20_80hz": {
      "max_simultaneous": 1,
      "violation": "warn",
      "exceptions": ["dubstep", "trap"]
    },
    "bass_80_250hz": {
      "max_simultaneous": 2,
      "min_interval": "P5",
      "violation": "warn"
    },
    "mid_250_2000hz": {
      "max_simultaneous": 4,
      "violation": "auto_reduce_lowest_gain"
    }
  }
}
```

---

## File Structure Finale

```
.claude/skills/audiosculpt/
├── SKILL.md                          # Aggiornato con nuove sezioni
├── narration_generator.py            # NUOVO - Script Edge-TTS
├── presets/
│   ├── coherence-matrix.json         # Esistente
│   ├── templates/                    # NUOVO
│   │   ├── tech_promo.json
│   │   ├── epic_trailer.json
│   │   ├── chill_lifestyle.json
│   │   ├── corporate_safe.json
│   │   ├── hype_social.json
│   │   └── luxury_minimal.json
│   ├── voice-leading/                # NUOVO
│   │   ├── tonal-major.json
│   │   ├── tonal-minor.json
│   │   └── jazz-extended.json
│   ├── narration/                    # NUOVO
│   │   ├── voices.json               # Catalogo voci raccomandate
│   │   └── emphasis-profiles.json    # Profili prosodia per element type
│   ├── soundtrack/
│   │   ├── jazz.json                 # Aggiornato con impact_frame, voiceover_mode
│   │   ├── electronic.json           # Aggiornato
│   │   └── ... (tutti i 20 preset)
│   └── sfx/
│       └── ... (invariati)

.claude/skills/video-craft/
├── SKILL.md                          # Aggiornato con Step 8: Audio Options
└── engine/src/
    └── ... (invariato, audio è post-processing)
```

---

## Verifiche

### Per Impact Frame
- [ ] Generare audio con template 15s → verificare hook nei primi 3 secondi
- [ ] Testare sync con video che ha fade-in visivo
- [ ] Confrontare A/B: preset con/senza impact frame

### Per Parametric Templates
- [ ] `/audiosculpt create --template tech_promo --duration 30s` genera correttamente
- [ ] Parametro `voiceover: true` attiva dual-layer
- [ ] Energy scaling produce differenze udibili

### Per Voiceover Mode
- [ ] Generare 30s di audio voiceover mode
- [ ] Sovrapporre voce parlata → verificare intelligibilità
- [ ] Confrontare con mode normale

### Per Voice Leading Tables
- [ ] Progressione ii-V-I suona smooth
- [ ] Nessun parallel fifths in family tonal
- [ ] Common tones mantenuti dove dichiarato

### Per TTS Narration
- [ ] `/video-craft create` con narration genera brief corretto
- [ ] `narration_generator.py` produce MP3 validi
- [ ] Timing narrazione sincronizzato con animazioni
- [ ] Ducking funziona: musica -12dB durante voce
- [ ] Fallback browser TTS se edge-tts non disponibile
- [ ] `/audiosculpt add-narration <html>` funziona su HTML esistente
- [ ] MP4 finale ha audio completo (narration + music + ducking)

---

## Timeline stimata

| Fase | Tasks | Effort | Dipendenze |
|------|-------|--------|------------|
| P0a | Impact Frame | 2h | Nessuna |
| P0b | Parametric Templates (6 template) | 4h | Impact Frame |
| P1a | Voiceover Mode | 3h | Nessuna |
| P1b | TTS Narration System | 5h | Voiceover Mode |
| P1c | Voice Leading Tables | 4h | Nessuna |
| P2a | Preset Inheritance | 2h | Nessuna |
| P2b | Loop Variation | 2h | Nessuna |
| P3a | Feel Profiles | 3h | Nessuna |
| P3b | Soft Constraints | 2h | Nessuna |

**Totale P0+P1:** ~18h
**Totale completo:** ~27h

### Breakdown TTS Narration (P1b)

| Sub-task | Effort |
|----------|--------|
| narration_generator.py (Edge-TTS script) | 1h |
| Narration brief schema + builder | 1h |
| Ducking timeline calculator | 0.5h |
| Browser audio integration (Web Audio API) | 1.5h |
| video-craft integration (Step 8) | 1h |

---

## Note implementative

### Retrocompatibilità
- Tutti i campi nuovi sono **opzionali**
- Preset esistenti continuano a funzionare
- `impact_frame.enabled: false` di default per non rompere nulla

### Ordine implementazione
1. **Impact Frame** — indipendente, testabile subito
2. **Templates** — dipende da impact frame per 15s
3. **Voiceover Mode** — indipendente, necessario per narration
4. **TTS Narration** — dipende da voiceover mode + modifica video-craft
5. **Voice Leading** — indipendente ma beneficia da templates

### Testing
- Ogni fase ha test audio generato
- Confronto A/B con versione precedente
- Feedback soggettivo su "professionalità" output

### Dipendenze esterne (Narration)
- **Python 3.8+** con `pip install edge-tts`
- **Connessione internet** per chiamate Edge-TTS (generazione offline non possibile)
- **FFmpeg** per encoding finale (già requisito di video-craft)
