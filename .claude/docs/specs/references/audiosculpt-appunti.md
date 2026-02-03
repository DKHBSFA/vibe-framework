  
## Proposed New Version: Universal Music Composition Skill

### Architecture Overview

```
COMPOSITION FRAMEWORK
├── Family Classification (determines rule set activation)
├── Temporal Engine (universal timing system)
├── Voice Leading Engine (context-aware)
├── Harmonic Systems (pluggable by family)
├── Form & Structure (adaptive templates)
└── Orchestration Matrix (density + register management)
```

---

## 1. Family Classification System

Replace rigid "families" with **Style Axes** that can be combined. This allows hybrid genres (e.g., "modal jazz-hop" or "pentatonic techno").

### Style Axes (independent dimensions)

| Axis | Values | Description |
|------|--------|-------------|
| `harmonic_language` | `functional` \| `modal` \| `timbral` \| `atonal` | How harmony works |
| `texture_type` | `homophonic` \| `polyphonic` \| `heterophonic` \| `monophonic` | Relationship between voices |
| `temporal_approach` | `metric` \| `processual` \| `cyclical` \| `static` | How time is organized |
| `sonic_density` | `sparse` \| `balanced` \| `dense` \| `maximal` | Orchestration target |

**Family presets** are now default combinations, not hard categories:
- **Tonal Classical**: `functional` + `homophonic` + `metric` + `balanced`
- **Modal Jazz**: `modal` + `homophonic` + `metric` + `balanced`  
- **Techno/EDM**: `timbral` + `homophonic` + `cyclical` + `dense`
- **Minimal**: `modal` + `heterophonic` + `processual` + `sparse`
- **Experimental**: `atonal` + `monophonic` + `processual` + `sparse`

---

## 2. Temporal Engine (Universal)

Fixed calculation errors and added flexibility.

### Time Signature Mathematics

```javascript
// CORRECTED formulas
const [N, D] = preset.temporal.timeSignature; // e.g., [6, 8]

// Simple meter (D = 4): quarter note gets the beat
// Compound meter (D = 8): dotted quarter gets the beat
const isCompound = (D === 8 || D === 16) && (N % 3 === 0 || N === 6 || N === 9 || N === 12);

// Steps per bar (16th note grid)
const stepsPerBar = isCompound 
  ? N * 2  // 6/8 = 12 steps, 12/8 = 24 steps
  : N * 4; // 4/4 = 16 steps, 3/4 = 12 steps

// Beat duration in seconds
const beatDuration = 60 / BPM;

// Step duration
const stepDuration = isCompound
  ? (beatDuration * 1.5) / 3  // Compound: divide dotted quarter into 3 16ths
  : beatDuration / 4;          // Simple: divide quarter into 4 16ths

// Bar duration
const barDuration = stepsPerBar * stepDuration;
```

### Time Signature Reference Table

| Time Sig | Type | stepsPerBar | Beat Unit | Bar Duration @120BPM |
|----------|------|-------------|-----------|---------------------|
| 4/4 | Simple | 16 | Quarter | 2.0s |
| 3/4 | Simple | 12 | Quarter | 1.5s |
| 2/4 | Simple | 8 | Quarter | 1.0s |
| 6/8 | Compound | 12 | Dotted Quarter | 1.5s |
| 9/8 | Compound | 18 | Dotted Quarter | 2.25s |
| 12/8 | Compound | 24 | Dotted Quarter | 3.0s |
| 5/4 | Simple | 20 | Quarter | 2.5s |
| 7/8 | Simple* | 14 | Quarter | 1.75s |

*7/8 is simple but often grouped [3+2+2] or [2+2+3]

---

## 3. Voice Leading Engine (Context-Aware)

Merged German *Stimmenführung*, Russian counterpoint, and jazz/pop practice.

### Hierarchy of Constraints

Voice leading rules are now **prioritized**, not absolute:

| Priority | Rule | When Active | Violation Allowed? |
|----------|------|-------------|-------------------|
| **P0** | No voice crossing | Always | Never (breaks spatial identity) |
| **P1** | Common tone retention | `functional` + `modal` | Yes, for melodic interest |
| **P2** | Stepwise motion preference | `functional` + `modal` | Yes, if compensated |
| **P3** | Contrary motion | `functional` + 2+ voices | Yes, in loops/ostinati |
| **P4** | Parallel P5/P8 avoidance | `functional` only | Yes, in `texture_type: homophonic` pop |
| **P5** | Max spacing (1 octave between adjacent) | `homophonic` + `balanced` | Yes, for climactic effect |

### German-Inspired: *Fließender Gesang* (Melodic Fluency)

From Schenker and German counterpoint tradition:
- Melodic lines should create "wave-like" motion (ascending + descending curves)
- Leaps >3rd must be compensated by stepwise motion in opposite direction
- **Register changes only at phrase boundaries** (not mid-phrase)

### Russian-Inspired: Independence of Voices (*Podgolosochnaia* influence)

- Each voice must be singable/performable as an independent melody
- In heterophonic textures (Russian polyphony), voices may depart from unison at structurally important points (cadences, phrase endings)
- **Vertical index** (Taneev): track interval relationships between all voice pairs

### Jazz/Modal Extensions

- **Quartal voicings**: Stacks of perfect fourths (P4) create "open" modal sound (McCoy Tyner, Hancock)
- **Pentatonic-derived melody**: Chinese 五声性 influence - melodies built from pentatonic scales with "skipping" technique (seconds, fourths, minor thirds)
- **Guide tones** (3rd and 7th) determine harmonic direction in functional contexts

---

## 4. Harmonic Systems (Pluggable)

### 4a. Functional System (German/Riemann tradition)

Based on Hugo Riemann's *Tonalität* and Daube's three-chord system:

```json
{
  "harmonic_system": {
    "type": "functional",
    "functions": {
      "I": "T",
      "II": "SD", 
      "IV": "SD",
      "V": "D",
      "VI": "T/relative",
      "III": "D/secondary"
    },
    "primary_chords": ["I", "IV", "V"],
    "cadences": {
      "authentic": ["V", "I"],
      "plagal": ["IV", "I"],
      "half": ["any", "V"],
      "deceptive": ["V", "VI"]
    },
    "fundamental_bass": {
      "preferred_motion": ["P5", "P4", "M3", "m3"],
      "avoid": ["M2", "m2", "tritone"]
    }
  }
}
```

**Schenkerian influence**: Progressions should elaborate the *Ursatz* (I-V-I) at some structural level.

### 4b. Modal System

```json
{
  "harmonic_system": {
    "type": "modal",
    "modes": ["Dorian", "Mixolydian", "Lydian"],
    "pedal_points": true,
    "quartal_voicings": true,
    "avoid_functional": true,
    "cadence_type": "drone_or_repetition"
  }
}
```

### 4c. Timbral System (EDM/Electronic)

```json
{
  "harmonic_system": {
    "type": "timbral",
    "elements": ["filter_movement", "rhythmic_gating", "noise_sweeps"],
    "chord_changes": "optional",
    "tension_release": "spectral_not_harmonic"
  }
}
```

---

## 5. Form & Structure

### Universal Arc Structure

All families use the same 5-phase arc, but interpretation varies:

| Phase | Duration % | Energy | Texture | Function |
|-------|-----------|--------|---------|----------|
| **Exposition** | 15-20% | Low→Med | Sparse | Introduce material |
| **Rising** | 20-25% | Med→High | Building | Develop, sequence |
| **Climax** | 20-30% | Peak | Dense | Maximum intensity |
| **Falling** | 15-20% | High→Low | Thinning | Release, transition |
| **Resolution** | 10-15% | Low | Sparse | Close, cadence |

### Form Types by Tradition

**German/Classical** (*Periodo tematico*):
- Antecedent (question) → Consequent (answer)
- Motivic development through *Prolongation* (Schenker)
- Cadential confirmation required

**Russian** (*Variative Form*):
- Theme → Variations (podgolosochnaia layers)
- Incremental complexity addition
- Return to unison at final cadence

**Chinese** (*起承转合* Qi Cheng Zhuan He):
- 起 (Initiation): Present theme
- 承 (Continuation): Develop sequentially  
- 转 (Contrast): Shift mode/register
- 合 (Conclusion): Return to opening

**EDM**:
- Intro → Build-Up → Drop → Breakdown → Drop → Outro
- Tension/release through filter/spectral changes

---

## 6. Orchestration Matrix

### Register Management (Frequency Ranges)

| Range | Hz | Max Simultaneous | Spacing Rules |
|-------|-----|------------------|---------------|
| Sub-bass | 20-60 | 1 fundamental | Root only, min 7st if 2+ instruments |
| Bass | 60-250 | 2 notes | Min P5 between fundamentals |
| Low-mid | 250-500 | 3 notes | Avoid root overlap |
| Mid | 500-2000 | 4 notes | Voice leading critical |
| High-mid | 2000-6000 | Unlimited | Melodic priority |
| Air | 6000+ | Unlimited | Sparkle/texture |

