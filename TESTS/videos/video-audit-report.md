# Video-Craft Comprehensive Audit Report

**Date:** 2026-02-04
**Generated Videos:** 10 unique configurations
**Source Material:** Kimi K2.5 AI (from TESTS/source-material.md)

---

## Executive Summary

Generated 10 videos with complete animation variety:
- **3 Formats:** horizontal-16x9, vertical-9x16, vertical-4x5, square-1x1
- **4 Modes:** safe, chaos, hybrid, cocomelon
- **5 Speeds:** slowest, slow, normal, fast, fastest

**Animation Coverage:** 44 unique entrance animations detected across all videos, covering all energy levels from minimal (fade-in) to high (glitch-in) to special (typewriter).

**Critical Issues Identified:** 4 code-level bugs requiring fixes.

---

## Video Configurations Generated

| Video | Format | Mode | Speed | Duration | Scenes |
|-------|--------|------|-------|----------|--------|
| v01-horiz-chaos-fast | 1920x1080 | chaos | fast | 44.8s | 10 |
| v02-vert-safe-normal | 1080x1920 | safe | normal | 37.5s | 8 |
| v03-square-hybrid-slow | 1080x1080 | hybrid | slow | 55.0s | 8 |
| v04-vert45-cocomelon-normal | 1080x1350 | cocomelon | normal | 30.1s | 11 |
| v05-horiz-safe-slowest | 1920x1080 | safe | slowest | 66.3s | 8 |
| v06-vert-chaos-fast | 1080x1920 | chaos | fast | 51.3s | 11 |
| v07-square-cocomelon-fastest | 1080x1080 | cocomelon | fastest | 26.5s | 11 |
| v08-vert45-hybrid-normal | 1080x1350 | hybrid | normal | 50.3s | 9 |
| v09-horiz-safe-slow | 1920x1080 | safe | slow | 61.1s | 8 |
| v10-vert-hybrid-normal | 1080x1920 | hybrid | normal | 28.3s | 6 |

---

## Animation Usage Analysis

### Entrance Animations (44 unique types detected)

| Animation | Count | Energy Level |
|-----------|-------|--------------|
| fade-in-up | 106 | minimal |
| char-stagger | 25 | special |
| clip-reveal-left | 21 | low |
| typewriter | 20 | special |
| clip-reveal-up | 13 | low |
| fade-in | 10 | minimal |
| slide-left | 8 | low |
| marquee | 8 | low (continuous) |
| scale-word | 5 | high |
| flip-in-y | 5 | medium |
| bounce-in | 5 | medium |
| zoom-in | 4 | medium |
| word-by-word | 4 | special |
| kinetic-push | 4 | high |
| bounce-in-down | 4 | medium |
| blur-in | 3 | special |
| traverse | 2 | medium (continuous) |
| text-reveal-mask | 2 | special |
| spring-scale | 2 | medium |
| spring-left | 2 | medium |
| anticipate-up | 2 | medium |
| glitch-in | 1 | high |
| flash-in | 1 | high |
| roll-in | 1 | medium |
| morph-circle-in | 1 | medium |

### Transitions Used

| Transition | Count | Videos |
|------------|-------|--------|
| crossfade | Most common | all |
| fade | Common | safe mode |
| blur | Medium | hybrid/safe |
| push-left/right/up/down | Common | all |
| slide-left/right/up/down | Common | all |
| iris-open/close | Rare | chaos |
| flash | Rare | cocomelon |
| glitch | Rare | cocomelon |
| diamond-reveal | Rare | chaos |
| circle-reveal | Medium | hybrid |
| morph-reveal | Medium | hybrid/safe |
| wipe-left/right | Medium | chaos |
| zoom-in | Medium | hybrid/cocomelon |

### Background Animations

| Animation | Count |
|-----------|-------|
| bg-gradient-drift | 41 |
| bg-grid-pulse | 29 |
| vignette | 10 |
| particle-float | 5 |
| ambient-glow | 4 |

---

## Issues Identified

### CRITICAL: Semantic Content Mismatches

**Issue 1: "The Problem" Scene Shows Features Instead of Problems**

- **Files Affected:** v01, v02, v03, v05, v08, v09
- **Location:** Scenes titled "The Problem"
- **Expected:** Problem statement text describing pain points
- **Actual:** Feature cards showing solutions (e.g., "1 Trillion Parameters", "100 Parallel Agents")

**Root Cause (autogen.ts:180-208):**
The `buildElements()` function for `problem-statement` scene type falls through to feature extraction when `findBestSection()` returns null or when features are found before problem-related sections.

```typescript
// autogen.ts:200-207
if (els.length < density.max) {
  const section = findBestSection(content, cursor, ['problem', 'challenge', 'pain', 'issue', 'struggle']);
  if (section?.body) els.push({ type: 'text', text: truncate(section.body, 200) });
}
if (els.length < density.max && content.ctaText) {
  els.push({ type: 'button', text: content.ctaText });
}
```

The function adds CTA buttons but never explicitly excludes feature cards when the scene is semantically a "problem" scene.

---

### HIGH: Scene Stacking Bug in Cocomelon Mode

**Issue 2: Multiple Scenes Visible Simultaneously**

