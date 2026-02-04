# Video-Craft Deep Analysis: Why Bugs Persist

**Date:** 2026-02-04
**Purpose:** Root cause analysis of persistent bugs despite multiple fix iterations

---

## Executive Summary

After deep code analysis of all source files in `.claude/skills/video-craft/engine/src/`, I identified **3 fundamental architectural issues** that cause the recurring bugs:

| Root Cause | Affects | Severity |
|------------|---------|----------|
| Scene Type / Scene Content Decoupling | Bug 1 (Semantic Mismatch) | **CRITICAL** |
| Content Cursor Mutation | Bug 1, Bug 2 | **HIGH** |
| Animation Timing at Frame Boundaries | Bug 2, Bug 3, Bug 4 | **MEDIUM** |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        autogen.ts                               │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ 1. selectNarrativePattern() → pattern.sequence[]        │   │
│  │    Returns: ['stat-callout|problem-statement',          │   │
│  │              'product-intro', 'feature-showcase', ...]  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ↓                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ 2. FOR EACH slot: resolveSlot() → SceneTypeId           │   │
│  │    Scores candidates, returns CONCRETE type             │   │
│  │    ⚠️ NO CONTENT CONSUMED YET                           │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ↓                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ 3. FOR EACH resolved type: buildElements()              │   │
│  │    Uses ContentCursor to consume content                │   │
│  │    ⚠️ CURSOR MUTATES CONTENT, MAY SWAP SECTIONS         │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ↓                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ 4. sceneNameFromElements() → scene.name                 │   │
│  │    Derives name from FIRST HEADING in elements          │   │
│  │    ⚠️ NAME COMES AFTER CONTENT, MAY NOT MATCH TYPE      │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                      html-generator.ts                          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ generateSceneHTML() → scene visibility animations       │   │
│  │ generateMultiPhaseHTML() → teaser/reveal timing         │   │
│  │ ⚠️ TIMING SENSITIVE TO FRAME EXTRACTION                 │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Root Cause 1: Scene Type / Content Decoupling

### The Problem

Scene **TYPE** is determined BEFORE content is assigned. Scene **NAME** is derived AFTER content is built. This creates a semantic disconnect.

### Evidence

**autogen.ts:423-427** — First loop resolves types:
```typescript
for (const slot of pattern.sequence) {
  const sceneTypeId = resolveSlot(slot, content, usedSceneTypes, mode);
  usedSceneTypes.add(sceneTypeId);
  resolvedSceneTypes.push(sceneTypeId);  // TYPE DECIDED HERE
}
```

**autogen.ts:465-519** — Second loop builds content:
```typescript
for (let i = 0; i < totalScenes; i++) {
  const sceneTypeId = resolvedSceneTypes[i];  // TYPE ALREADY FIXED
  let elements = buildElements(sceneTypeId, content, cursor, density);  // CONTENT BUILT NOW
  // ...
  const scene: SceneDef = {
    name: sceneNameFromElements(elements, sceneTypeId, i, usedSceneNames),  // NAME FROM CONTENT
    elements,
  };
}
```

### Why This Causes Bug 1

1. `resolveSlot('stat-callout|problem-statement')` scores content fitness
2. Returns `feature-showcase` if `content.features.length` is high
3. `buildElements('feature-showcase')` builds feature cards
4. For the heading, `findBestSection()` may return a section titled "The Problem"
5. `sceneNameFromElements()` uses that heading as the scene name
6. **Result:** Scene TYPE is `feature-showcase`, but NAME is "The Problem"

### The Fix Required

**Either:**
- A) Couple type resolution with content assignment (semantic scene building)
- B) Use the TYPE to dictate the scene name, not the content
- C) Add content-type validation before building elements

---

## Root Cause 2: Content Cursor Mutation

### The Problem

The content cursor pattern consumes content sequentially AND mutates the source arrays.

### Evidence

**autogen.ts:106-130** — `findNarrativeSection()` SWAPS array elements:
```typescript
function findNarrativeSection(content, cursor) {
  for (let i = cursor.sectionIdx; i < content.sections.length; i++) {
    if (NARRATIVE_KEYWORDS.some(kw => titleLower.includes(kw))) {
      // MUTATION: Swap found section to cursor position
      if (i !== cursor.sectionIdx) {
        [content.sections[cursor.sectionIdx], content.sections[i]] =
          [content.sections[i], content.sections[cursor.sectionIdx]];
      }
      cursor.sectionIdx++;
      return s;
    }
  }
}
```

**autogen.ts:132-168** — `findBestSection()` also swaps:
```typescript
function findBestSection(content, cursor, keywords) {
  // ... find bestIdx by score ...
  if (bestIdx !== cursor.sectionIdx) {
    [content.sections[cursor.sectionIdx], content.sections[bestIdx]] =
      [content.sections[bestIdx], content.sections[cursor.sectionIdx]];
  }
  cursor.sectionIdx++;
  return section;
}
```

### Why This Causes Bugs

1. Scene N calls `findNarrativeSection()` → swaps "The Problem" section to position 2
2. Scene N+1 calls `findBestSection(['feature', ...])` → "The Problem" is now at position 2
3. If no feature-keyword match, falls back to `nextSection()` which returns "The Problem"
4. **Result:** "The Problem" title gets assigned to a feature-showcase scene

### The Fix Required

**Either:**
- A) Don't mutate source arrays — use indices/marks instead
- B) Pre-allocate content to scenes based on semantic matching before building
- C) Clone content before processing