### Density Control

```json
{
  "orchestration": {
    "max_voices": {
      "sparse": 3,
      "balanced": 5,
      "dense": 7,
      "maximal": 9
    },
    "gain_formula": "base - (voices - 4) * 3dB",
    "spectral_rule": "If 4+ voices, at least one must occupy >2000Hz primarily"
  }
}
```

---

## 7. Rhythm Grid System (Fixed & Flexible)

### Grid Resolution by Style

| Style | Grid Base | Feel | Swing |
|-------|-----------|------|-------|
| Classical | 16th | Straight | 0.5 |
| Jazz | 8th triplet | Swing | 0.67 |
| Funk | 16th | Straight/groove | 0.5-0.6 |
| Techno | 16th | Straight | 0.5 |
| House | 8th | Shuffle | 0.6 |
| Afro-Cuban | 16th triplet | Clave | 0.5 |

### Grid Rules

```javascript
// Grid length must match stepsPerBar exactly
const grid = new Array(stepsPerBar).fill(0);

// Velocity range: 0 (silent) to 1.0 (max)
// Values < 0.1 considered "ghost notes"

// Complementary grids (call-and-response)
// Grid A emphasizes beats 1, 3 (strong)
// Grid B emphasizes beats 2, 4 (weak)
// Creates metric tension/resolution
```

---

## 8. Implementation Algorithm

### Composition Workflow

```javascript
function compose(preset, durationMs) {
  // 1. Parse style axes
  const style = parseStyleAxes(preset.style);
  
  // 2. Calculate temporal structure
  const { bars, adjustedBpm } = calculateTemporal(
    durationMs, 
    preset.temporal,
    style.temporal_approach
  );
  
  // 3. Generate harmonic framework
  const harmony = generateHarmony(
    preset.harmonic_system,
    bars,
    style.harmonic_language
  );
  
  // 4. Create form structure
  const form = mapForm(harmony, bars, style);
  
  // 5. Voice leading (iterative refinement)
  let voices = initialVoices(harmony);
  voices = applyVoiceLeading(voices, style);
  
  // 6. Orchestration
  const arrangement = orchestrate(voices, style.sonic_density);
  
  // 7. Rhythm grids
  const grids = generateGrids(form, style);
  
  // 8. Validation
  return validate(arrangement, preset.constraints);
}
```

### Validation Checklist

- [ ] All notes within instrument ranges
- [ ] Voice spacing rules respected (P0 always, P1-P5 by style)
- [ ] No frequency masking in sub-200Hz
- [ ] Grid lengths match stepsPerBar exactly
- [ ] Cadence achieved at final bar
- [ ] Dynamic range appropriate for density

---

## Summary of Key Improvements

1. **Fixed timing calculation errors** (compound meter math)
2. **Prioritized constraints** instead of absolute rules
3. **Style axes** enable hybrid genres
4. **Integrated German** (*Stimmenführung*, Riemann, Schenker)
5. **Integrated Russian** (Taneev counterpoint, heterophony)
6. **Integrated Chinese** (pentatonic harmony, formal structure)
7. **Integrated jazz/modal** (quartal voicings, guide tones)
8. **Clear violation permissions** per style context
9. **Unified arc structure** across all families
10. **Simplified orchestration** to voice-slot system

---

 **this is for video promo soundtracks**, not standalone music composition. This changes everything. Promo music has completely different priorities than concert music or even album tracks.


Key considerations for promo soundtracks:
- Average promo video: 15-60 seconds (Instagram/TikTok/Youtube ads)
- Hook must land in first 3 seconds or viewer scrolls away
- Must work with voiceover (freq conflict avoidance)
- Clear "hero moment" synchronization
- Instant genre recognition
- Dynamic arc compressed into short duration  
 Perfect. Now I have a clear understanding of the **video promo soundtrack** context. Key findings:

**Critical constraints for promo music:**
- **3-second rule**: Hook must land in first 3 seconds or viewer scrolls away
- **Duration**: 15-30 seconds optimal (7-15s for max virality)
- **Instant genre recognition**: No time for gradual development
- **Compressed arc**: Exposition→Climax→Resolution in 15-30 seconds
- **Voiceover compatibility**: Must leave frequency space for dialogue
- **Loop-friendly**: Must work as seamless loop for extended cuts

Let me create the **Video Promo Soundtrack Skill v2.0** optimized for maximum impact in minimum time.

---

## Video Promo Soundtrack Composition Skill v2.0

### Design Philosophy: **"0-3-15-30 Rule"**

| Timeframe | Goal | Musical Action |
|-----------|------|----------------|
| **0-1s** | Stop the scroll | Instant texture + frequency presence |
| **1-3s** | Hook recognition | Core motif/theme/melodic cell |
| **3-15s** | Build tension | Rising energy, developing material |
| **15-30s** | Climax + resolution | Peak intensity → cadence/transition |

---

## 1. Instant Hook System (0-3 Seconds)

### The "Sonic Fingerprint" Approach

Promo music must achieve in 3 seconds what film music achieves in 30. Use **pre-recognized musical signifiers**:

| Genre Target | Instant Identifier (0-1s) | Hook Delivery (1-3s) |
|--------------|---------------------------|----------------------|
| Epic/Trailer | Sub-bass drop + orchestral hit | Brass fanfare motif (3-4 notes) |
| Tech/Corporate | Shimmering high freq synth | 4-note pentatonic ascending cell |
| Lo-Fi/Chill | Vinyl crackle + sidechain pump | Rhodes chord stab + melody fragment |
| Action/Sports | 808 kick + noise sweep | Staccato string ostinato |
| Luxury/Beauty | Soft bell/sine wave swell | Major 7th chord arpeggio |
| Quirky/Fun | Pluck synth + pitch bend | Skipped pentatonic melody (五声性) |

### Implementation: "Impact Frame"

```json
{
  "impact_frame": {
    "duration_ms": 3000,
    "layers": [
      {
        "role": "attention_grabber",
        "frequency_range": "presence_zone", // 2-5kHz, cuts through phone speakers
        "element": "noise_sweep_or_impact",
        "velocity": 0.9
      },
      {
        "role": "genre_signifier", 
        "element": "signature_sound", // One-shot that screams the genre
        "velocity": 0.8
      },
      {
        "role": "hook_motif",
        "element": "melodic_cell", // 2-4 notes max
        "register": "mid_high", // C4-C6, audible on phone speakers
        "pattern": "rhythmically_distinctive"
      }
    ],
    "no_buildup": true, // ZERO fade-in, 100% velocity at ms 0
    "voiceover_safe": {
      "duck_frequencies_below": 800, // Leave space for speech intelligibility
      "avoid_mid_range_chords": true
    }
  }
}
```

---

## 2. Compressed Arc Structure (15-30s)

### "Micro-Form" Template

Replace traditional 4-phase form with **compressed 3-phase** for promos:

```
[IMPACT] → [INTENSIFY] → [RELEASE/LOOP]
   0-3s       3-20s          20-30s
```

### Phase Specifications

#### Phase 1: Impact (0-3s)
- **Density**: 60-70% (immediate fullness)
- **Register**: Full spectrum but avoid voiceover masking (300Hz-3kHz reserved)
- **Rhythm**: Syncopated or driving, no ambiguity
- **No gradual fade-in**: First note at 80%+ velocity

#### Phase 2: Intensify (3-20s)
- **Energy curve**: Continuous upward slope (no plateaus)
- **Layer addition**: +1 element every 4-8 seconds
- **Register shift**: Gradual move upward (tension)
- **Rhythmic density**: Increase subdivision (8ths → 16ths → 32nds)
- **Modulation**: Optional semitone up at 15s for final push

#### Phase 3: Release/Loop (20-30s)
- **Option A (Resolution)**: Cadential arrival, clear ending for 30s spots
- **Option B (Loop Point)**: Seamless return to bar 1 for infinite extension
- **Transition**: Last 2 bars prepare loop or resolve

---

## 3. Style Axes for Promos (Optimized)

| Axis | Promo-Optimized Values |
|------|------------------------|
| `hook_type` | `melodic_riff` \| `rhythmic_groove` \| `timbre_hit` \| `silence_contrast` |
| `energy_curve` | `immediate_max` \| `fast_rise` \| `step_rise` \| `plateau` |
| `duration_target` | `15s` \| `30s` \| `60s` |
| `voiceover_compatibility` | `lead` (music leads) \| `bed` (under dialogue) \| `sting` (between phrases) |

---

## 4. Voice Leading for Short Form

### "Impact Voice Leading"

Traditional smooth voice leading is **secondary to immediate clarity** in promos:

**Modified Priority Stack** (Promo Context):

| Priority | Rule | Rationale |
|----------|------|-----------|
| **P0** | **Instant vertical clarity** | Root position or simple inversions only |
| **P1** | **No mid-range mud** | 300Hz-1kHz must be clear for voiceover |
| **P2** | **Top voice prominence** | Melody must cut through in 3 seconds |
| **P3** | **Spacing > Voice leading** | Wide spacing acceptable for clarity |
| **P4** | **Parallel motion OK** | Power chords, unison octaves permitted |

