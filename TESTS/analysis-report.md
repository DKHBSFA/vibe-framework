# TESTS Directory Analysis Report

**Date:** 2026-02-04
**Analyzed by:** Claude

---

## Executive Summary

Deep analysis of **10 webvideo HTML files** (v01-v10), JSON content files, and **MP4 frame extraction (517 frames)** revealed:

- **Critical semantic mismatches** — scene titles don't match content (v01 "The Problem", v02 "The Old Way", **v08 "The Problem"**)
- **Animation timing bugs** — text overlap during teaser→reveal transitions (v01, v02, v05, **v10**)
- **Severe scene stacking** — v04 renders multiple scenes simultaneously throughout
- **Text truncation** — partial text display in fast modes (**v07**, **v09**, **v10**)
- **Black transition frames** — scene transitions showing blank frames (**v10 frame 16**)
- **HTML Preview mode bugs** — severe overlap in preview player not present in MP4 (**v10 critical**)

**Note:** HTML preview mode artifacts (aspect ratio, text overlap) do not appear in rendered MP4 output.

---

## Files Analyzed

| File | Format | Dimensions | Scenes | Speed Mode |
|------|--------|------------|--------|------------|
| video1-hero-launch.html | horizontal-16x9 | 1920x1080 | 6 | fast/chaos |
| video2-explainer.html | vertical-9x16 | 1080x1920 | 6 | normal/safe |
| video3-benchmarks.html | square-1x1 | 1080x1080 | 4 | normal/hybrid |
| video4-timeline.html | horizontal-16x9 | 1920x1080 | 8 | fast/cocomelon |
| video5-modes.html | vertical-4x5 | 1080x1350 | 6 | slow/safe |

---

## CRITICAL: Semantic Mismatches

### 1. video1-hero-launch.html — Scene 3: "The Problem"

**Location:** Lines 375-403

**Issue:** Scene is titled "The Problem" but displays FEATURES (solutions), not problems.

**What it shows:**
- Card 1: "1 Trillion Parameters"
- Card 2: "100 Parallel Agents"
- Card 3: "76% Cheaper than Claude"
- Card 4: "Open Source Freedom"

**What it should show (from video1-content.json):**
> "One agent. One task. One bottleneck. Sequential AI is holding humanity back."

**Visual Evidence:**
Screenshot confirms 4 feature cards displayed under "The Problem" heading — a clear narrative contradiction.

**Impact:** High — breaks the problem→solution storytelling arc.

---

### 2. video2-explainer.html — Scene 3: "The Old Way"

**Location:** Lines 377-404

**Issue:** Scene is titled "The Old Way" but displays NEW swarm features.

**What it shows:**
- Card 1: "Automatic task decomposition"
- Card 2: "100 specialized agents"
- Card 3: "4.5x faster execution"
- Card 4: "Self-coordinating swarm"

**What it should show (from video2-content.json):**
> "Traditional AI: one task, one agent, wait for completion, repeat. Sequential. Slow."

**Visual Evidence:** Screenshot (3/6) confirms all 4 cards display NEW swarm features under "The Old Way" heading — complete narrative inversion.

**Impact:** High — inverts the intended contrast between old and new approaches.

---

## Animation Timing Bugs

### video1-hero-launch.html — Scene 0: Text Swap Overlap

**Location:** Lines 359-362

**Issue:** During the "teaser → reveal" text swap, both headings are visible simultaneously, creating unreadable overlapping text.

**What happens:**
- Teaser text: "The world's first agentic swarm AI with 1 trillion parameters"
- Reveal text: "76% Cheaper than Claude"
- Both render on top of each other during transition

**Animation timing analysis:**
```
Teaser:  fade-in-up 400ms @ 500ms  → fade-out 300ms @ 2400ms (ends ~2700ms)
Reveal:  scale-word 500ms @ 2600ms (starts while teaser still visible)
```

**Visual Evidence:** Screenshot shows "76% Cheaper than Claude" overlapping with "trillion parameters" — both texts simultaneously visible and unreadable.