- **Files Affected:** v04-vert45-cocomelon-normal, v07-square-cocomelon-fastest
- **Symptom:** Scene hide animation timing overlaps with next scene reveal
- **Example:** Scene 0 ends at 1500ms but scene-hide fires at 1350ms (150ms buffer), while scene 1 reveals at 1500ms

**Root Cause (html-generator.ts:599-606):**
```typescript
const hideDelay = scene.startMs + scene.durationMs - 150;  // Start hiding 150ms before scene ends
const sceneHideValue = isLastScene
  ? ''
  : `scene-hide 150ms ease ${hideDelay}ms forwards`;
```

The 150ms overlap is intentional for crossfade effect, but in cocomelon mode with very short scene durations (1500ms), this creates visible overlap.

---

### MEDIUM: Generic Scene Names ("Details 1", "Details 2"...)

**Issue 3: Auto-generated Scene Names Are Uninformative**

- **Files Affected:** All 10 videos
- **Symptom:** Multiple scenes named "Details 1", "Details 2", "Details 3"...
- **Impact:** Makes debugging and navigation difficult

**Root Cause (autogen.ts:634-672):**
When content cursor is exhausted, `sceneNameFromElements()` falls back to generic names.

---

### LOW: Output Path Always Uses Default

**Issue 4: All Videos Render to Same Output Path**

- **Symptom:** `output="./output/video.mp4"` is hardcoded
- **Impact:** Renders overwrite each other

**Root Cause (autogen.ts:594):**
```typescript
output: './output/video.mp4',
```

The output path should be derived from the input filename or provided as a parameter.

---

## Mode-Specific Observations

### Safe Mode (v02, v05, v09)
- Consistent use of fade-in-up as primary entrance
- Smooth easing (cubic-bezier(0.4, 0.0, 0.2, 1))
- Transitions: crossfade, fade, blur, push, slide
- Scene durations: 4000-12850ms
- Professional, corporate feel

### Chaos Mode (v01, v06)
- Wide variety of entrances (27 unique types)
- Aggressive transitions: iris-open/close, diamond-reveal, flash, glitch
- Unpredictable easing: includes spring and bounce curves
- Higher energy throughout

### Hybrid Mode (v03, v08, v10)
- Base safe animations with 1-2 "breaker" animations per video
- Transitions include circle-reveal, morph-reveal
- Scene durations: 3000-11500ms
- Good balance of professionalism and visual interest

### Cocomelon Mode (v04, v07)
- Neuro-optimized pattern with rapid scene changes
- Shortest scene durations: 1500-3500ms
- High-energy transitions: flash, glitch
- Spring/bounce easing throughout
- Most scenes per video (11 scenes)

---

## Animation Timing Analysis

### Scene Transition Timing Pattern

```
Scene N:   |-------- duration --------|
Scene N+1:              |-------- duration --------|
                        ^ reveal    ^ hide
                        +100ms      -150ms (overlap)
```

**Cocomelon Problem:**
With 1500ms scene durations:
- Scene 0: 0ms → 1500ms, hide at 1350ms
- Scene 1: reveal at 1500ms
- **Overlap window:** 150ms where both scenes are transitioning

**Safe Mode (5000ms durations):**
- Scene 0: 0ms → 5000ms, hide at 4850ms
- Scene 1: reveal at 5000ms
- **Overlap window:** 150ms (less noticeable due to longer duration)

---

## Recommendations

### Immediate Fixes Required

1. **Fix semantic content mapping (HIGH)**
   - Modify `buildElements()` to respect scene type semantics
   - Add explicit problem/solution content separation logic
   - Prevent feature cards from appearing in problem-statement scenes

2. **Fix cocomelon scene stacking (HIGH)**
   - Add minimum scene duration validation for cocomelon mode
   - Adjust hide timing to be mode-aware
   - Consider using `visibility: hidden` instead of opacity for faster scene switches

3. **Fix output path (LOW)**
   - Pass output filename through autogen options
   - Or derive from input HTML filename

4. **Improve scene naming (LOW)**
   - Use heading text for scene name when available
   - Avoid "Details N" pattern

### Code Locations for Fixes

| Issue | File | Lines | Function |
|-------|------|-------|----------|
| Semantic mismatch | autogen.ts | 180-260 | buildElements() |
| Scene stacking | html-generator.ts | 599-606 | generateSceneHTML() |
| Output path | autogen.ts | 594 | generateConfig() |
| Scene naming | autogen.ts | 634-672 | sceneNameFromElements() |

---

## Appendix: Files Generated

```
TESTS/videos/
├── content-kimi.json          # Source content
├── v01-horiz-chaos-fast.html  # 1920x1080 chaos fast
├── v02-vert-safe-normal.html  # 1080x1920 safe normal
├── v03-square-hybrid-slow.html # 1080x1080 hybrid slow
├── v04-vert45-cocomelon-normal.html # 1080x1350 cocomelon normal
├── v05-horiz-safe-slowest.html # 1920x1080 safe slowest
├── v06-vert-chaos-fast.html   # 1080x1920 chaos fast
├── v07-square-cocomelon-fastest.html # 1080x1080 cocomelon fastest
├── v08-vert45-hybrid-normal.html # 1080x1350 hybrid normal
├── v09-horiz-safe-slow.html   # 1920x1080 safe slow
├── v10-vert-hybrid-normal.html # 1080x1920 hybrid normal
└── video-audit-report.md      # This report
```

---

*Report generated from static HTML analysis and code review.*