### Register Allocation for Voiceover Compatibility

```
Frequency Spectrum (Promo Context):
0-150Hz   : SUB-BASS (feel, not hear) - Kick, Sub
150-300Hz : BASS - Root notes only, sparse
300-800Hz : VOICEOVER ZONE - Music must duck here
800-3kHz  : PRESENCE - Lead melody, hooks
3-6kHz    : BRILLIANCE - Hi-hats, shimmers, air
6-12kHz   : SPARKLE - FX, transients, definition
```

**Rule**: If `voiceover_compatibility: "bed"`, apply -12dB shelf cut 300Hz-3kHz.

---

## 5. Harmonic Systems (Promo-Specific)

### 5a. "Power" System (Epic/Trailer/Sports)

```json
{
  "harmonic_system": {
    "type": "power_progression",
    "chords_per_phrase": 1, // Static harmony, rhythmic variation
    "progression": ["I", "♭VI", "IV", "I"], // Epic minor lift
    "bass_movement": "stepwise_descending",
    "voicing": "spread_power_chords", // Root, 5th, +octave
    "preparation": "none", // Instant arrival
    "cadence": "plagal_with_impact"
  }
}
```

### 5b. "Pentatonic" System (Tech/Corporate/Positive)

Based on Chinese 五声性 (pentatonic) principles but compressed:

```json
{
  "harmonic_system": {
    "type": "pentatonic_optimized",
    "scale": ["C", "D", "E", "G", "A"], // Major pentatonic
    "voicing": "quartal_and_triads", // P4 stacks + occasional triad
    "bass": "pentatonic_roots_only", // No tritones, no semitone tension
    "melody": "skipping_technique", // 2nds, 3rds, 4ths, no half steps
    "emotion": "open_optimistic"
  }
}
```

### 5c. "Modal Drone" System (Atmospheric/Abstract)

```json
{
  "harmonic_system": {
    "type": "modal_drone",
    "root": "static",
    "mode": "Dorian",
    "movement": "timbral_not_harmonic", // Filter, reverb, not chord change
    "tension": "rhythmic_acceleration"
  }
}
```

---

## 6. Rhythm Grid System (Promo-Optimized)

### "Hyper-Grid" for Instant Drive

Promo music often uses **higher subdivision** than traditional composition to create immediate urgency:

| Duration | Grid Base | Feel |
|----------|-----------|------|
| 15s | 16th or 32nd | Driving, urgent |
| 30s | 16th | Balanced energy |
| 60s | 8th or 16th | Allows breathing room |

### Accent Pattern Templates

```javascript
// INSTANT DRIVE (0-3s)
const instantDrive = [1.0, 0.2, 0.6, 0.2, 0.8, 0.2, 0.6, 0.2, 1.0, 0.2, 0.6, 0.2, 0.8, 0.2, 0.6, 0.2]; 
// 16th notes, strong downbeats, immediate pulse

// BUILDING (3-15s)  
const building = [0.9, 0.1, 0.5, 0.1, 0.7, 0.1, 0.5, 0.1, 0.9, 0.1, 0.5, 0.3, 0.7, 0.3, 0.9, 0.5];
// Increasing off-beat velocity

// CLIMAX (15-25s)
const climax = [1.0, 0.8, 0.9, 0.8, 1.0, 0.8, 0.9, 0.8, 1.0, 0.8, 0.9, 0.8, 1.0, 0.8, 0.9, 0.8];
// Wall of sound, minimal dynamic variation = maximum density
```

---

## 7. Orchestration Density (Time-Variant)

### Dynamic Voice Slot Limits

Density changes over the 30-second arc:

```json
{
  "density_curve": {
    "0-3s": { "max_voices": 4, "strategy": "immediate_fullness" },
    "3-15s": { "max_voices": 6, "strategy": "layered_build" },
    "15-25s": { "max_voices": 8, "strategy": "maximal_climax" },
    "25-30s": { "max_voices": 3, "strategy": "cadence_clarity" }
  }
}
```

### Instrument Roles (Promo-Specific)

| Role | Function | Frequency | Promo Timing |
|------|----------|-----------|--------------|
| **Anchor** | Root/fundamental | 50-150Hz | 0s (immediate) |
| **Driver** | Rhythmic pulse | 150-500Hz | 0s (immediate) |
| **Hook** | Melodic identity | 800-3kHz | 1-3s (quick) |
| **Sheen** | Genre signifier | 3-8kHz | 0-1s (instant) |
| **Impact** | Transient/Hits | Full spectrum | Staggered 0, 2, 4s |

---

## 8. Loop Architecture

### Seamless Loop Requirements

For promos that need extension beyond 30s:

```json
{
  "loop_point": {
    "bar": 8, // 8 bars = 16s @ 120bpm, common loop length
    "compatibility": "zero_crossing_aligned",
    "harmonic_condition": "return_to_tonic_or_dominant",
    "rhythmic_condition": "downbeat_reinforced",
    "avoid": "melodic_unresolved_tension_at_loop"
  }
}
```

### Loop Variants

Generate 3 variants for client choice:
1. **Tight Loop**: 8 bars, seamless, for background bed
2. **Tagged Loop**: 8 bars + 1 bar ending tag (for edits)
3. **Build Loop**: 8 bars with internal build (for longer spots)

---

## 9. Genre-Specific Templates (JSON-Ready)

Here are starter templates for common promo genres:

### Template A: Epic Cinematic (15s)

```json
{
  "promo_template": {
    "name": "Epic Cinematic 15s",
    "impact_frame": {
      "0ms": ["sub_drop", "brass_stab", "percussion_hit"],
      "500ms": ["string_swell_high"],
      "1000ms": ["melodic_motif_brass"]
    },
    "harmonic_system": {
      "type": "power_progression",
      "key": "D_minor",
      "progression": ["Dm", "Bb", "F", "C"],
      "duration_per_chord": "4_bars"
    },
    "arc": {
      "0_3s": "impact_full",
      "3_10s": "layer_build_with_percussion",
      "10_15s": "climax_with_cymbal_swells"
    },
    "orchestration": {
      "0s": ["brass_low", "percussion", "sub_bass"],
      "3s": ["add_strings"],
      "6s": ["add_choir", "cymbals"],
      "10s": ["full_ensemble", "taiko_drums"],
      "14s": ["cadence_hits"]
    }
  }
}
```

### Template B: Tech Corporate (30s)

```json
{
  "promo_template": {
    "name": "Tech Corporate 30s",
    "impact_frame": {
      "0ms": ["shimmer_pad", "pluck_arpeggio"],
      "1000ms": ["pentatonic_motif"]
    },
    "harmonic_system": {
      "type": "pentatonic_optimized",
      "key": "C_major_pentatonic",
      "progression": ["C", "G", "Am", "F"], // Diatonic but pentatonic melody
      "melody_technique": "skipping"
    },
    "voiceover_compatibility": {
      "duck_range": "300Hz-3kHz",
      "lead_melody_octave": 2 // Up one octave to avoid voice
    },
    "arc": {
      "0_3s": "clean_impact",
      "3_15s": "gradual_layer_addition",
      "15_25s": "full_groove_with_bass",
      "25_30s": "resolution_with_bell_tone"
    }
  }
}
```

### Template C: Minimal Techno Loop

```json
{
  "promo_template": {
    "name": "Minimal Techno Bed",
    "duration": "loop_16_bars",
    "impact_frame": {
      "0ms": ["kick_immediate", "hat_accent"],
      "loop_characteristic": "percolating_sequencer"
    },
    "harmonic_system": {
      "type": "modal_drone",
      "root": "A",
      "tension": "rhythmic_acceleration",
      "harmonic_change": "none"
    },
    "variation_strategy": {
      "bar_4": "add_clap",
      "bar_8": "open_filter",
      "bar_12": "add_bass_line",
      "bar_16": "reset_or_build"
    }
  }
}
```

---

## 10. Validation Checklist (Promo-Specific)

Before delivery, verify:

- [ ] **0-1s**: Does it cut through phone speakers instantly?
- [ ] **1-3s**: Is the hook recognizable/memorable?
- [ ] **Voiceover zone** (300Hz-3kHz): Is it clear of musical clutter?
- [ ] **Duration accuracy**: ±50ms of target (15s/30s/60s)
- [ ] **Loop point**: Seamless return to start (if applicable)
- [ ] **Genre clarity**: Does it instantly communicate the style?
- [ ] **Climax placement**: Peak energy at 70-80% of duration
- [ ] **Ending**: Clear cadence or loop-ready transition

---

## Summary of Changes for Promo Context