**Root cause:** The fade-out (ends ~2700ms) overlaps with scale-word start (2600ms), creating a 100ms+ window where both are visible. Additionally, the teaser text may not be fully fading due to `position: absolute` stacking.

**Impact:** High — opening hook is illegible during transition.

---

### video2-explainer.html — Scene 0: Text Swap Overlap

**Location:** Lines 359-364

**Issue:** Same text overlap bug as video1 — teaser and reveal headings render simultaneously.

**What happens:**
- Teaser text: "How Kimi K2.5 orchestrates 100 parallel AI agents"
- Reveal text: "4.5x faster execution"
- Both overlap during transition

**Visual Evidence:** Screenshot shows "execution" overlapping with "How Kimi K2.5 orchestrates 100 parallel AI agents" — illegible.

**Impact:** High — opening hook unreadable.

---

### video4-timeline.html — Scene 1

**Location:** Lines 366-377

**Scene timing:**
- Starts: 1500ms
- Duration: 1500ms
- Ends: 3000ms

**Broken animations:**
1. `marquee 6300ms...6345ms infinite` — delay 6345ms exceeds scene end (3000ms)
2. `fade-out 300ms...3900ms forwards` — fires 900ms AFTER scene ends

**Result:** Text marquee and fade-out animations never execute visibly.

---

## Contrast Issues

### video1-hero-launch.html — Scene 5: "The Architecture"

**Visual Evidence:** Screenshot shows very low contrast:
- Background: near-black (`#0a0a0a` area)
- Text: gray (`opacity: 0.85` on already muted text)
- Grid overlay further reduces readability

**Text affected:**
> "Mixture-of-Experts with 384 experts. Only 8 active per token. 96.8% compute savings."

The text appears truncated/clipped mid-word ("...96.8% con..." visible in screenshot).

---

### video2-explainer.html — Scene 2: Text Truncation

**Visual Evidence:** The subtitle text is truncated by the navigation overlay:
- Shows: "How Kimi K2.5 orchestrates 100 parallel AI age..."
- Should show: "How Kimi K2.5 orchestrates 100 parallel AI agents"

**Root cause:** Navigation controls positioned over content area; text wrapping pushes "nts" behind nav bar.

**Impact:** Medium — incomplete information displayed.

---

### video3-benchmarks.html — Scene 3: "SWE-Bench Verified" Low Contrast

**Visual Evidence:** Screenshot shows extremely low contrast:
- Background: dark blue-gray (`#0f172a`)
- Card backgrounds: slightly lighter gray
- Text: muted gray, very difficult to read
- All 4 benchmark cards barely visible

**Cards affected:**
- "96.1% AIME 2025"
- "76.8% SWE-Bench"
- "50.2% HLE"
- "74.9% BrowseComp"

**Impact:** Medium — key benchmark data hard to read.

**Note:** video3 does NOT have the text overlap bug in scene 0 — it uses a simple single heading ("The Numbers Don't Lie") instead of the teaser→reveal pattern.

---

## Scene Count Mismatches

| Video | JSON Sections | HTML Scenes | Discrepancy |
|-------|---------------|-------------|-------------|
| video3-benchmarks | 5 | 4 | Missing "Price Comparison" |
| video4-timeline | 5 | 8 | 3 extra scenes not in JSON |

---

## Minor Issues

### 1. Empty CSS Declarations
Multiple files have trailing empty lines in CSS rules:
```css
.el-heading {
  ...


}
```
Cosmetic only, no functional impact.

### 2. Duplicate Text in Hook Scenes
All videos repeat the description text twice in scene 0:
- Once in the animated heading transition
- Once in the supporting `el-text`

This appears intentional for the "teaser → reveal" pattern.

### 3. video3 Notably Shorter
Only 4 scenes vs 6-8 in other videos. May be intentional for square format.

---

## video5-modes.html Analysis (from HTML Preview Screenshots)

### Aspect Ratio / Canvas Width Bug (PREVIEW MODE ONLY)

**Visual Evidence:** All 6 HTML preview screenshots show content rendered only in the left ~60% of the canvas, with solid black filling the right ~40%.

