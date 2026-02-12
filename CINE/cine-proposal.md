# Product Requirements Document (PRD)

## Cine: Programmatic Video Engine

**Versione:** 1.0.0  
**Data:** 2025-02-13  
**Stato:** Draft  
**Autore:** Product Team  

---

## 1. Executive Summary

Cine è un motore di generazione video programmatico nativo per l'era dell'intelligenza artificiale. A differenza delle soluzioni esistenti che si basano su browser headless, Cine utilizza rendering GPU nativo per offrire performance ordini di magnitudine superiori, integrazione nativa con Large Language Models tramite lo standard skill.MD, e workflow di produzione video completamente automatizzati.

**Problema:** Gli strumenti esistenti (Remotion, After Effects scripting) sono lenti, non deterministici, e non progettati per l'integrazione con AI. Un video di 60 secondi in 4K richiede 15-30 minuti di rendering su hardware consumer.

**Soluzione:** Cine riduce il tempo di rendering del 95% tramite WebGPU nativo, abilita la generazione video guidata da LLM, e supporta workflow di produzione batch scalabili.

---

## 2. Visione e Obiettivi

### 2.1 Visione a Lungo Termine
Diventare l'infrastruttura standard per la generazione video programmatica nell'era AI, abilitando casi d'uso impossibili con gli strumenti attuali: video personalizzati in tempo reale, contenuto generativo scalabile, e produzione broadcast automatizzata.

### 2.2 Obiettivi di Prodotto (12 mesi)

| Obiettivo | Metrica | Target |
|-----------|---------|--------|
| Performance | Tempo render 1080p60 | <5% del tempo reale video |
| Adozione | Download CLI | 10,000 utenti attivi |
| Integrazione | Supporto skill.MD | 100% compatibilità Claude/Kimi |
| Affidabilità | Crash rate | <0.1% su rendering >1h |

---

## 3. Utenti Target

### 3.1 Segmenti Principali

**1. AI-Native Developers**
- Sviluppatori che usano Claude Code, Cursor, o Kimi per generare codice
- Vogliono creare video senza uscire dal flusso di sviluppo
- Priorità: velocità, integrazione LLM, determinismo

**2. Video Engineers (Broadcast/Media)**
- Professionisti che producono contenuto in volume (news, sport, e-commerce)
- Necessitano di 100-1000 video/giorno con brand consistency
- Priorità: throughput, qualità 4K+, automazione

**3. Creative Technologists**
- Artisti generativi, agenzie creative tech-forward
- Esplorano confini tra AI e video tradizionale
- Priorità: flessibilità, effetti avanzati, real-time preview

### 3.2 Persona Primaria: "Alex, AI-Native Developer"

- 28 anni, full-stack developer
- Usa Claude Code quotidianamente per scrivere codice
- Deve creare video promo per il SaaS che sta costruendo
- Non ha competenze video tradizionali (After Effects, Premiere)
- Vuole: "Crea un video di 30s che spieghi la feature X usando i colori del mio brand"

---

## 4. Requisiti Funzionali

### 4.1 Core Engine

**FE-001: Rendering GPU Nativo**
- Il sistema deve renderizzare video utilizzando WebGPU/Vulkan/Metal/DirectX12 senza dipendenze da browser
- Deve supportare hardware encoding (NVENC, VideoToolbox, VA-API) per H.264, HEVC, AV1
- Deve garantire determinismo assoluto: stesso input = stesso output bit-identico su qualsiasi piattaforma

**FE-002: Composizione Scene**
- Supportare definizione scene tramite React-like JSX
- Supportare composizione node-based per casi d'uso avanzati
- Permettere nesting di componenti con propagazione di proprietà (props)
- Supportare variabili d'ambiente e parametrizzazione dinamica

**FE-003: Timeline e Temporizzazione**
- Timeline basata su frame (non tempo) per determinismo
- Supporto frame rates: 24, 25, 30, 60, 120 fps
- Supporto durate arbitrarie (da 1 frame a ore)
- Gestione di easing curves, keyframes, e interpolazioni

### 4.2 AI Integration

**FE-004: Standard skill.MD**
- Implementare parser completo per skill.MD con sezioni: capabilities, constraints, workflow, commands
- Esportare capability discovery per LLM (Claude, Kimi, GPT-4, ecc.)
- Validazione automatica compatibilità versione