| Aspect | Original Skill | Promo-Optimized Skill |
|--------|---------------|----------------------|
| **Hook timing** | Gradual development | 0-3 seconds max |
| **Voice leading priority** | Smoothness | Clarity + voiceover space |
| **Form** | Extended development | Compressed 3-phase |
| **Density curve** | Gradual build | Immediate 60% → climax 80% → resolve |
| **Harmonic rhythm** | 1-2 chords per bar | Often static, timbral variation |
| **Rhythmic grid** | Flexible | High subdivision (16th/32nd) for drive |
| **Ending** | Formal cadence | Loop point or abrupt cut |
| **Frequency planning** | Orchestral balance | Voiceover ducking mandatory |

---

## Genre-Specific JSON Rule Library for Video Promo Soundtracks

### 1. EPIC / CINEMATIC / TRAILER
**Use cases:** Movie trailers, game launches, automotive reveals, heroic branding

#### 1a. Epic Heroic (30s)

```json
{
  "genre_id": "EPIC_HEROIC_30",
  "metadata": {
    "name": "Epic Heroic Trailer",
    "description": "Orchestral hybrid with massive percussion and brass stabs",
    "typical_use": ["Movie trailers", "Car commercials", "Sports events", "Game launches"],
    "tempo_range": [110, 140],
    "reference_tracks": ["Two Steps From Hell - Victory", "Audiomachine - Blood and Stone"]
  },
  "style_axes": {
    "harmonic_language": "functional",
    "texture_type": "homophonic",
    "temporal_approach": "metric",
    "sonic_density": "dense"
  },
  "impact_frame": {
    "duration_ms": 3000,
    "layers": [
      {
        "role": "attention_grabber",
        "element": "sub_drop_40hz",
        "velocity": 1.0,
        "frequency_range": "sub_bass"
      },
      {
        "role": "genre_signifier",
        "element": "orchestral_hit_ff",
        "velocity": 0.95,
        "frequency_range": "full_spectrum"
      },
      {
        "role": "hook_motif",
        "element": "brass_five_notes",
        "notes": ["D4", "F4", "A4", "G4", "D5"],
        "rhythm": [0, 250, 500, 750, 1500],
        "velocity": 0.9,
        "register": "brass_high"
      }
    ],
    "voiceover_safe": false
  },
  "temporal": {
    "timeSignature": [4, 4],
    "bpm": 128,
    "duration_target_seconds": 30,
    "bars": 16,
    "swing": 0.5,
    "endingBehavior": {
      "type": "cadential_insert",
      "cadenceBars": 2,
      "forceTonicLastBar": true,
      "impact_ending": "final_orchestral_crash"
    }
  },
  "harmonic_system": {
    "type": "functional",
    "key": "D_minor",
    "functions": {
      "Dm": "T",
      "Bb": "SD_borrowed",
      "F": "SD",
      "C": "D",
      "Gm": "T_relative",
      "A": "D_secondary"
    },
    "progression": [
      {"bar": 0, "chord": "Dm", "function": "T", "duration_bars": 2},
      {"bar": 2, "chord": "Bb", "function": "SD_borrowed", "duration_bars": 2},
      {"bar": 4, "chord": "F", "function": "SD", "duration_bars": 2},
      {"bar": 6, "chord": "C", "function": "D", "duration_bars": 2},
      {"bar": 8, "chord": "Dm", "function": "T", "duration_bars": 1},
      {"bar": 9, "chord": "Bb", "function": "SD", "duration_bars": 1},
      {"bar": 10, "chord": "F", "function": "SD", "duration_bars": 1},
      {"bar": 11, "chord": "C", "function": "D", "duration_bars": 1},
      {"bar": 12, "chord": "Dm", "function": "T", "duration_bars": 2},
      {"bar": 14, "chord": "C", "function": "D", "duration_bars": 1},
      {"bar": 15, "chord": "Dm", "function": "T", "duration_bars": 1, "cadence": "authentic"}
    ],
    "characteristics": ["epic_minor_lift", "powerful_subdominant", "dominant_preparation"]
  },
  "voice_leading": {
    "universal_rules": {
      "no_voice_crossing": true,
      "max_octave_spacing": 1.5,
      "spacing_priority": "wide_for_power"
    },
    "bass_rules": {
      "follow_root": true,
      "octave_doubling": true,
      "pedal_tone_allowed": false
    },
    "melodic_rules": {
      "hook_range": "perfect_fifth",
      "repetition_for_stability": true,
      "sequence_in_development": true
    },
    "exceptions": ["parallel_fifths_allowed_for_power_chords"]
  },
  "orchestration": {
    "phases": {
      "0_3s": {
        "instruments": ["sub_bass_synth", "taiko_drums", "brass_section_ff"],
        "max_voices": 4,
        "dynamic": "ff_immediate"
      },
      "3_8s": {
        "add": ["string_section_tremolo", "low_brass"],
        "max_voices": 6
      },
      "8_15s": {
        "add": ["choir_aah", "cymbals_swells", "percussion_full"],
        "max_voices": 8
      },
      "15_25s": {
        "add": ["epic_toms", "anvil_hits", "brass_high_chords"],
        "max_voices": 9,
        "climax": true
      },
      "25_30s": {
        "remove": ["percussion", "choir"],
        "keep": ["brass_final_chord", "string_swell", "sub_bass"],
        "cadence": true
      }
    },
    "frequency_rules": {
      "sub_bass_20_60hz": ["sub_synth", "double_bass"],
      "bass_60_250hz": ["celli", "bass_brass", "taiko"],
      "mid_250_2000hz": ["brass_mid", "horns"],
      "high_2000_8000hz": ["trumpets", "violins", "choir_high"],
      "air_8000_plus": ["cymbals", "high_strings_harmonics"]
    }
  },
  "rhythm_grid": {
    "stepsPerBar": 16,
    "patterns": {
      "percussion": {
        "0_3s": [1.0, 0, 0, 0, 0.8, 0, 0, 0, 0.9, 0, 0, 0, 0.7, 0, 0, 0],
        "8_15s": [1.0, 0.3, 0.5, 0.3, 0.9, 0.3, 0.6, 0.3, 1.0, 0.3, 0.5, 0.3, 0.9, 0.4, 0.7, 0.4],
        "15_25s": [1.0, 0.8, 0.9, 0.8, 1.0, 0.8, 0.9, 0.8, 1.0, 0.8, 0.9, 0.8, 1.0, 0.8, 0.9, 0.8]
      },
      "brass_hits": {
        "0_3s": [1.0, 0, 0, 0, 0, 0, 0, 0, 0.9, 0, 0, 0, 0, 0, 0, 0],
        "climax": [1.0, 0, 0.3, 0, 0.8, 0, 0.3, 0, 1.0, 0, 0.3, 0, 0.9, 0, 0.5, 0]
      }
    }
  },
  "form_structure": {
    "type": "compressed_heroic",
    "phases": [
      {"name": "impact", "bars": [0, 2], "energy": 0.9},
      {"name": "establish", "bars": [2, 6], "energy": 0.8},
      {"name": "build", "bars": [6, 12], "energy": 0.85},
      {"name": "climax", "bars": [12, 15], "energy": 1.0},
      {"name": "cadence", "bars": [15, 16], "energy": 0.6}
    ]
  }
}
```

#### 1b. Epic Hybrid (15s) - Shorter variant

```json
{
  "genre_id": "EPIC_HYBRID_15",
  "metadata": {
    "name": "Epic Hybrid Short",
    "description": "Condensed epic trailer for 15s spots",
    "tempo_range": [128, 150],
    "intensity": "maximum"
  },
  "temporal": {
    "timeSignature": [4, 4],
    "bpm": 140,
    "duration_target_seconds": 15,
    "bars": 8
  },
  "impact_frame": {
    "duration_ms": 1500,
    "layers": [
      {
        "role": "attention_grabber",
        "element": "noise_sweep_down_with_drop",
        "velocity": 1.0
      },
      {
        "role": "hook_motif",
        "element": "synth_brass_repeating_fifth",
        "notes": ["D4", "A4"],
        "rhythm": "eighth_note_repetition"
      }
    ]
  },
  "harmonic_system": {
    "type": "static_power",
    "root": "D",
    "mode": "minor",
    "bass_movement": "none",
    "upper_structure": "evolving"
  },
  "form_structure": {
    "type": "immediate_climax",
    "bars": [
      {"index": 0, "energy": 1.0, "label": "impact"},
      {"index": 1, "energy": 1.0, "label": "maintain"},
      {"index": 2, "energy": 0.95, "label": "slight_breathe"},
      {"index": 3, "energy": 1.0, "label": "build_return"},
      {"index": 4, "energy": 0.9, "label": "transition"},
      {"index": 5, "energy": 1.0, "label": "final_push"},
      {"index": 6, "energy": 1.0, "label": "climax_sustain"},
      {"index": 7, "energy": 0.5, "label": "cut_or_cadence"}
    ]
  },
  "orchestration": {
    "strategy": "maximum_from_start",
    "initial_fullness": 0.9,
    "variation": "timbral_not_textural"
  }
}
```

---

### 2. TECH / CORPORATE / INNOVATION
**Use cases:** SaaS products, tech launches, AI demos, startup pitches, corporate branding

#### 2a. Tech Positive (30s)