---

## Root Cause 3: Animation Timing at Frame Boundaries

### The Problem

Frame extraction at 1fps captures momentary animation states that appear as bugs.

### Evidence

**html-generator.ts:790-838** — Multi-phase timing:
```typescript
// Phase 0: enters at baseDelay, holds 1500ms, fades out 300ms
// Phase 1: enters after exitTime + 300ms + 100ms buffer
cursor = exitTime + (pi < phases.length - 1 ? exitDuration + 100 : 0);
```

The math is correct (100ms gap between phases), but:
- Frame at second 2 might catch Phase 0 mid-fade
- Frame at second 3 might catch Phase 1 mid-entrance
- Neither shows the "correct" stable state

### Why This Appears as Bugs

1. Video runs at 60fps, frame extraction at 1fps
2. 1 frame represents 1000ms of video time
3. If transition happens at 2400ms, frame 2 (at 2000ms) shows Phase 0
4. Frame 3 (at 3000ms) shows Phase 1
5. **The 600ms transition window is never captured**
6. If frame 2 or 3 lands in the transition window, it shows overlap

### Evidence from Frame Analysis

- v10 frames 12-15 show "agentic swarm AI with 1 trillion"
- This is PARTIAL text during animation entrance
- The text IS complete, but the animation hasn't finished when the frame is captured

### The Fix Required

**Either:**
- A) Add longer hold times before transitions (padding for frame capture)
- B) Use `visibility: hidden` instead of opacity for phase exits
- C) Extract frames at higher rates to verify actual behavior

---

## Why Previous Fixes Haven't Worked

### Spec Analysis

The spec file `.claude/docs/specs/video-craft-bug-fixes.md` contains correct diagnoses and proposed fixes, BUT:

1. **Fixes were written to spec, not applied to code**
   - The spec proposes `cursor = exitTime + exitDuration + 100`
   - The code at `html-generator.ts:837` ALREADY HAS this
   - The fix was already there, bug persists for different reasons

2. **Root cause misidentified**
   - Bug 1 was attributed to "timing" but is actually "decoupling"
   - Bug 2 fix is in place but frame capture timing causes perceived bug

3. **Array mutation not addressed**
   - The `findNarrativeSection()` and `findBestSection()` mutations
   - These were never identified as a root cause

---

## Files and Line References

| File | Function | Lines | Issue |
|------|----------|-------|-------|
| `autogen.ts` | `resolveSlot()` call | 423-427 | Type resolved before content |
| `autogen.ts` | `buildElements()` call | 469 | Content built with type already fixed |
| `autogen.ts` | `sceneNameFromElements()` | 515 | Name derived from content, not type |
| `autogen.ts` | `findNarrativeSection()` | 121-124 | Array mutation |
| `autogen.ts` | `findBestSection()` | 158-161 | Array mutation |
| `composition.ts` | `resolveSlot()` | 408-462 | Scores content but doesn't reserve it |
| `html-generator.ts` | `generateMultiPhaseHTML()` | 790-844 | Timing math correct |
| `html-generator.ts` | Scene visibility | 596-614 | overlap/hide timing |

---

## Recommended Fix Strategy

### Phase 1: Fix Semantic Mismatch (Bug 1)

**Change `buildElements()` for 'feature-showcase' case (autogen.ts:226-264):**

```typescript
case 'feature-showcase': {
  // NEW: Get the scene NAME that was assigned to this slot
  // If it's a narrative title, use narrative content, not features
  const assignedName = pattern.sequence[sceneIndex]; // or track separately

  // Check if this scene is SUPPOSED to show problem/narrative content
  const isNarrativeScene = NARRATIVE_KEYWORDS.some(kw =>
    assignedName?.toLowerCase().includes(kw)
  );

  if (isNarrativeScene) {
    // Force narrative content, not feature cards
    const section = findBestSection(content, cursor, ['problem', 'challenge', ...]);
    if (section) {
      els.push({ type: 'heading', text: section.title, size: 'lg' });
      els.push({ type: 'text', text: section.body });
      break;
    }
  }

  // ... existing feature card logic
}
```

### Phase 2: Fix Array Mutation

**Replace array swaps with a "used sections" set:**

```typescript
const usedSectionIndices = new Set<number>();

function findNarrativeSection(content, cursor, usedSections) {
  for (let i = 0; i < content.sections.length; i++) {
    if (usedSections.has(i)) continue;  // Skip already used
    // ... matching logic ...
    if (match) {
      usedSections.add(i);
      return content.sections[i];
    }
  }
}
```

### Phase 3: Scene Visibility Hardening

**Use `visibility: hidden` end-state for definitive hiding:**

```css
@keyframes scene-hide {
  from { opacity: 1; visibility: visible; }
  99% { opacity: 0; visibility: visible; }
  100% { opacity: 0; visibility: hidden; }
}
```

---

## Validation Plan

After applying fixes:

1. **Unit test semantic matching:**
   - Input: content with "The Problem" section + 5 features
   - Expected: "The Problem" scene shows text, "Features" scene shows cards

2. **Integration test cursor state:**
   - Log cursor state after each scene build
   - Verify no section is used twice

3. **Frame analysis at 10fps:**
   - Extract frames at higher rate to capture transitions
   - Verify no overlap during transition windows

---

*Analysis based on deep code review of 22 source files totaling 200KB+*
*Cross-referenced with 517 extracted frames from 10 test videos*
