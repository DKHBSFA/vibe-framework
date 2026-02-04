# Video-Craft Bug Fixes Implementation Plan

**Date:** 2026-02-04
**Updated:** 2026-02-04 (frame-by-frame visual verification)
**Source:** TESTS/analysis-report.md + MP4 frame analysis (10 videos, 500+ frames)
**Files to modify:** 4 core files in `.claude/skills/video-craft/engine/src/`

---

## Visual Frame Analysis Summary

Frame-by-frame inspection of rendered videos confirms these issues:

### v01-horiz-chaos-fast
- **Frame 21-23:** "The Problem" scene shows feature cards ("1 Trillion Parameters Total", "32 Billion Active Per Token") mixed with problem text
- **Frame 30:** "The Solution" displays correctly with feature cards

### v04-vert45-cocomelon-normal
- **Frame 4:** Dark/blank transition frame between scenes
- Rapid scene changes create visible artifacts

### v07-square-cocomelon-fastest
- **Frame 4:** Similar transition artifacts as v04
- **Frame 5:** Text truncation — missing heading, sentence cut off mid-word
- Fast pacing (1500ms scenes) amplifies overlap issues

### v08-vert45-hybrid-normal
- **Frame 20:** "The Problem" scene shows "76.8% SWE-Bench Verified" benchmark card
- Same semantic mismatch bug as v01

### v09-horiz-safe-slow
- **Frame 3:** Text truncation — missing "The world's first agentic swarm AI with 1" prefix
- Heading not visible during animation

### v10-vert-hybrid-normal
- **Frames 12-15:** Partial text "agentic swarm AI with 1 trillion" (missing prefix)
- **Frame 16:** Completely black during scene transition
- **HTML Preview (Critical):** Severe multi-layer text overlap with aspect ratio bug (content at ~40% width)

---

## Executive Summary

Root cause analysis identified **5 distinct bug categories** affecting video generation:

| Bug | Severity | Root Cause File | Fix Complexity |
|-----|----------|-----------------|----------------|
| Semantic Mismatch | Critical | `autogen.ts` | Medium |
| Multi-Phase Text Overlap | High | `html-generator.ts` | Low |
| Scene Stacking | Critical | `html-generator.ts` | Medium |
| Scene Transition Overlap | High | `html-generator.ts` | Medium |
| Low Contrast Text | Medium | `html-generator.ts` | Low |

---

## Bug 1: Semantic Mismatches

### Symptoms
- **v01** "The Problem" scene shows features (solutions) instead of problem statement
- **v02** "The Old Way" scene shows NEW swarm features instead of old-way description
- **v08** "The Problem" scene shows "76.8% SWE-Bench Verified" benchmark card instead of problem statement

### Root Cause Analysis

**File:** `autogen.ts:131-333` (`buildElements()` function)

**Key Insight from Frame Analysis:** The scene NAME vs scene TYPE are decoupled:

1. Scene TYPES are resolved in `resolveSlot()` BEFORE elements are built
2. A scene may get assigned `feature-showcase` type → builds feature cards
3. Scene NAME is derived LATER from heading content via `sceneNameFromElements()`
4. **Result:** Scene named "The Problem" (from heading) but TYPE is `feature-showcase` (with cards)

The `problem-statement` case in `buildElements()` (lines 195-209) correctly builds text-only content, but it's not being invoked because the scene TYPE is `feature-showcase`, not `problem-statement`.

The function builds scene content using a **content cursor** that sequentially pulls from `features[]` array, regardless of the scene's semantic meaning.

```typescript
// Current behavior (WRONG):
case 'feature-showcase': {
  const features = nextFeatures(content, cursor, maxItems);  // Just takes next N features
  // ... builds cards from features
}
```

**Problem:** When a scene is assigned the name "The Problem" (from `sections[0].title`), it should use `sections[0].body` as content. Instead, it pulls from `features[]`.

### Fix

**Modify `buildElements()` to match scene content semantically:**

1. For `problem-statement` and `before-after` scene types:
   - Use `findBestSection()` with the actual scene NAME as keyword
   - If section body contains problem-related content, use that

2. Create new helper `findSectionByTitle()`:
   ```typescript
   function findSectionByTitle(content: ExtractedContent, title: string): Section | null {
     return content.sections.find(s =>
       s.title.toLowerCase().includes(title.toLowerCase())
     ) ?? null;
   }
   ```