**Expected:** 4:5 vertical format (1080x1350) should fill the entire width
**Actual in preview:** Content is compressed to left side, leaving dead black space on right

**UPDATE:** MP4 frame analysis confirmed this bug is **NOT present in the actual rendered video**. The MP4 renders correctly at 4:5 format with content filling full width.

**Conclusion:** This is a **preview mode artifact** — the HTML preview's viewport handling doesn't match the actual video rendering.

**Impact:** Low — preview mode only, actual video is correct

---

### Scene 1 (1/6): Text Animation Overlap

**Issue:** The word "seconds" appears in large text overlapping with the subtitle "Four ways to use Kimi K2.5 for any workflow"

**What should show:** "Kimi K2.5 Modes" title

**What appears:** Partial animation state showing "seconds" (fragment from title animation) rendered mid-transition, creating illegible overlap

**Pattern:** This is the same teaser→reveal text overlap bug documented in video1 and video2, where both animation states render simultaneously.

**Impact:** High — opening scene is illegible

---

### Scene 2 (2/6): Proper Title Display

**Status:** Working correctly
- "Kimi K2.5 Modes" title displayed
- "Four ways to use Kimi K2.5 for any workflow" subtitle
- Red accent line below
- Purple/blue gradient background

This appears to be the same scene as 1/6 at a later point in the animation after the text swap completes.

---

### Scene 3 (3/6): Mode Overview Cards

**Status:** Layout working
- "Instant Mode" as scene title
- 4 stacked cards listing all modes:
  - "Instant Mode: 3-8 seconds"
  - "Thinking Mode: Deep reasoning"
  - "Agent Mode: Multi-step tasks"
  - "Swarm Mode: 100 parallel agents"

**Minor issue:** Cards only fill left portion of viewport (related to aspect ratio bug)

---

### Scene 4 (4/6): Thinking Mode

**Status:** Content displays correctly
- "Thinking Mode" title
- "Shows reasoning step-by-step. 96K token budget. 96.1% AIME accuracy."
- Dark background

---

### Scene 5 (5/6): Agent Mode — Low Contrast

**Visual Evidence:** Gray text on blue background
- Title: "Agent Mode" (readable)
- Subtitle: "Autonomous multi-step workflows. Search, code, browse. 200+ tool calls stable."
- Blue background with subtle grid pattern

**Issue:** Text contrast is borderline — light gray text on medium blue background reduces readability

**Impact:** Medium — content legible but strained

---

### Scene 6 (6/6): CTA Scene

**Status:** Working correctly
- "Pick Your Mode" title
- "Four ways to use Kimi K2.5 for any workflow" subtitle
- Pink/coral CTA button "Pick Your Mode"
- Red/maroon background with gradient

---

## MP4 Frame Analysis (Rendered Video Verification)

Extracted frames at 1fps from all 5 MP4 files to verify issues in actual rendered output.

**Frame extraction:** `ffmpeg -i video.mp4 -vf "fps=1" frame_%03d.png`

### video1 (01-hero-launch-kimi.mp4) — 24 frames

| Frame | Timestamp | Content | Issue |
|-------|-----------|---------|-------|
| 1 | 0s | Empty cyan background | — |
| 2-3 | 1-2s | "trillion parameters" partial text | Text animation shows fragment |
| 4 | 3s | "76% Cheaper than Claude" | Reveal text visible |
| 5 | 4s | Empty red/pink screen | Scene transition |
| 8 | 7s | "Kimi K2.5" + full description | Working correctly |
| 12 | 11s | **"The Problem"** with feature cards | **CONFIRMED: Semantic mismatch** |
| 16 | 15s | "The Solution" | Working |
| 20 | 19s | **"TheASolutionre"** overlapping text | **NEW: Scene transition overlap** |
| 24 | 23s | "Experience the Swarm Revolution" CTA | Working |

**New finding:** Frame 20 shows severe scene transition bug — "The Solution" and "The Architecture" titles render simultaneously, creating garbled "TheASolutionre" text.

---