```json
{
  "genre_id": "TECH_POSITIVE_30",
  "metadata": {
    "name": "Tech Corporate Uplifting",
    "description": "Clean, optimistic electronic with pentatonic hooks",
    "typical_use": ["SaaS commercials", "App launches", "AI demos", "Startup videos"],
    "tempo_range": [115, 130],
    "mood": "optimistic_clean_innovative"
  },
  "style_axes": {
    "harmonic_language": "modal",
    "texture_type": "homophonic",
    "temporal_approach": "metric",
    "sonic_density": "balanced"
  },
  "impact_frame": {
    "duration_ms": 3000,
    "layers": [
      {
        "role": "attention_grabber",
        "element": "shimmer_swell_high_pass",
        "frequency_range": "8000-12000hz",
        "velocity": 0.7
      },
      {
        "role": "genre_signifier",
        "element": "synth_pluck_pentatonic",
        "pattern": "arpeggio_up",
        "velocity": 0.8
      },
      {
        "role": "hook_motif",
        "element": "major_seventh_chord_stab",
        "notes": ["C4", "E4", "G4", "B4"],
        "rhythm": "quarter_notes",
        "velocity": 0.75
      }
    ],
    "voiceover_safe": {
      "duck_frequencies_below": 800,
      "leave_mid_range_clear": true,
      "lead_melody_octave": 5
    }
  },
  "temporal": {
    "timeSignature": [4, 4],
    "bpm": 124,
    "duration_target_seconds": 30,
    "bars": 16,
    "swing": 0.52,
    "endingBehavior": {
      "type": "cadential_insert",
      "cadenceBars": 2,
      "forceTonicLastBar": true,
      "final_chord": "major_seventh"
    }
  },
  "harmonic_system": {
    "type": "pentatonic_optimized",
    "key": "C_major",
    "scale_notes": ["C", "D", "E", "G", "A"],
    "chord_progression": [
      {"bar": 0, "chord": "Cmaj7", "voicing": "quartal_triad", "duration_bars": 4},
      {"bar": 4, "chord": "Gadd9", "voicing": "quartal", "duration_bars": 4},
      {"bar": 8, "chord": "Am7", "voicing": "open_fifth", "duration_bars": 2},
      {"bar": 10, "chord": "Fmaj7", "voicing": "spread", "duration_bars": 2},
      {"bar": 12, "chord": "Cmaj7", "voicing": "root_position", "duration_bars": 2},
      {"bar": 14, "chord": "Gadd9", "voicing": "second_inversion", "duration_bars": 1},
      {"bar": 15, "chord": "Cmaj7", "voicing": "root_position", "duration_bars": 1}
    ],
    "melody_technique": "skipping_pentatonic",
    "avoid_half_steps": true,
    "characteristics": ["open_intervals", "no_tritone_tension", "optimistic_seventh"]
  },
  "voice_leading": {
    "universal_rules": {
      "no_voice_crossing": true,
      "max_octave_spacing": 1.2,
      "tight_register": "C3_to_C6"
    },
    "chord_voicing": {
      "type": "quartal_and_open",
      "doubling": "fifth_and_octave",
      "third_usage": "minimal",
      "seventh_usage": "as_color_not_tension"
    },
    "bass_rules": {
      "follow_root": true,
      "movement": "stepwise_preferred",
      "octave_jumps": false
    },
    "melodic_rules": {
      "range_minimum": "octave",
      "contour": "ascending_arc",
      "ending_note": "scale_degree_1_or_3"
    }
  },
  "orchestration": {
    "phases": {
      "0_3s": {
        "instruments": ["shimmer_pad_high", "clean_pluck_synth"],
        "max_voices": 3,
        "frequency_focus": "high_air"
      },
      "3_8s": {
        "add": ["sub_bass_sine", "soft_kick", "light_percussion"],
        "max_voices": 4,
        "establish_groove": true
      },
      "8_15s": {
        "add": ["rhythm_guitar_clean", "synth_arp", "light_chords"],
        "max_voices": 6,
        "build_layer": "every_2_bars"
      },
      "15_25s": {
        "add": ["full_pad", "melody_doubling", "shaker"],
        "max_voices": 7,
        "climax": "full_texture"
      },
      "25_30s": {
        "remove": ["percussion", "arp"],
        "keep": ["pad", "final_chord", "bell_tone"],
        "cadence": "clean_resolve"
      }
    },
    "frequency_management": {
      "voiceover_reserve": {
        "range": "300Hz-3000Hz",
        "attenuation": "-9dB",
        "instruments_affected": ["pad_mid", "guitar_body"]
      },
      "lead_melody_range": "C5-C6",
      "bass_synth_range": "C2-C3"
    }
  },
  "rhythm_grid": {
    "stepsPerBar": 16,
    "swing_factor": 0.52,
    "patterns": {
      "kick": {
        "0_3s": [0.8, 0, 0, 0, 0, 0, 0, 0, 0.7, 0, 0, 0, 0, 0, 0, 0],
        "groove": [0.9, 0, 0, 0, 0.5, 0, 0, 0, 0.8, 0, 0, 0, 0.5, 0, 0, 0]
      },
      "hats": {
        "light": [0, 0, 0.4, 0, 0, 0, 0.4, 0, 0, 0, 0.4, 0, 0, 0, 0.4, 0],
        "full": [0, 0.3, 0.6, 0.3, 0, 0.3, 0.6, 0.3, 0, 0.3, 0.6, 0.3, 0, 0.3, 0.6, 0.3]
      },
      "pluck_arp": {
        "pattern": "eighth_note_tripets",
        "notes_per_bar": 8,
        "velocity_curve": "ascending"
      }
    }
  },
  "form_structure": {
    "type": "tech_build",
    "phases": [
      {"name": "sparkle_intro", "bars": [0, 2], "energy": 0.6, "focus": "high_freq"},
      {"name": "groove_establish", "bars": [2, 6], "energy": 0.7, "focus": "foundation"},
      {"name": "layer_build", "bars": [6, 12], "energy": 0.8, "focus": "complexity"},
      {"name": "full_statement", "bars": [12, 15], "energy": 0.9, "focus": "climax"},
      {"name": "clean_resolve", "bars": [15, 16], "energy": 0.4, "focus": "cadence"}
    ]
  }
}
```

#### 2b. AI/Future Tech (15s)

```json
{
  "genre_id": "AI_FUTURE_15",
  "metadata": {
    "name": "AI Futuristic Glitch",
    "description": "Glitchy, intelligent sounding with micro-edits",
    "tempo_range": [130, 150]
  },
  "temporal": {
    "timeSignature": [4, 4],
    "bpm": 140,
    "duration_target_seconds": 15,
    "bars": 8
  },
  "harmonic_system": {
    "type": "modal_static",
    "mode": "Lydian",
    "characteristic_note": "F_sharp",
    "ambiguity": "high",
    "chord_changes": "minimal"
  },
  "sound_design": {
    "glitch_elements": ["stutter_edits", "bit_reduction", "micro_chops"],
    "synth_type": "fm_digital",
    "texture": "crystalline"
  }
}
```

---

### 3. LIFESTYLE / LO-FI / CHILL
**Use cases:** Wellness apps, coffee brands, travel content, mindfulness, fashion lookbooks

#### 3a. Lo-Fi Chill (30s loop)