3. In `feature-showcase` case, check if scene is named after a section:
   ```typescript
   case 'feature-showcase': {
     // Check if this scene should use section content
     const matchingSection = findSectionByTitle(content, sceneName);
     if (matchingSection && !matchingSection.body.includes('feature')) {
       // Use section body as text, not feature cards
       els.push({ type: 'heading', text: matchingSection.title, size: 'lg' });
       els.push({ type: 'text', text: matchingSection.body });
       break;
     }
     // ... existing feature card logic
   }
   ```

### Files to Modify
- `autogen.ts`: Lines 131-333 (buildElements function)
- `composition.ts`: `resolveSlot()` function - needs to consider content semantics when selecting scene type

### Additional Discovery
The `feature-showcase` case (lines 227-264) already has narrative handling:
```typescript
// FIRST: Check for narrative sections (problem statements, origin stories, etc.)
const narrativeSection = findNarrativeSection(content, cursor);
if (narrativeSection) {
  els.push({ type: 'heading', text: truncate(narrativeSection.title, 120), size: 'lg' });
  els.push({ type: 'text', text: truncate(narrativeSection.body, 250) });
  break;
}
```

But this check isn't being triggered reliably because:
1. `findNarrativeSection()` swaps sections in the array (mutates content)
2. By the time a "problem" scene is built, narrative sections may already be consumed
3. The cursor position affects which sections are searched

---

## Bug 2: Multi-Phase Text Overlap (Scene 0 teaser→reveal)

### Symptoms
- Opening scene shows "trillion parameters" and "76% Cheaper than Claude" overlapping
- Both teaser and reveal text visible simultaneously during transition

### Additional Instances (v06-v10)
- **v07 frame 5:** Text truncation — heading missing, sentence cut off ("...for")
- **v09 frame 3:** Text truncation — missing "The world's first agentic swarm AI with 1" prefix
- **v10 frames 12-15:** Partial text visible, animation state incomplete
- **v10 HTML preview:** Severe multi-layer overlap (teaser + reveal + other elements)

### Root Cause Analysis

**File:** `html-generator.ts:773-825` (`generateMultiPhaseHTML()`)

The timing calculation allows overlap:

```
Phase 0 (teaser):
  - Entrance: 500ms
  - Fade-out starts: 2400ms, duration 300ms (ends ~2700ms)

Phase 1 (reveal):
  - Entrance starts: 2600ms

OVERLAP WINDOW: 2600ms - 2700ms (100ms+ where both visible)
```

### Fix

**Option A (Recommended):** Add gap between fade-out end and next entrance

In `generateMultiPhaseHTML()`, modify the cursor calculation:

```typescript
// Current (line 806-818):
const exitTime = enterTime + phaseDur + holdTime;
animParts += `, fade-out ${300}ms ${easing} ${exitTime}ms forwards`;
cursor = exitTime;

// Fixed:
const exitDuration = 300;
const exitTime = enterTime + phaseDur + holdTime;
animParts += `, fade-out ${exitDuration}ms ${easing} ${exitTime}ms forwards`;
cursor = exitTime + exitDuration + 100;  // Wait for fade-out to complete + 100ms buffer
```

**Option B:** Ensure phase 0 is `visibility: hidden` after fade-out

Add a keyframe animation that sets `visibility: hidden` at the end of fade-out:

```css
@keyframes fade-out-hide {
  0% { opacity: 1; visibility: visible; }
  99% { opacity: 0; visibility: visible; }
  100% { opacity: 0; visibility: hidden; }
}
```

### Files to Modify
- `html-generator.ts`: Lines 806-818 (cursor calculation in generateMultiPhaseHTML)

---

## Bug 3: Scene Stacking (cocomelon mode)

### Symptoms
- v04-vert45-cocomelon-normal frame 4: Dark transition frame
- v07-square-cocomelon-fastest frame 4: Similar artifacts
- Rapid cocomelon scenes (1500ms) show visible overlap during transitions

### Root Cause Analysis

**File:** `html-generator.ts:601-609` (overlap calculation)

**Code Review Finding:** The overlap is already proportional:
```typescript
const overlapMs = Math.max(50, Math.min(150, Math.round(scene.durationMs * 0.03)));
const hideDelay = scene.startMs + scene.durationMs - overlapMs;
```

