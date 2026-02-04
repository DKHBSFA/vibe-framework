#!/bin/bash
# Render all videos and extract frames

ENGINE="npx tsx .claude/skills/video-craft/engine/src/index.ts"
OUTDIR="TESTS/videos/output"
FRAMEDIR="TESTS/videos/frames"

cd /home/uh1/Vibe_Projects/CLAUDE_SKILLS

echo "=== Starting video renders at $(date) ==="

# Render videos sequentially (parallel renders would overwhelm system)
for i in 01 02 03 04 05 06 07 08 09 10; do
  HTML=$(ls TESTS/videos/v${i}-*.html 2>/dev/null | head -1)
  if [ -n "$HTML" ]; then
    name=$(basename "$HTML" .html)
    MP4="$OUTDIR/${name}.mp4"
    
    if [ -f "$MP4" ]; then
      echo "[v${i}] Already exists: $MP4, skipping render"
    else
      echo "[v${i}] Rendering $HTML..."
      $ENGINE render "$HTML" 2>&1 | tail -5
      echo "[v${i}] Done: $MP4"
    fi
    
    # Extract frames at 2fps for analysis
    if [ -f "$MP4" ]; then
      mkdir -p "$FRAMEDIR/$name"
      echo "[v${i}] Extracting frames at 2fps..."
      ffmpeg -y -i "$MP4" -vf "fps=2" -q:v 2 "$FRAMEDIR/$name/frame_%04d.jpg" 2>/dev/null
      count=$(ls "$FRAMEDIR/$name"/*.jpg 2>/dev/null | wc -l)
      echo "[v${i}] Extracted $count frames"
    fi
  fi
done

echo ""
echo "=== All renders and extractions complete at $(date) ==="