**FE-005: AI-Assisted Generation**
- Generazione struttura scene da descrizione naturale
- Expansion di prompt vaghi in parametri concreti (es. "animazione dinamica" → keyframes specifici)
- Suggestion system per ottimizzazione scene basata su contesto progetto

**FE-006: Repository Context Awareness**
- Scansione automatica design system (colori, font, componenti)
- Estrazione copy e asset da codebase esistente
- Mantenimento sincronizzazione con modifiche repository

### 4.3 Asset Pipeline

**FE-007: Asset Management**
- Import nativo: immagini (PNG, JPG, WebP, SVG, AVIF), font (TTF, OTF, WOFF2), audio (WAV, MP3, AAC)
- Generazione AI integrata: text-to-image, text-to-speech, music generation
- Content-addressed caching: stesso input = stesso output, deduplicazione automatica
- Versioning e lineage tracking per asset generati

**FE-008: Real-time Preview**
- Viewport interattiva con playback istantaneo (no attesa rendering)
- Scrubbing timeline con feedback immediato (<50ms latency)
- Hot-reload su modifica codice o asset
- Modalità wireframe per preview ultra-veloce su hardware limitato

### 4.4 Output e Distribuzione

**FE-009: Format Output**
- Video: MP4 (H.264/HEVC), WebM (VP9/AV1), MOV (ProRes), GIF, image sequence (PNG/JPG/EXR)
- Risoluzioni: da 360p a 8K UHD, aspect ratio arbitrari
- Bitrate control: CBR, VBR, CQ, supporto preset qualità

**FE-010: Batch e Automation**
- Rendering parallelo multi-scena
- Queue management con prioritizzazione
- Webhook e callback su completamento
- Integrazione CI/CD (GitHub Actions, GitLab CI, ecc.)

---

## 5. Requisiti Non Funzionali

### 5.1 Performance

| Metrica | Requisito | Note |
|---------|-----------|------|
| Throughput 1080p60 | >500 fps su RTX 3060 equivalente | Rendering puro, non encode |
| Latenza preview | <50ms frame-to-frame | Su GPU dedicata |
| Memory footprint | <500MB base + 50MB/minuto video | vs 2-4GB di Chrome |
| Startup time | <2s da comando a preview visibile | Cold start |
| Scale CPU fallback | Funzionale su CPU solo, 10x più lento | Lavapipe/software renderer |

### 5.2 Affidabilità

- **Determinismo:** Stesso progetto, stessa macchina, stesso output bit-identico. Cross-platform: differenze <0.1% per floating point.
- **Crash recovery:** Resume rendering da ultimo frame completato su crash/oom.
- **Validation:** Schema strict per file progetto, errori descrittivi con suggerimenti fix.

### 5.3 Compatibilità

| Piattaforma | Supporto | Note |
|-------------|----------|------|
| Linux | Primaria | Vulkan, X11/Wayland |
| macOS | Primaria | Metal, Intel/Apple Silicon |
| Windows | Primaria | DirectX 12, Vulkan fallback |
| Docker/Container | Supportata | GPU passthrough richiesto per performance |
| WebAssembly | Futura | Preview solo, no encode hardware |

### 5.4 Sicurezza

- Sandbox per esecuzione codice utente (Deno permissions model)
- No network access durante rendering (determinismo)
- Audit trail per asset generati da AI (prompt, modello, seed, timestamp)

---

## 6. Architettura di Sistema

### 6.1 Stack Tecnologico

| Componente | Tecnologia | Razionale |
|------------|------------|-----------|
| Core Engine | Rust + wgpu | Performance zero-cost, memory safety, ecosistema grafico maturo |
| Runtime Scripting | Deno (TypeScript) | Sandbox nativa, compatibilità moderna, no node_modules overhead |
| UI Framework | Tauri (Rust) + WebGPU canvas | Native performance, bundle size minimo, accesso hardware |
| Video Encode | FFmpeg (libavcodec) + hardware encoders | Standard industriale, supporto codec completo |
| AI Integration | Python bridge (opzionale) | Ecosistema ML, ma isolato da core performance-critical |

### 6.2 Architettura a Livelli