```json
{
  "genre_id": "LOFI_CHILL_30",
  "metadata": {
    "name": "Lo-Fi Hip Hop Chill",
    "description": "Warm, dusty beats with jazzy chords and vinyl texture",
    "typical_use": ["Coffee shop vibes", "Wellness apps", "Travel content", "Study music"],
    "tempo_range": [70, 90],
    "mood": "nostalgic_warm_relaxed"
  },
  "style_axes": {
    "harmonic_language": "modal",
    "texture_type": "homophonic",
    "temporal_approach": "cyclical",
    "sonic_density": "sparse"
  },
  "impact_frame": {
    "duration_ms": 4000,
    "characteristic": "no_sharp_attack",
    "layers": [
      {
        "role": "genre_signifier",
        "element": "vinyl_crackle_and_noise",
        "velocity": 0.4,
        "constant": true
      },
      {
        "role": "foundation",
        "element": "sidechained_pad",
        "velocity": 0.5,
        "attack": "slow_500ms"
      },
      {
        "role": "hook_motif",
        "element": " Rhodes_melody_fragment",
        "notes": ["F4", "A4", "E4", "D4"],
        "velocity": 0.6,
        "timing": "behind_beat_lazy"
      }
    ],
    "voiceover_safe": {
      "ducking": "sidechain_reactive",
      "mid_range": "permanently_clear",
      "headroom": "-6dB"
    }
  },
  "temporal": {
    "timeSignature": [4, 4],
    "bpm": 82,
    "duration_target_seconds": 30,
    "bars": 16,
    "swing": 0.6,
    "loop_type": "seamless_infinite",
    "endingBehavior": {
      "type": "loop_and_fade",
      "fade_start_bar": 14,
      "fade_curve": "slow"
    }
  },
  "harmonic_system": {
    "type": "modal_jazz",
    "mode": "Dorian",
    "key": "D_minor",
    "chord_progression": [
      {"bar": 0, "chord": "Dm9", "voicing": "rootless_third_seventh", "duration_bars": 2},
      {"bar": 2, "chord": "G13", "voicing": "shell", "duration_bars": 2},
      {"bar": 4, "chord": "Am9", "voicing": "quartal", "duration_bars": 2},
      {"bar": 6, "chord": "Gm7", "voicing": "closed", "duration_bars": 2},
      {"bar": 8, "chord": "Dm9", "voicing": "spread", "duration_bars": 2},
      {"bar": 10, "chord": "Cmaj7", "voicing": "open", "duration_bars": 2},
      {"bar": 12, "chord": "Am9", "voicing": "quartal", "duration_bars": 2},
      {"bar": 14, "chord": "Gm7", "voicing": "closed", "duration_bars": 1},
      {"bar": 15, "chord": "Dm9", "voicing": "spread", "duration_bars": 1}
    ],
    "extensions": ["ninths", "thirteenths"],
    "avoid": ["dominant_function", "tritone_resolution"]
  },
  "voice_leading": {
    "quartal_voicings": {
      "enabled": true,
      "stacks": ["perfect_fourths"],
      "use_in": ["Am9", "Dm9_passing"]
    },
    "guide_tones": {
      "priority": "third_and_seventh",
      "voice_movement": "stepwise"
    },
    "bass_rules": {
      "pattern": "repetitive_ostinato",
      "variation": "minimal",
      "sub_bass": "sine_wave_sidechained"
    },
    "melodic_rules": {
      "phrasing": "lazy_behind_beat",
      "range": "limited_fifth",
      "ornamentation": ["grace_notes", "subtle_bends"]
    }
  },
  "sound_design": {
    "vinyl_simulation": {
      "crackle": 0.3,
      "wow_flutter": 0.2,
      "dust": true
    },
    "tape_saturation": {
      "drive": 0.4,
      "frequency_loss": "high_shelf_-3db"
    },
    "reverb": {
      "type": "plate_long",
      "decay": 3.0,
      "wet": 0.4
    }
  },
  "orchestration": {
    "max_simultaneous": 5,
    "instruments": {
      "rhodes": {
        "range": ["F3", "D6"],
        "velocity": "soft_to_medium",
        "chorus": true
      },
      "sub_bass": {
        "waveform": "sine",
        "sidechain": true,
        "range": ["D1", "D2"]
      },
      "drums": {
        "kick": "soft_pillow",
        "snare": "brush_or_rim",
        "hats": "loose_shaker"
      },
      "pad": {
        "type": "warm_analog",
        "filter": "low_pass_resonant"
      }
    }
  },
  "rhythm_grid": {
    "stepsPerBar": 16,
    "swing": 0.6,
    "velocity_humanization": 0.15,
    "timing_humanization": 0.08,
    "patterns": {
      "kick": [0.7, 0, 0, 0, 0, 0, 0.5, 0, 0.6, 0, 0, 0, 0, 0, 0.4, 0],
      "snare": [0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0, 0, 0, 0.5, 0, 0, 0],
      "hats": [0, 0.3, 0.4, 0.3, 0, 0.3, 0.5, 0.3, 0, 0.3, 0.4, 0.3, 0, 0.3, 0.5, 0.3]
    }
  }
}
```

---

### 4. ACTION / SPORTS / ENERGY
**Use cases:** Sports highlights, fitness apps, energy drinks, action movie promos, gaming montages

#### 4a. High Energy Sports (30s)

```json
{
  "genre_id": "SPORTS_ENERGY_30",
  "metadata": {
    "name": "High Energy Sports Action",
    "description": "Driving beats, distorted synths, maximum adrenaline",
    "typical_use": ["Sports highlights", "Energy drink ads", "Gaming montages", "Fitness apps"],
    "tempo_range": [140, 170],
    "intensity": "maximum"
  },
  "style_axes": {
    "harmonic_language": "timbral",
    "texture_type": "homophonic",
    "temporal_approach": "metric",
    "sonic_density": "dense"
  },
  "impact_frame": {
    "duration_ms": 2000,
    "layers": [
      {
        "role": "attention_grabber",
        "element": "distorted_808_drop",
        "velocity": 1.0,
        "frequency_range": "sub_bass"
      },
      {
        "role": "energy_signal",
        "element": "white_noise_sweep_up",
        "velocity": 0.9,
        "duration": "1_second"
      },
      {
        "role": "hook_motif",
        "element": "synth_stab_riff",
        "notes": ["E4", "B4", "E5"],
        "rhythm": "staccato_eighths",
        "velocity": 0.95
      }
    ]
  },
  "temporal": {
    "timeSignature": [4, 4],
    "bpm": 150,
    "duration_target_seconds": 30,
    "bars": 20,
    "drive": "maximum",
    "endingBehavior": {
      "type": "hard_cut",
      "cut_bar": 19,
      "final_hit": "downbeat_20"
    }
  },
  "harmonic_system": {
    "type": "power_static",
    "root": "E",
    "mode": "minor",
    "power_chords": true,
    "progression": "minimal",
    "tension": "rhythmic_not_harmonic",
    "bass_movement": "pedal_or_octave"
  },
  "orchestration": {
    "phases": {
      "0_2s": {
        "full_throttle": true,
        "instruments": ["distorted_808", "layered_kicks", "noise_sweeps"],
        "energy": 1.0
      },
      "2_20s": {
        "variation": "timbre_modulation",
        "filter_movement": "saw_lfo",
        "energy": "sustained_max"
      }
    },
    "distortion": {
      "buss": 0.3,
      "parallel_compression": true
    }
  },
  "rhythm_grid": {
    "stepsPerBar": 32,
    "density": "maximum",
    "patterns": {
      "kick": "four_on_floor_with_extra_16ths",
      "snare": "backbeat_with_rolls",
      "hats": "32nd_note_rolls"
    }
  }
}
```

---

### 5. LUXURY / BEAUTY / FASHION
**Use cases:** Perfume commercials, high-end fashion, jewelry, premium automobiles, skincare

#### 5a. Luxury Elegant (30s)

```json
{
  "genre_id": "LUXURY_ELEGANT_30",
  "metadata": {
    "name": "Luxury Beauty Elegant",
    "description": "Sparse, refined textures with expensive silence",
    "typical_use": ["Perfume ads", "Fashion shows", "Luxury cars", "Premium skincare"],
    "tempo_range": [80, 100],
    "mood": "sophisticated_exclusive_minimal"
  },
  "style_axes": {
    "harmonic_language": "modal",
    "texture_type": "monophonic",
    "temporal_approach": "processual",
    "sonic_density": "sparse"
  },
  "impact_frame": {
    "duration_ms": 5000,
    "approach": "slow_reveal",
    "layers": [
      {
        "role": "atmosphere",
        "element": "solo_string_harmonics",
        "velocity": 0.4,
        "attack": "10_seconds"
      },
      {
        "role": "definition",
        "element": "single_bell_tone",
        "velocity": 0.5,
        "timing": "bar_2"
      }
    ]
  },
  "harmonic_system": {
    "type": "modal_static",
    "mode": "Lydian",
    "movement": "glacial",
    "chord_changes": "every_4_bars",
    "voicing": "extreme_open"
  },
  "orchestration": {
    "max_simultaneous": 3,
    "solo_instruments": ["solo_violin", "harp", "crystal_bowls"],
    "reverb": "cathedral_long",
    "silence_usage": "structural"
  }
}
```

---

### 6. QUIRKY / FUN / PLAYFUL
**Use cases:** Mobile games, children's products, casual apps, comedy content, food commercials

#### 6a. Quirky Fun (15s)

```json
{
  "genre_id": "QUIRKY_FUN_15",
  "metadata": {
    "name": "Quirky Playful Fun",
    "description": "Bouncy, unexpected sounds with rhythmic playfulness",
    "typical_use": ["Mobile game ads", "Kids apps", "Food commercials", "Casual games"],
    "tempo_range": [120, 145],
    "mood": "playful_bright_bouncy"
  },
  "style_axes": {
    "harmonic_language": "modal",
    "texture_type": "heterophonic",
    "temporal_approach": "metric",
    "sonic_density": "balanced"
  },
  "harmonic_system": {
    "type": "pentatonic_major",
    "avoid": ["minor_third", "tritone"],
    "characteristics": ["skip_step_melody", "major_seventh_resolution"]
  },
  "sound_design": {
    "acoustic_elements": ["kalimba", "ukulele", "claps", "whistles"],
    "synth_elements": ["bouncy_pluck", "pitch_bend_bass"],
    "unexpected_sounds": ["boings", "pops", "slides"]
  }
}
```

---

## Quick Reference: Genre Selection Matrix