### video2 (02-explainer-agent-swarm.mp4) — 26 frames

| Frame | Timestamp | Content | Issue |
|-------|-----------|---------|-------|
| 1 | 0s | Empty purple gradient | — |
| 3 | 2s | "orchestrates 100 parallel AI agents" | Low contrast gray text |
| 8 | 7s | "Agent Swarm Technology" | Ghosted text visible behind |
| 12 | 11s | **"The Old Way"** with swarm features | **CONFIRMED: Semantic mismatch** |

**Confirmed:** "The Old Way" scene displays NEW swarm features instead of old-way problems.

---

### video3 (03-benchmarks-data.mp4) — 16 frames

| Frame | Timestamp | Content | Issue |
|-------|-----------|---------|-------|
| 1 | 0s | Empty green gradient | — |
| 4 | 3s | "The Numbers Don't Lie" | Clean, no overlap |
| 8 | 7s | "AIME 2025" with 2 benchmark cards | Animation in progress |
| 12 | 11s | "SWE-Bench Verified" with 4 cards | **Contrast better than HTML preview** |

**Status:** Video3 is the cleanest — no text overlap bugs, benchmarks display well in actual MP4.

---

### video4 (04-timeline-moonshot.mp4) — 12 frames

| Frame | Timestamp | Content | Issue |
|-------|-----------|---------|-------|
| 1-6 | 0-5s | "$3.3B valuation" + "The Spark" | **CRITICAL: Dual title overlap** |
| 10 | 9s | Same content fading out | Overlap persists |
| 12 | 11s | **Three titles overlapping** | **SEVERE: "valuation/Spark/Revolution"** |

**Critical finding:** Video4 has severe scene stacking — multiple scene titles render simultaneously throughout. Frame 12 shows "$3.3B valuation", "The Spark", and "Join the Revolution" all visible at once with mixed card content.

---

### video5 (05-feature-modes.mp4) — 27 frames

| Frame | Timestamp | Content | Issue |
|-------|-----------|---------|-------|
| 1 | 0s | Blue gradient with red glow | — |
| 4 | 3s | "seconds" partial word | Text animation fragment |
| 10 | 9s | "Instant Mode" title only | Cards not yet visible |
| 14 | 13s | "Thinking Mode" + description | Working correctly |
| 18 | 17s | "Agent Mode" title | Working |
| 22 | 21s | "Agent Mode" + description + grid | Working correctly |
| 27 | 26s | "Pick Your Mode" CTA | Working correctly |

**CORRECTION:** The aspect ratio bug documented from HTML preview screenshots is **NOT present** in the actual MP4. The video renders at correct 4:5 vertical format with content filling full width. The black space on the right was a **preview mode artifact only**.

**Remaining issue:** Scene 0 text animation still shows "seconds" partial word.

---

## MP4 Analysis Summary

| Video | Semantic Bug | Text Overlap | Scene Stacking | Contrast | Aspect Ratio |
|-------|--------------|--------------|----------------|----------|--------------|
| video1 | **YES** (The Problem) | YES (scene 0) | **YES** (frame 20) | Medium | OK |
| video2 | **YES** (The Old Way) | YES (scene 0) | No | Low | OK |
| video3 | No | No | No | OK in MP4 | OK |
| video4 | — | YES | **SEVERE** (multi-scene) | OK | OK |
| video5 | No | YES (scene 0) | No | OK | **OK** (HTML preview bug only) |

---

## Recommendations

### Immediate Fixes (High Priority)

1. **video1, video2 & video5 Scene 0 text overlap:**
   - Delay reveal animation start until teaser fade-out completes
   - Option A: Change reveal delay from 2600ms to 2800ms
   - Option B: Speed up teaser fade-out or start it earlier
   - Apply fix to video1-hero-launch.html, video2-explainer.html, and video5-modes.html

2. **video4 Scene Stacking Bug (CRITICAL):**
   - Multiple scenes render simultaneously throughout the video
   - "$3.3B valuation", "The Spark", "Join the Revolution" all visible at once
   - Investigate scene visibility/opacity transitions
   - Ensure previous scene fully hides before next scene appears