```
┌─────────────────────────────────────────┐
│  Layer 4: User Interfaces               │
│  - CLI (Rust)                           │
│  - Tauri Desktop App                    │
│  - VSCode Extension                     │
├─────────────────────────────────────────┤
│  Layer 3: Orchestration                 │
│  - Project Parser (skill.MD, TSX)       │
│  - Scene Graph Compiler                 │
│  - Asset Pipeline Manager               │
│  - AI Service Router (local/cloud)      │
├─────────────────────────────────────────┤
│  Layer 2: Runtime Engine                │
│  - Deno Embedded (V8 isolates)          │
│  - React-like Component System          │
│  - Animation/Interpolation Engine       │
├─────────────────────────────────────────┤
│  Layer 1: Rendering Core                │
│  - wgpu Abstraction                     │
│  - Shader Pipeline (WGSL)               │
│  - 2D Vector Rasterizer                 │
│  - Text Layout (HarfBuzz)               │
│  - Hardware Video Encode                │
├─────────────────────────────────────────┤
│  Layer 0: Platform Abstraction          │
│  - Vulkan / Metal / DirectX 12          │
│  - Windowing (winit)                    │
│  - File I/O async                       │
└─────────────────────────────────────────┘
```

### 6.3 Componenti Critici

**Rendering Core (Rust)**
- Gestione command buffer GPU
- Memory management frame buffers
- Shader hot-reloading
- Encoder hardware integration

**Scene Compiler**
- Parsing TSX/JSX senza Babel (SWC o simile)
- Static analysis per ottimizzazione
- Tree-shaking componenti non usati

**Asset Pipeline**
- DAG (Directed Acyclic Graph) per dipendenze
- Parallel download/generation
- Checksum-based caching

---

## 7. Flussi Utente

### 7.1 Onboarding Primo Utente

1. **Installazione:** `curl -fsSL https://cine.dev/install.sh | sh`
   - Auto-detect OS/architettura
   - Download binary Rust + runtime Deno
   - Verifica GPU capabilities
   - Setup PATH

2. **Verifica:** `cine doctor`
   - Check dipendenze mancanti
   - Test GPU/CPU fallback
   - Report readiness

3. **Primo Progetto:** `cine init my-video --template promo`
   - Genera skill.md con capabilities rilevate
   - Setup struttura directory
   - Link a tutorial interattivo

4. **Prima Generazione:** `cine generate --prompt "Video promo 30s per startup tech"`
   - LLM genera scene structure
   - Preview automatica in viewport
   - Iterazione conversazionale

### 7.2 Workflow Quotidiano (Alex, Developer)

```bash
# Alex lavora sul suo SaaS, vuole video per nuova feature
cd ~/my-saas-project

# Claude Code è già attivo
> @cine Crea video per il lancio della feature "Analytics Dashboard"

# Cine (via skill) esegue:
1. Legge skill.md locale
2. Analizza ./src per design system
3. Estrae copy da README e componenti
4. Genera scenes/analytics-dashboard.tsx
5. Avvia preview in finestra separata

# Alex vede preview, chiede modifiche
> Rendi la transizione più fluida, aggiungi screenshot della UI reale

# Cine aggiorna, hot-reload, Alex approva
> Renderizza in 4K per YouTube

# Output: ./dist/analytics-dashboard-4k.mp4
```

### 7.3 Workflow Batch (Video Engineer)

```bash
# Configurazione progetto batch
cine init batch-campaign --template batch

# Definizione variabili in data/products.csv
# Struttura scene parametrica: scenes/product-template.tsx

# Esecuzione parallela
cine render-batch \
  --input data/products.csv \
  --template scenes/product-template.tsx \
  --output-dir ./renders/ \
  --parallel 8 \
  --format mp4 \
  --resolution 1080p

# Monitoraggio via dashboard web (opzionale)
cine dashboard --port 8080
```

-

---

## 12. Appendici

### A. Glossario

- **skill.MD:** Standard metadata per capability discovery da LLM
- **WebGPU:** API grafica moderna, successore WebGL, accesso diretto GPU
- **Determinismo:** Proprietà per cui stesso input produce stesso output sempre
- **Hardware Encode:** Codifica video accelerata da chip dedicato (NVENC, ecc.)

### B. Riferimenti Competitivi

- Remotion: https://remotion.dev
- After Effects Expressions: Adobe automation
- FFmpeg: https://ffmpeg.org
- wgpu: https://wgpu.rs

### C. Documentazione Collegata

- Architecture Decision Records (ADR): /docs/adr/
- API Reference: /docs/api/
- skill.MD Specification: /docs/skill-spec.md

---

*Documento soggetto a revisione. Ultimo aggiornamento: 2025-02-13*