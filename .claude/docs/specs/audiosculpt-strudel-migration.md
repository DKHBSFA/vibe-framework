# Spec: Migrazione audiosculpt a Strudel

**Data:** 2026-02-03
**Stato:** Completato

---

## Obiettivo

Sostituire Tone.js con Strudel come engine audio di audiosculpt, sfruttando:
- Pattern language (mini-notation, transformazioni)
- Samples built-in (VCSL, Dirt samples, 50+ drum machines)
- FM synthesis configurabile
- Codice generato più compatto

---

## Razionale

| Aspetto | Tone.js attuale | Strudel |
|---------|-----------------|---------|
| Pattern definition | Array JSON 16 elementi + loop | `"bd sd [hh hh] cp"` |
| Variazioni | If/else, Math.random | `.every(4, rev).sometimes(fast(2))` |
| Polyrhythm | Scheduling separato | `stack(pat1, pat2)` |
| Euclidean | Da implementare | `.euclid(3,8)` built-in |
| Samples | CDN custom + fallback FM | VCSL + Dirt (1000+) built-in |
| FM Synth | 45 patch custom | `fmh()`, `fm()` configurabili |
| Drum machines | MembraneSynth/MetalSynth | TR-808, 909, LinnDrum... (50+) |

---

## Cosa si elimina

### File da rimuovere

| File | Motivo |
|------|--------|
| `presets/synth-patches.json` | Strudel ha FM configurabile + samples migliori |
| `presets/sample-map.json` | Strudel ha VCSL built-in |
| `engine/` directory | Text2midi non più necessario (opzionale, vedi sotto) |

### Sezioni SKILL.md da rimuovere

- "Samples — 2-Level Architecture" (Strudel gestisce samples)
- "Sampled Instruments" section
- "Gain Staging Guidelines" (Strudel ha compressor/limiter built-in)
- "Tone.js Code Structure" (sostituito da Strudel code structure)
- Tutte le regole "MANDATORY" su timing (Strudel le gestisce nel pattern engine)

---

## Cosa si mantiene

### Teoria musicale (invariata)

- Voice leading rules per famiglia (tonal, modal, loop, experimental)
- Functional harmony (T/SD/D, cadenze)
- Orchestration density limits
- Form types (periodo_tematico, drop_structure, processuale, atematico)
- Temporal quantization algorithm
- Time signature rules

**Queste sono istruzioni per me, non codice. Continuano ad applicarsi.**

### Preset structure (trasformata)

I 20 preset mantengono:
- `progression` (chords, scale, bars_per_chord)
- `harmonic_system` (type, functions, cadences)
- `voiceLeading` (chords con voicings pre-calcolati)
- `arc` (layers per fase, velocity)
- `orchestration_limits`
- `form`
- `temporal` (bpm, swing, timeSignature, endingBehavior)
- `transitions` (intro_to_build, build_to_climax, etc.)

Cambiano:
- `rhythmGrid` → `patterns` (Strudel mini-notation)
- `melodicPatterns` → `patterns` (Strudel mini-notation)
- `instruments` → `sounds` (riferimenti a samples/synth Strudel)

### SFX families (adattate)

Le 6 famiglie SFX mantengono la struttura ma usano samples Strudel invece di Tone.js synth.

### Coherence matrix (invariata)

- Mode → style mapping
- Style → SFX family mapping
- Feature profiles (arousal/valence)

---

## Nuovo formato preset

### Prima (jazz.json attuale)

```json
{
  "style": "jazz",
  "instruments": {
    "piano": {
      "type": "Sampler",
      "sampleMap": "piano",
      "fallbackPatch": "piano-acoustic",
      "volume": -18,
      "effects": [{ "type": "Reverb", "config": { "decay": 2.0, "wet": 0.25 } }]
    },
    "bass": {
      "type": "MonoSynth",
      "config": { "oscillator": { "type": "triangle" }, ... },
      "volume": -14
    }
  },
  "rhythmGrid": {
    "intro": {
      "ride": [0.7, 0, 0, 0.4, 0.6, 0, 0, 0.3, ...],
      "brush": [0, 0, 0.3, 0, 0, 0, 0.3, 0, ...]
    }
  },
  "melodicPatterns": {
    "bass": {
      "intro": "whole_notes",
      "build": "walking_quarter_notes"
    }
  }
}
```

### Dopo (jazz.json nuovo)