| Client Need | Genre ID | Duration | Key Characteristics |
|-------------|----------|----------|---------------------|
| Movie trailer | EPIC_HEROIC_30 | 30s | Brass, percussion, minor lift |
| 15s social ad | EPIC_HYBRID_15 | 15s | Immediate full intensity |
| SaaS product demo | TECH_POSITIVE_30 | 30s | Pentatonic, voiceover safe |
| AI/tech innovation | AI_FUTURE_15 | 15s | Glitch, Lydian, futuristic |
| Coffee shop vibes | LOFI_CHILL_30 | 30s loop | Rhodes, vinyl, sidechain |
| Sports highlights | SPORTS_ENERGY_30 | 30s | 150bpm, distorted, maximum |
| Energy drink | SPORTS_ENERGY_30 | 15s | Hard cut, adrenaline |
| Perfume luxury | LUXURY_ELEGANT_30 | 30s | Solo strings, reverb, sparse |
| Fashion show | LUXURY_ELEGANT_30 | 60s | Processual, evolving |
| Mobile game | QUIRKY_FUN_15 | 15s | Bouncy, pentatonic, playful |
| Kids product | QUIRKY_FUN_15 | 30s | Acoustic elements, bright |

---

## Implementation Notes for Claude Code

### Workflow Integration

```javascript
// Pseudo-code for skill implementation
function composePromo(presetId, videoDurationMs, brandTone) {
  const preset = loadPreset(presetId);
  const adjustedPreset = adaptForDuration(preset, videoDurationMs);
  
  // Ensure 3-second hook rule
  const hook = generateImpactFrame(adjustedPreset.impact_frame, 3000);
  
  // Calculate exact bars for video
  const temporal = calculateTemporal(adjustedPreset.temporal, videoDurationMs);
  
  // Generate harmonic framework
  const harmony = generateHarmony(adjustedPreset.harmonic_system, temporal.bars);
  
  // Voice leading with promo priorities
  const voices = applyPromoVoiceLeading(harmony, adjustedPreset.voice_leading);
  
  // Orchestrate with density curve
  const arrangement = orchestrate(voices, adjustedPreset.orchestration);
  
  // Generate rhythm grids
  const grids = generateRhythmGrids(adjustedPreset.rhythm_grid, temporal);
  
  // Validate against video constraints
  return validateForVideo(arrangement, videoDurationMs);
}
```

### Priority Overrides for Promo Context

When conflicts arise between traditional voice leading and promo requirements:

1. **Hook clarity > Smooth voice leading** (melody must be instantly recognizable)
2. **Voiceover space > Orchestral fullness** (mid-range must be clear)
3. **Energy curve > Formal development** (compressed arc acceptable)
4. **Impact > Preparation** (no long fades or gradual entrances)
5. **Loop functionality > Cadential closure** (for social media use)

**What I provided are RULES/TEMPLATES, not actual music.** They are JSON **presets** that define constraints, parameters, and algorithms for generating music. They cannot be "played" as audio—they are instructions for a composition system.

Let me clarify the architecture:

---

## Architecture: Rules → Algorithm → Music

```
┌─────────────────────────────────────────────────────────────┐
│  JSON PRESET (What I provided)                               │
│  • Metadata (genre, mood, tempo range)                      │
│  • Style axes (harmonic language, texture)                  │
│  • Constraints (voice leading rules, orchestration limits)  │
│  • Templates (rhythm patterns, form structures)             │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  COMPOSITION ENGINE (Claude Code Skill Implementation)       │
│  • Parses JSON preset                                       │
│  • Makes decisions based on constraints                     │
│  • Generates symbolic music data (notes, rhythms, velocities)│
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  OUTPUT: Symbolic Music Representation                       │
│  • Note events (pitch, velocity, time, duration)            │
│  • Instrument assignments                                   │
│  • Control data (tempo, effects, automation)                │
│  • Format: MIDI / MusicXML / JSON for Tone.js / etc.       │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  AUDIO RENDERING (External tools)                            │
│  • Sampler instruments ( Kontakt, Ableton, etc.)            │
│  • Synth engines (Serum, Vital, etc.)                       │
│  • DAW export                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## The Skill's Role

The skill I designed is **step 2**—the composition engine. It takes a JSON preset and generates new music each time based on those rules.

**Key characteristics:**

| Aspect | What it is | What it is NOT |
|--------|-----------|----------------|
| **JSON Presets** | Constraint sets, probability distributions, rule hierarchies | Pre-composed audio files or note-for-note scores |
| **Skill Logic** | Algorithm that interprets presets and makes compositional choices | A playback engine or sampler |
| **Output** | Variable symbolic data (different every generation) | Fixed audio or fixed MIDI file |
| **Determinism** | Same preset + same seed = same output; same preset + different seed = different output | Random or fully predetermined |

---

## Example: How Generation Works

### Input (Preset snippet):
```json
{
  "harmonic_system": {
    "type": "pentatonic_optimized",
    "scale_notes": ["C", "D", "E", "G", "A"],
    "chord_progression": [
      {"chord": "Cmaj7", "duration_bars": 4},
      {"chord": "Gadd9", "duration_bars": 4}
    ]
  },
  "voice_leading": {
    "stepwise_preference": 0.8,
    "max_leap": 7
  }
}
```

### Skill Processing (Algorithm):
```
1. SELECT chord: Cmaj7 (bar 0-3)
2. GENERATE voicing: Choose between quartal or triad (weighted by preset)
3. VOICE LEADING: 
   - Prefer common tones from previous chord (if any)
   - Move other voices by step (70% probability) or small leap (30%)
   - Ensure no voice crossing
4. MELODY GENERATION:
   - Use pentatonic scale [C,D,E,G,A]
   - Create motif with "skipping" technique (avoid half steps)
   - Range: limited to one octave for hook clarity
5. RHYTHM:
   - Select grid pattern from preset based on current phase (impact/build/climax)
   - Apply velocity curve
6. CHECK constraints: Voice spacing, register, density limits
7. REPEAT for next chord with voice leading connections
```

### Output (Symbolic):
```json
{
  "events": [
    {"time": 0.0, "note": "C3", "velocity": 90, "duration": 2.0, "instrument": "bass"},
    {"time": 0.0, "note": "E4", "velocity": 70, "duration": 2.0, "instrument": "pad"},
    {"time": 0.0, "note": "G4", "velocity": 70, "duration": 2.0, "instrument": "pad"},
    {"time": 0.0, "note": "B4", "velocity": 70, "duration": 2.0, "instrument": "pad"},
    {"time": 0.5, "note": "C5", "velocity": 85, "duration": 0.5, "instrument": "lead"},
    {"time": 1.0, "note": "G4", "velocity": 80, "duration": 0.5, "instrument": "lead"},
    {"time": 1.5, "note": "E4", "velocity": 85, "duration": 0.5, "instrument": "lead"},
    {"time": 2.0, "note": "D4", "velocity": 75, "duration": 0.5, "instrument": "lead"}
    // ... continues for all bars
  ],
  "tempo": 124,
  "time_signature": [4, 4]
}
```

This output is then fed to a synthesizer/sampler to create audio.

---

## Comparison to Alternative Approaches

| Approach | Description | Pros | Cons |
|----------|-------------|------|------|
| **My Approach (Rule-Based)** | Presets define constraints; algorithm generates within bounds | Controllable, explainable, style-consistent | Requires good algorithm, may sound "safe" |
| **Pre-composed Loops** | Fixed audio files triggered by video events | Instant, professional quality | Not adaptive, repetitive, licensing issues |
| **AI Generation (Audio)** | Neural network generates raw audio from text | Highly varied, can mimic any style | Unpredictable, hard to control timing, compute-heavy |
| **Markov Chains** | Statistical patterns from existing music | Simple to implement | Often nonsensical harmonic progressions |

My approach is **hybrid**: rule-based symbolic generation with probabilistic variation, optimized for the constraints of video promos (timing, voiceover space, instant hooks).

---

## What Claude Code Would Actually Do

If implementing this as a Claude Code skill:

1. **User provides**: Video duration (e.g., 30s), genre hint (e.g., "tech corporate"), optional reference

2. **Claude selects**: Appropriate JSON preset from library

3. **Claude generates**: Symbolic music data (MIDI-like JSON) by:
   - Calculating exact bar structure for 30s @ 124bpm = ~15.5 bars → quantize to 16 bars
   - Applying harmonic progression rules from preset
   - Generating note events with voice leading constraints
   - Building orchestration layers per phase
   - Creating rhythm grids

4. **Claude outputs**: 
   ```json
   {
     "metadata": {"genre": "TECH_POSITIVE_30", "duration_ms": 30000},
     "midi_data": [...],
     "automation": [...],
     "render_notes": "Use clean pluck synth for lead, sidechain pad to kick..."
   }
   ```

5. **User takes output** and imports into DAW (Ableton, Logic, etc.) or web audio engine (Tone.js) for final rendering

---

## Clarification of My JSON Presets

The presets I provided are **declarative specifications**—they tell the system:
- WHAT constraints to respect
- WHAT parameters to vary within
- WHAT priorities to enforce

They do NOT contain:
- Actual note data
- Audio samples
- Fixed compositions

Each time the skill runs with the same preset, it generates a **new, unique composition** that follows those rules.

---

**Does this clarify the architecture?** The skill is essentially an **algorithmic composer** that uses JSON presets as its "style guide," not a playback system or a library of pre-made music.

---

  Ecco la **PdR (Proposta di Reale)** completa per il sistema inglese con HTML/CSS + Edge-TTS sincronizzato.

---

## CONTESTO ED OBIETTIVO

Devo creare un'**esperienza di apprendimento vocabolario interattiva** dove:

- **Input**: File HTML con animazioni CSS che mostrano parole inglesi in sequenza (es. fade-in, slide-in, typewriter)
- **Comportamento**: Ogni parola/apparizione testuale deve essere letta da Edge-TTS **nel momento esatto** in cui appare visivamente
- **Esperienza utente**: Sincronia perfetta tra visivo e audio, con voci naturali (neurali) che guida l'attenzione
- **Vincolo assoluto**: Solo strumenti gratuiti (Edge-TTS), uso personale/educativo

---

## TI PROPONGO QUESTA ARCHITETTURA

### Struttura tecnica ipotizzata

1. **Livello visivo**: HTML5 + CSS3 con keyframe animations (opacity/transform), nessun framework pesante
2. **Sincronizzazione**: JavaScript MutationObserver o Eventi CSS `animationstart` per catturare l'apparizione di ogni elemento
3. **TTS**: Edge-TTS via Python (script locale che serve API REST) o Node.js (edge-tts wrapper), con buffering preventivo degli audio
4. **Gestione stato**: Coda di riproduzione FIFO che associa ogni evento visivo al corrispondente MP3 generato
5. **Pre-generazione**: Script Python che scansiona l'HTML, estrae tutti i testi "animati", genera MP3 in batch con parametri ottimizzati per entusiasmo/pseudo-emozione

### Flusso dati
```
HTML con data-attributes (testo, timing, enfasi)
    ↓