3. **video1 Scene Transition Overlap (frame 20):**
   - "The Solution" and "The Architecture" titles render simultaneously
   - Creates garbled "TheASolutionre" text
   - Add proper fade-out completion before next scene starts

4. **video1 "The Problem" scene:**
   - Replace feature cards with problem statement
   - Content: "One agent. One task. One bottleneck. Sequential AI is holding humanity back."

5. **video2 "The Old Way" scene:**
   - Replace swarm feature cards with old-way description
   - Content: "Traditional AI: one task, one agent, wait for completion, repeat. Sequential. Slow."

### Medium Priority

6. **video1 "The Architecture" scene:**
   - Increase text contrast
   - Check for text overflow/clipping

7. **video3 "SWE-Bench Verified" scene:**
   - Note: Contrast is better in actual MP4 than HTML preview
   - Still consider increasing card contrast for accessibility

8. **video5 "Agent Mode" scene:**
   - Increase text contrast (gray on blue)
   - Consider darker text or lighter background

9. **video3:**
   - Add missing "Price Comparison" scene if intended

10. **video5 HTML Preview Mode (Low Priority):**
    - Fix aspect ratio display in preview (content shows at 60% width)
    - Note: Actual MP4 renders correctly — this is preview mode only

---

## Videos 6-10 Analysis (v06-v10)

**Date:** 2026-02-04 (Extended analysis)

### Video Configurations

| Video | Format | Dimensions | Speed | Mode |
|-------|--------|------------|-------|------|
| v06-vert-chaos-fast | vertical-9x16 | 1080x1920 | fast | chaos |
| v07-square-cocomelon-fastest | square-1x1 | 1080x1080 | fastest | cocomelon |
| v08-vert45-hybrid-normal | vertical-4x5 | 1080x1350 | normal | hybrid |
| v09-horiz-safe-slow | horizontal-16x9 | 1920x1080 | slow | safe |
| v10-vert-hybrid-normal | vertical-9x16 | 1080x1920 | normal | hybrid |

### Frame Counts

| Video | Frames |
|-------|--------|
| v06 | 91 |
| v07 | 53 |
| v08 | 101 |
| v09 | 110 |
| v10 | 57 |

---

### v06 (vert-chaos-fast) — 91 frames

| Frame | Timestamp | Content | Issue |
|-------|-----------|---------|-------|
| 1 | 0s | Black screen | — |
| 3 | 2s | "The Future of AI is Here" + tilted subtitle | Minor animation artifact |
| 5 | 4s | Clean title + subtitle | OK |
| 20 | 19s | "The Solution" (title only) | No body content visible |

**Status:** Relatively clean. Minor text animation tilt on frame 3.

---

### v07 (square-cocomelon-fastest) — 53 frames

| Frame | Timestamp | Content | Issue |
|-------|-----------|---------|-------|
| 1 | 0s | Black screen | — |
| 3 | 2s | "The Future of AI is Here" | Clean |
| 5 | 4s | "with 1 trillion parameters. Orchestrates 100 parallel agents for" | **TRUNCATED: Missing title, sentence cut off** |
| 10 | 9s | "The Solution" | Title only |

**Issues Found:**
- **Frame 5:** Truncated text — missing heading "The Future of AI is Here", subtitle sentence incomplete ("...for" cut off)
- Fast cocomelon pacing (1500ms scenes) causing text truncation

---

### v08 (vert45-hybrid-normal) — 101 frames

| Frame | Timestamp | Content | Issue |
|-------|-----------|---------|-------|
| 3 | 2s | "The Future of AI is Here" | Clean |
| 5 | 4s | Same | Clean |
| 20 | 19s | "The Problem" + "76.8% SWE-Bench Verified" card | **SEMANTIC MISMATCH (Bug 1)** |

**Issues Found:**
- **Frame 20:** "The Problem" scene displays benchmark feature card instead of problem statement
- Same semantic mismatch bug as v01 and v02

---

### v09 (horiz-safe-slow) — 110 frames