```json
{
  "style": "jazz",
  "family": "tonal",

  "sounds": {
    "piano": { "source": "piano", "room": 0.5, "gain": 0.7 },
    "bass": { "source": "bass", "lpf": 800, "gain": 0.8 },
    "ride": { "source": "jazz_ride", "room": 0.4, "gain": 0.5 },
    "brush": { "source": "brush", "hpf": 2000, "gain": 0.4 }
  },

  "patterns": {
    "intro": {
      "rhythm": "stack(s('jazz_ride').struct('t(7,16)').gain(sine.range(0.4,0.7)), s('brush').struct('~ t ~ t'))",
      "harmony": "silent",
      "bass": "note('<c2 f2 bb1 eb2>').slow(4).sound('bass')"
    },
    "build": {
      "rhythm": "stack(s('jazz_ride').struct('t(9,16)').gain(0.7), s('brush').struct('~ t ~ t').gain(0.5))",
      "harmony": "chord('<Cm7 F7 Bbmaj7 Ebmaj7>').voicing().sound('piano')",
      "bass": "note('<c2 d2 e2 f2> <f2 e2 eb2 d2> <bb1 c2 d2 f2>').sound('bass')"
    },
    "climax": {
      "rhythm": "stack(s('jazz_ride').struct('t(11,16)').gain(0.9), s('brush').fast(2).gain(0.6))",
      "harmony": "chord('<Cm7 F7 Bbmaj7 Ebmaj7>').voicing().sound('piano').gain(0.8)",
      "bass": "note('<c2 d2 e2 f2> <f2 e2 eb2 d2> <bb1 c2 d2 f2>').sound('bass').gain(0.85)"
    },
    "resolve": {
      "rhythm": "s('jazz_ride').struct('t f t f').gain(perlin.range(0.3,0.5))",
      "harmony": "chord('<Bbmaj7>').voicing().sound('piano').gain(0.4)",
      "bass": "note('bb1').slow(2).sound('bass')"
    }
  },

  "temporal": { "bpm": 120, "swing": 0.65, "timeSignature": [4, 4] },
  "progression": { "chords": ["IImaj7", "V7", "Imaj7", "IVmaj7"], "scale": "dorian" },
  "harmonic_system": { "type": "functional_tonal", "functions": { "IImaj7": "SD", "V7": "D", "Imaj7": "T" } },
  "voiceLeading": { /* invariato */ },
  "arc": { /* invariato */ },
  "form": { /* invariato */ },
  "transitions": { /* invariato */ }
}
```

### Vantaggi del nuovo formato

1. **Pattern compatti**: `t(7,16)` = euclidean 7/16, una stringa vs array 16 elementi
2. **Variazioni inline**: `.gain(sine.range(0.4,0.7))` = velocity che oscilla
3. **Chord voicing**: `.voicing()` genera voicings automatici
4. **Walking bass**: Sequenza note esplicita, leggibile

---

## Nuovo SKILL.md structure

### Sezioni da riscrivere

1. **How It Works** — Nuovo diagramma con Strudel
2. **Building the TIR** — Invariato (parsing HTML)
3. **Audio Generation: Soundtrack** — Completamente nuovo (Strudel patterns)
4. **Audio Generation: SFX** — Adattato per Strudel
5. **Strudel Code Structure** — Nuovo (sostituisce Tone.js Code Structure)
6. **Presets** — Nuovo formato documentato

### Sezioni da rimuovere

- Text2midi Engine (opzionale, può restare come alternativa)
- Samples — 2-Level Architecture
- Sampled Instruments
- Gain Staging Guidelines dettagliate (Strudel semplifica)
- Tutte le regole MANDATORY su timing

### Sezioni invariate

- Commands
- Guided Flow
- Style Selection (algorithmic)
- Stylistic Families
- Voice leading rules
- Functional Harmony
- Orchestration
- Form and Phrasing
- Temporal Quantization
- Integration with video-craft
- Audio Report (adattato per Strudel)

---

## Output generato

### Prima (Tone.js)

```html
<script src="https://unpkg.com/tone"></script>
<script>
document.addEventListener('click', async () => {
  await Tone.start();

  const compressor = new Tone.Compressor({threshold: -18, ratio: 3});
  const limiter = new Tone.Limiter(-3);
  Tone.getDestination().chain(compressor, limiter);

  const piano = new Tone.Sampler({
    urls: { "A3": "A3.ogg", "C4": "C4.ogg", ... },
    baseUrl: "https://..."
  });
  const pianoReverb = new Tone.Reverb({decay: 2.0, wet: 0.25});
  piano.chain(pianoReverb, Tone.getDestination());

  // 100+ righe di scheduling...
  Tone.Transport.schedule((t) => {
    piano.triggerAttackRelease("C4", "4n", t, 0.7);
  }, 0);
  // ...

  Tone.Transport.bpm.value = 120;
  Tone.Transport.start();
}, { once: true });
</script>
```