For 1500ms cocomelon scenes: 0.03 * 1500 = 45ms → clamped to 50ms overlap.

**Why It Still Fails:**
- Scene hide starts at 1450ms (50ms before end)
- Next scene reveal at 1500ms
- Both scenes have partial opacity during 50ms window
- With flash/glitch transitions, artifacts are highly visible

**Previous approach** (fixed but incomplete):
```css
.scene {
  position: absolute;
  opacity: 0;
}
.scene:first-child { opacity: 1; }
/* Scene reveal via animation */
animation: scene-reveal 100ms ease [startMs]ms both;
```

The scene-hide animation was added but the overlap timing still causes issues in fast modes.

### Fix

**Add scene fade-out animations that complete BEFORE next scene fades in.**

1. Create `scene-hide` keyframe:
```css
@keyframes scene-hide {
  from { opacity: 1; }
  to { opacity: 0; visibility: hidden; }
}
```

2. In `generateSceneHTML()`, add fade-out animation to each scene:
```typescript
// For each scene except the last, add hide animation
const hideDelay = scene.startMs + scene.durationMs - 100;  // Start 100ms before next scene
const hideAnim = sceneIndex < totalScenes - 1
  ? `, scene-hide 100ms ease ${hideDelay}ms forwards`
  : '';

const combinedAnim = animParts.length > 0
  ? `animation: ${animParts.join(', ')}${hideAnim};`
  : hideAnim ? `animation: ${hideAnim.slice(2)};` : '';
```

3. Ensure visibility is properly managed:
```css
@keyframes scene-reveal {
  from { opacity: 0; visibility: visible; }
  to { opacity: 1; visibility: visible; }
}
@keyframes scene-hide {
  from { opacity: 1; visibility: visible; }
  to { opacity: 0; visibility: hidden; }
}
```

### Cocomelon-Specific Fix (NEW)

**Mode-aware overlap handling:**

```typescript
// In html-generator.ts:601-609
const mode = config.video?.mode;
const overlapMs = mode === 'cocomelon'
  ? 0  // Instant switch for fast-paced cocomelon
  : Math.max(50, Math.min(150, Math.round(scene.durationMs * 0.03)));
```

**Or use visibility toggle instead of opacity fade:**
```css
@keyframes scene-hide-instant {
  0% { visibility: visible; }
  100% { visibility: hidden; }
}
```

### Files to Modify
- `html-generator.ts`:
  - Lines 163-171 (scene-hide keyframe already exists)
  - Lines 601-609 (mode-aware overlap calculation)

---

## Bug 4: Scene Transition Overlap (video1 frame 20)

### Symptoms
- "The Solution" and "The Architecture" titles overlap creating "TheASolutionre"
- Scene transitions don't properly hide previous scene

### Root Cause
Same as Bug 3 - this is a manifestation of the scene stacking issue during transition.

### Fix
Same fix as Bug 3. Additionally:

1. Ensure transition-out animations include opacity fade:
```typescript
// In generateSceneHTML, when scene has transitionOut:
if (scene.transitionOut) {
  // Add explicit fade-out before transition starts
  const fadeOutStart = scene.startMs + scene.durationMs - transitionOutDurationMs;
  // ...
}
```

---

## Bug 5: Low Contrast Text

### Symptoms
- video1 "The Architecture" scene: gray text on near-black background, barely readable
- video3 "SWE-Bench Verified" scene: muted text on dark blue-gray, cards hard to read
- video5 "Agent Mode" scene: gray text on blue background, strained readability

### Root Cause Analysis

**File:** `html-generator.ts` (CSS generation for text elements)

The issue stems from:
1. Text opacity defaults (0.85) combined with already muted colors
2. Background gradients that reduce effective contrast
3. Grid overlays that further diminish readability

### Specific Cases

**video1 "The Architecture":**
- Background: `#0a0a0a` (near-black)
- Text: gray with `opacity: 0.85`
- Grid overlay compounds the problem
- Text also appears truncated ("...96.8% con...")

**video3 "SWE-Bench Verified":**
- Background: `#0f172a` (dark blue-gray)
- Card backgrounds: slightly lighter gray
- Benchmark cards barely visible
- Note: MP4 renders better than HTML preview

**video5 "Agent Mode":**
- Background: medium blue with grid pattern
- Text: light gray
- Borderline WCAG compliance

