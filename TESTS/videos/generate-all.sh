#!/bin/bash
# Generate 10 diverse video variations using all animation types

ENGINE="npx tsx .claude/skills/video-craft/engine/src/index.ts"
CONTENT="TESTS/videos/content-kimi.json"
OUTDIR="TESTS/videos"

echo "=== Generating 10 Video Variations ==="
echo ""

# Video 1: horizontal-16x9, fast, chaos - product launch (high energy entrances)
echo "[1/10] horizontal-16x9 | fast | chaos | product-launch"
$ENGINE autogen "$CONTENT" \
  --format=horizontal-16x9 \
  --mode=chaos \
  --speed=fast \
  --intent="product launch announcement" \
  > "$OUTDIR/v01-horiz-chaos-fast.html"

# Video 2: vertical-9x16, normal, safe - explainer (clean minimal animations)
echo "[2/10] vertical-9x16 | normal | safe | explainer"
$ENGINE autogen "$CONTENT" \
  --format=vertical-9x16 \
  --mode=safe \
  --speed=normal \
  --intent="explainer tutorial" \
  > "$OUTDIR/v02-vert-safe-normal.html"

# Video 3: square-1x1, slow, hybrid - data visualization (mixed animations)
echo "[3/10] square-1x1 | slow | hybrid | data-viz"
$ENGINE autogen "$CONTENT" \
  --format=square-1x1 \
  --mode=hybrid \
  --speed=slow \
  --intent="data visualization benchmarks" \
  > "$OUTDIR/v03-square-hybrid-slow.html"

# Video 4: vertical-4x5, normal, cocomelon - social media (neuro-optimized)
echo "[4/10] vertical-4x5 | normal | cocomelon | social"
$ENGINE autogen "$CONTENT" \
  --format=vertical-4x5 \
  --mode=cocomelon \
  --speed=normal \
  --intent="social media promo reel" \
  > "$OUTDIR/v04-vert45-cocomelon-normal.html"

# Video 5: horizontal-16x9, slowest, safe - presentation (professional)
echo "[5/10] horizontal-16x9 | slowest | safe | presentation"
$ENGINE autogen "$CONTENT" \
  --format=horizontal-16x9 \
  --mode=safe \
  --speed=slowest \
  --intent="presentation demo b2b" \
  > "$OUTDIR/v05-horiz-safe-slowest.html"

# Video 6: vertical-9x16, fast, chaos - teaser (short punchy)
echo "[6/10] vertical-9x16 | fast | chaos | teaser"
$ENGINE autogen "$CONTENT" \
  --format=vertical-9x16 \
  --mode=chaos \
  --speed=fast \
  --intent="teaser short ad launch" \
  > "$OUTDIR/v06-vert-chaos-fast.html"

# Video 7: square-1x1, fastest, cocomelon - promo (maximum energy)
echo "[7/10] square-1x1 | fastest | cocomelon | promo"
$ENGINE autogen "$CONTENT" \
  --format=square-1x1 \
  --mode=cocomelon \
  --speed=fastest \
  --intent="promo quick" \
  > "$OUTDIR/v07-square-cocomelon-fastest.html"

# Video 8: vertical-4x5, normal, hybrid - portfolio (creative)
echo "[8/10] vertical-4x5 | normal | hybrid | portfolio"
$ENGINE autogen "$CONTENT" \
  --format=vertical-4x5 \
  --mode=hybrid \
  --speed=normal \
  --intent="portfolio brand creative story" \
  > "$OUTDIR/v08-vert45-hybrid-normal.html"

# Video 9: horizontal-16x9, slow, safe - tutorial (educational)
echo "[9/10] horizontal-16x9 | slow | safe | tutorial"
$ENGINE autogen "$CONTENT" \
  --format=horizontal-16x9 \
  --mode=safe \
  --speed=slow \
  --intent="tutorial explainer demo" \
  > "$OUTDIR/v09-horiz-safe-slow.html"

# Video 10: vertical-9x16, normal, hybrid - announcement (balanced)
echo "[10/10] vertical-9x16 | normal | hybrid | announcement"
$ENGINE autogen "$CONTENT" \
  --format=vertical-9x16 \
  --mode=hybrid \
  --speed=normal \
  --intent="announcement partnership ecosystem" \
  > "$OUTDIR/v10-vert-hybrid-normal.html"

echo ""
echo "=== All HTML configs generated ==="
echo ""
echo "Now rendering videos..."
echo ""

# Render all videos
for i in 01 02 03 04 05 06 07 08 09 10; do
  HTML=$(ls $OUTDIR/v${i}-*.html 2>/dev/null | head -1)
  if [ -n "$HTML" ]; then
    echo "Rendering $HTML..."
    $ENGINE render "$HTML" || echo "  WARNING: render failed for $HTML"
  fi
done

echo ""
echo "=== Done ==="