| Frame | Timestamp | Content | Issue |
|-------|-----------|---------|-------|
| 3 | 2s | "trillion parameters. Orchestrates 100 parallel agents for complex tasks." | **TRUNCATED: Missing prefix** |

**Issues Found:**
- **Frame 3:** Text truncation — missing "The world's first agentic swarm AI with 1" prefix
- Heading not visible during this frame

---

### v10 (vert-hybrid-normal) — 57 frames

| Frame | Timestamp | Content | Issue |
|-------|-----------|---------|-------|
| 3-10 | 2-9s | "The Future of AI is Here" | Clean |
| 12-15 | 11-14s | "agentic swarm AI with 1 trillion" | **PARTIAL TEXT: Incomplete** |
| 16 | 15s | Completely black | **BLACK FRAME during transition** |

**Issues Found:**
- **Frames 12-15:** Partial text visible — missing "The world's first" prefix
- **Frame 16:** Completely black during scene transition

**HTML Preview Mode Bug (Critical):**
Screenshot evidence shows severe text overlap in HTML preview player (scene 2/6):
- "agentic sw**AIME**" — multiple text layers overlapping
- "with 1 trilli**Accuracy**" — reveal text bleeding through teaser
- Problem statement text visible simultaneously with feature overlays
- Content only rendered on left ~40% of canvas (aspect ratio bug in preview)

**Note:** This HTML preview overlap is more severe than what appears in the MP4 frames, indicating a preview-mode-specific rendering bug.

---

### v06-v10 Summary

| Video | Semantic Bug | Text Truncation | Black Frames | Preview Overlap |
|-------|--------------|-----------------|--------------|-----------------|
| v06 | No | No | No | — |
| v07 | No | **YES** (frame 5) | No | — |
| v08 | **YES** (frame 20) | No | No | — |
| v09 | No | **YES** (frame 3) | No | — |
| v10 | No | **YES** (frames 12-15) | **YES** (frame 16) | **CRITICAL** |

---

### New Bug Category: HTML Preview Rendering

**Affects:** v10 (confirmed), possibly others

**Symptoms:**
- Text layers overlap severely in HTML preview mode
- Aspect ratio wrong (content ~40% width, rest black)
- Preview navigation (Prev/Next/Play buttons) visible
- Not present in rendered MP4 output

**Root Cause:** HTML preview player doesn't properly handle:
1. Multi-phase text animations (teaser→reveal)
2. Scene visibility timing
3. Vertical format aspect ratios

**Recommendation:** Add as Bug 6 or note as preview-mode-only issue that doesn't affect final video output.

---

## Appendix: JSON Section → HTML Scene Mapping

### video1-content.json Sections
| # | Title | Expected Content |
|---|-------|------------------|
| 1 | The Problem | "One agent. One task. One bottleneck..." |
| 2 | The Solution | "Kimi K2.5 orchestrates up to 100..." |
| 3 | The Architecture | "Mixture-of-Experts with 384 experts..." |
| 4 | The Results | "96.1% AIME 2025. 76.8% SWE-Bench..." |
| 5 | The Freedom | "Open source. Self-hostable..." |

### video2-content.json Sections
| # | Title | Expected Content |
|---|-------|------------------|
| 1 | The Old Way | "Traditional AI: one task, one agent..." |
| 2 | The Swarm Way | "Kimi decomposes complex tasks..." |
| 3 | Specialization | "Each agent specializes: researcher, coder..." |
| 4 | Coordination | "Agents share context and collaborate..." |
| 5 | Results | "50 competitor analyses in 40 minutes..." |

---

*Report generated from code analysis, HTML preview screenshots, and MP4 frame extraction of all 10 videos.*

**Total frames analyzed:** 517 (v01-v10)
- v01: 23 frames
- v02: 26 frames
- v03: 16 frames
- v04: 12 frames
- v05: 27 frames
- v06: 91 frames
- v07: 53 frames
- v08: 101 frames
- v09: 110 frames
- v10: 57 frames

**Frame location:** `TESTS/videos/frames/v{01-10}-*/`