### Fix

**Option A (Recommended): Enforce minimum contrast ratio**

Add contrast checking in `html-generator.ts` when generating text styles:

```typescript
function ensureContrast(textColor: string, bgColor: string): string {
  const ratio = getContrastRatio(textColor, bgColor);
  if (ratio < 4.5) {  // WCAG AA standard
    // Lighten text for dark backgrounds, darken for light
    return adjustForContrast(textColor, bgColor, 4.5);
  }
  return textColor;
}
```

**Option B: Remove opacity reduction on text**

In CSS generation, ensure text elements have full opacity:

```css
.el-text, .el-heading {
  opacity: 1;  /* Override any inherited opacity */
}
```

**Option C: Add text shadow for legibility**

```css
.el-text, .el-heading {
  text-shadow: 0 1px 2px rgba(0,0,0,0.5);
}
```

### Files to Modify
- `html-generator.ts`: Text element CSS generation
- Possibly `composition.ts`: If contrast is calculated during composition

---

## Implementation Order

1. **Bug 2 (Multi-Phase Text Overlap)** - Quickest fix, isolated to one function
2. **Bug 3 & 4 (Scene Stacking/Transition)** - Related fixes, do together
3. **Bug 1 (Semantic Mismatch)** - Most complex, requires understanding content flow
4. **Bug 5 (Low Contrast)** - Can be done independently, visual polish

---

## Testing Plan

After each fix:
1. Regenerate all 10 test videos using existing content JSON files
2. Extract frames at 1fps using ffmpeg
3. Verify specific frame timestamps:

   **v01-v05 (existing tests):**
   - v01 frame 2-4: No text overlap in opening
   - v01 frame 12: "The Problem" should show problem text, not features
   - v01 frame 20: No overlapping scene titles
   - v04 frame 1-12: Single scene visible at each timestamp

   **v06-v10 (new tests):**
   - v07 frame 5: Complete text visible (no truncation)
   - v08 frame 20: "The Problem" should show problem text, not benchmark card
   - v09 frame 3: Complete sentence with prefix visible
   - v10 frames 12-15: Complete text animation
   - v10 frame 16: Smooth transition (no black frame)

4. Contrast verification:
   - v01 "The Architecture": Text clearly readable against dark background
   - v03 "SWE-Bench Verified": Benchmark cards legible
   - v05 "Agent Mode": Gray text readable on blue background

5. HTML Preview verification (v10):
   - Open v10-vert-hybrid-normal.html in browser
   - Navigate through all 6 scenes
   - No text overlap at any scene
   - Full-width content (no aspect ratio bug)

---

## Code Changes Summary

| File | Function | Change |
|------|----------|--------|
| `autogen.ts` | `buildElements()` | Add semantic section matching |
| `html-generator.ts` | `generateMultiPhaseHTML()` | Fix phase timing cursor |
| `html-generator.ts` | CSS keyframes section | Add `scene-hide` keyframe |
| `html-generator.ts` | `generateSceneHTML()` | Add scene hide animation |
| `html-generator.ts` | Text element CSS | Ensure minimum contrast / full opacity |

---

## Risk Assessment

| Fix | Risk | Mitigation |
|-----|------|------------|
| Multi-phase timing | Low | Only affects scene 0 multi-phase elements |
| Scene hide animation | Medium | May affect scene duration calculations; test all formats |
| Semantic matching | Medium | May change content distribution; needs thorough testing |
| Contrast enforcement | Low | Visual-only change; may alter intended aesthetic slightly |

---

## Priority Order (Revised)

1. **Bug 1 (Semantic Mismatch)** - Most visible quality issue, affects professional perception
2. **Bug 3 (Scene Stacking)** - Cocomelon-specific, mode-aware fix needed
3. **Bug 2 (Multi-Phase Overlap)** - Isolated fix, low risk
4. **Bug 4 (Transition Overlap)** - Resolved by Bug 3 fix
5. **Bug 5 (Low Contrast)** - Visual polish, improves accessibility (WCAG compliance)

---

*Plan created from analysis of 10 videos (v01-v10), 517 extracted frames, and deep code review.*
*Updated 2026-02-04 with frame-by-frame visual verification of all 10 videos.*
*Bugs confirmed in: v01, v02, v04, v07, v08, v09, v10*