Parser Python estrae sequenza temporale
    ↓
Edge-TTS genera MP3 per ogni snippet (rate/pitch variabili)
    ↓
Web server locale serve HTML + MP3 pre-generati
    ↓
JS sincronizza animation CSS con play() audio
```

---

## ANALIZZA, CONFUTA O CONFERMA

### Criticità potenziali che identifico:

**A. Latenza Edge-TTS in tempo reale**
- Edge-TTS richiede chiamata HTTP ai server Microsoft (~200-800ms)
- Se genero on-the-fly durante l'animazione, l'audio arriva in ritardo rispetto al CSS
- **Soluzione proposta**: Pre-generazione batch di tutti gli MP3 all'avvio, poi riproduzione locale sincronizzata

**B. Sincronia frame-perfect CSS vs Audio**
- CSS animations sono GPU-accelerated, Audio è thread del browser
- Drift temporale possibile su animazioni lunghe
- **Soluzione proposta**: Usare Web Animations API (WAAPI) invece di CSS keyframes per controllo programmatico, o usare `animation-play-state` pausato finché audio non è ready

**C. Pseudo-emozione con Edge-TTS: limiti tecnici**
- Edge-TTS non supporta SSML avanzato (`<mstts:express-as style="excited">` è solo Azure a pagamento)
- Solo: `rate`, `pitch` base, `volume`, `<break>`, `<emphasis>` (limitato)

---

## TECNICHE CONFERMATE PER PSEUDO-EMOZIONE (Edge-TTS Inglese)

Basate su ricerca forum (Reddit r/LocalLLaMA, GitHub edge-tts issues, blog cinesi Xiaoice TTS) :

### 1. **Punteggiatura emotiva stratificata**

| Pattern | Effetto | Esempio vocabolario |
|---------|---------|---------------------|
| `!!` doppio | Picco energia base | `"Word!!"` |
| `!!!` triplo | Enfasi massima | `"Excellent!!!"` |
| `!?` | Sorpresa/incredulità | `"Really!?"` |
| `...` | Sospensione drammatica | `"And the word is... [pause] Amazing!!"` |
| `—` (em dash) | Pausa ritmica | `"Listen—carefully—now!!"` |

### 2. **Onomatopee e interiezioni "cariche"**

| Tipo | Esempi | Uso |
|------|--------|-----|
| Gioia | `Yay!!`, `Woo-hoo!!`, `Yippee!!` | Inizio/fine lezione |
| Sorpresa | `Wow!!`, `Oh my!!`, `Whoa!!` | Parola difficile rivelata |
| Approvazione | `Nice!!`, `Great job!!`, `Perfect!!` | Risposta corretta |
| Incitamento | `Come on!!`, `You got this!!` | Prima di quiz |

### 3. **Prosodia via SSML base (supportato)**

```xml
<speak version="1.0">
  <!-- Parola normale: neutrale, chiaro -->
  <prosody rate="-15%">The word is: Book!!</prosody>
  
  <!-- Parola importante: rallentata + pitch alto -->
  <prosody rate="-25%" pitch="+10%">Pay attention: Irregular!!</prosody>
  
  <!-- Entusiasmo finale: velocità variabile -->
  <prosody rate="+5%">You</prosody> 
  <prosody rate="-10%">did</prosody> 
  <prosody rate="-20%" pitch="+15%">it!!!</prosody>
</speak>
```

**Trucco**: Variazione rate *interna* alla frase crea "melodia" emotiva.

### 4. **Tecniche "Prompt Engineering" per TTS**

Da ElevenLabs narrative styling , adattato per Edge-TTS:

| Tecnica | Implementazione |
|---------|-----------------|
| Stage directions | `"She whispers excitedly: The answer is... Secret!!"` |
| Reduplicazione | `"Wow wow wow!! That's right!!"` |
| Allitterazione | `"Super study success!!"` |
| Numeri scritti | `"Ninety percent!!"` > `"90%!!"` (più enfatico) |

### 5. **Pause `<break>` strategiche**

```xml
"Great!!<break time='200ms'/> 
Now listen...<break time='400ms'/> 
The word<break time='600ms'/> is...<break time='800ms'/> 
Incredible!!"
```

- Pause crescenti = tensione drammatica
- Pause dopo esclamazione = respiro emotivo

### 6. **Pattern ritmico "Stadium Chant"**

Da pratiche cinesi (forum Baidu Tieba su TTS emotivo):

```
"What! What! What!!"  (ritmo cardiaco, 120 BPM)
"Yes! Yes! Yes!!"     (crescendo)
```

Edge-TTS interpreta la ripetizione ritmica come energia.

---

## ARCHITETTURA CONFERMATA (post-analisi)

### Schema tecnico finale

```
FASE 1: PREPARAZIONE (Python offline)
├── Parser HTML estrae:
│   ├── Selettore CSS dell'elemento
│   ├── Testo da leggere
│   ├── Timing delay (quando appare)
│   └── Tipo enfasi (normal/excited/whisper/slow)
├── Edge-TTS genera MP3 per ogni elemento:
│   ├── Rate variabile per enfasi
│   ├── Pitch alto per picchi
│   └── Break calcolati su lunghezza testo
└── Genera manifest.json (sequenza temporale)

FASE 2: ESECUZIONE (Browser)
├── Carica HTML + CSS animations (paused all'inizio)
├── Precarica tutti MP3 in AudioBuffer
├── Al play: avvia sequenza dal manifest
│   ├── t=0ms: CSS animation start + audio1.play()
│   ├── t=1200ms: CSS animation2 + audio2.play() 
│   └── ... sincronizzato via timestamp assoluti
└── Gestione drift: ogni 5s, resync animation con currentTime audio
```

### Gestione errori

- **LibreOffice non serve più** (input è HTML, non PPTX)
- **Fallback**: se MP3 mancante, browser TTS locale (`speechSynthesis`) con voce di sistema
- **Offline mode**: MP3 pre-generati, nessuna chiamata HTTP durante la lezione

---

## CONFERMA O CONFUTAZIONE RICHIESTA A CLAUDE

1. **MutationObserver vs WAAPI**: Quale è più affidabile per catturare "elemento apparso" e triggerare audio senza drift?

2. **Edge-TTS rate/pitch**: Conosci limiti numerici esatti? (es. pitch max +50%? rate min -50%?)

3. **Preload MP3**: Quanti file audio può gestire fluidamente un browser moderno (50? 100?) prima di saturare memoria?

4. **Alternative a Edge-TTS offline**: Esiste Piper TTS (completamente offline) con qualità comparabile per l'inglese? Trade-off qualità vs latenza?

5. **SSML in Edge-TTS reale**: Hai conferma che `<emphasis>` funziona in inglese con edge-tts, o è documentazione Azure-only?

Se confermi l'architettura, fornisci il codice Python per il parser HTML + generatore batch MP3, e il codice JavaScript per la sincronizzazione precisa CSS/audio.

---

**Vincoli rigidi ripetuti**: Solo Edge-TTS (gratuito), no API a pagamento, no framework JS pesanti (React/Vue), solo vanilla JS + CSS animations.