### Dopo (Strudel)

```html
<script src="https://unpkg.com/@strudel/web"></script>
<script>
document.addEventListener('click', async () => {
  const { repl } = await import('https://unpkg.com/@strudel/web');

  const patterns = {
    intro: `stack(
      s('jazz_ride').struct('t(7,16)').room(0.4).gain(sine.range(0.4,0.7)),
      s('brush').struct('~ t ~ t').hpf(2000),
      note('<c2 f2 bb1 eb2>').slow(4).sound('bass').lpf(800)
    )`,
    build: `stack(
      s('jazz_ride').struct('t(9,16)').room(0.4).gain(0.7),
      s('brush').struct('~ t ~ t').gain(0.5),
      chord('<Cm7 F7 Bbmaj7>').voicing().sound('piano').room(0.5),
      note('<c2 d2 e2 f2>').sound('bass')
    )`,
    // ...
  };

  await repl({
    defaultOutput: webAudioOutput,
    code: patterns.intro,
    cps: 120/60/4  // BPM to cycles per second
  }).start();
}, { once: true });
</script>
```

**Riduzione codice: ~70%**

---

## Piano di migrazione

### Fase 1: Setup Strudel

1. Verificare CDN Strudel e API per uso embedded (non REPL)
2. Creare template base per output HTML
3. Testare pattern semplice end-to-end

### Fase 2: Convertire preset

Per ogni preset (20 totali):
1. Convertire `rhythmGrid` → pattern Strudel
2. Convertire `melodicPatterns` → pattern Strudel
3. Mappare `instruments` → `sounds` Strudel
4. Testare ogni fase (intro/build/climax/resolve)
5. Validare transizioni

Ordine suggerito:
1. `electronic` (semplice, drum machine)
2. `minimal-techno` (pattern ripetitivi)
3. `trap`, `dnb` (drum-focused)
4. `ambient`, `chillwave` (pad-focused)
5. `jazz`, `neo-classical` (complessi, per ultimi)

### Fase 3: Riscrivere SKILL.md

1. Nuovo diagramma "How It Works"
2. Documentare pattern syntax
3. Documentare sounds disponibili
4. Aggiornare Audio Generation sections
5. Rimuovere sezioni obsolete

### Fase 4: Adattare SFX

1. Mappare SFX families a samples Strudel
2. Testare sync con TIR
3. Verificare ducking

### Fase 5: Cleanup

1. Rimuovere `synth-patches.json`
2. Rimuovere `sample-map.json`
3. Decidere se mantenere `engine/` (Text2midi) come opzione avanzata
4. Aggiornare registry

---

## File toccati

| File | Azione |
|------|--------|
| `.claude/skills/audiosculpt/SKILL.md` | Riscrittura maggiore |
| `.claude/skills/audiosculpt/presets/soundtrack/*.json` | Conversione formato (20 file) |
| `.claude/skills/audiosculpt/presets/sfx/*.json` | Adattamento (6 file) |
| `.claude/skills/audiosculpt/presets/synth-patches.json` | Eliminazione |
| `.claude/skills/audiosculpt/presets/sample-map.json` | Eliminazione |
| `.claude/skills/audiosculpt/presets/coherence-matrix.json` | Aggiornamento minore |
| `.claude/docs/registry.md` | Aggiornamento |

---

## Rischi

| Rischio | Mitigazione |
|---------|-------------|
| Strudel API non stabile per uso embedded | Verificare in Fase 1 prima di procedere |
| Pattern complessi difficili da debuggare | Testare ogni preset fase per fase |
| Samples Strudel mancanti per alcuni timbri | Usare FM synthesis configurabile |
| Breaking change in CDN Strudel | Pinning versione specifica |

---

## Verifica completamento

- [x] Tutti i 20 preset convertiti e funzionanti
- [x] SFX sync con TIR verificato (6 preset adattati)
- [x] Output HTML < 50 righe di codice (vs 150+ attuali)
- [x] Audio Report funzionante con Strudel
- [x] SKILL.md aggiornato e completo
- [x] File obsoleti rimossi (sample-map.json, synth-patches.json)
- [x] Registry aggiornato

---

**Migrazione completata il 2026-02-03.**
