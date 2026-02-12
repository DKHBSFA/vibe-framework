// Parallel scene rendering: split video into segments, render each in a separate
// Playwright instance, then concatenate with FFmpeg.
// Speedup is near-linear with core count (2-4x typical).

import { cpus } from 'os';
import { resolve, dirname } from 'path';
import { mkdirSync, writeFileSync, existsSync, unlinkSync } from 'fs';
import { spawn } from 'child_process';
import { initCapture, captureFrames, closeCapture, type CaptureOptions } from './capture.js';
import { startEncoder } from './encode.js';
import type { CodecId, CodecPreset } from './presets.js';

export interface SceneSegment {
  sceneIndex: number;
  startFrame: number;
  endFrame: number;
  startMs: number;
  endMs: number;
}

export interface ParallelRenderOptions {
  htmlPath: string;
  width: number;
  height: number;
  fps: number;
  totalFrames: number;
  totalDurationMs: number;
  codec: CodecId;
  outputPath: string;
  codecOverride?: CodecPreset;
  /** Scene boundaries in frames */
  scenes: SceneSegment[];
  onProgress?: (completed: number, total: number) => void;
}

/**
 * Determine optimal worker count based on system resources and scene count.
 */
function getWorkerCount(sceneCount: number): number {
  const cpuCount = cpus().length;
  return Math.min(sceneCount, Math.floor(cpuCount / 2), 4);
}

/**
 * Render a single segment (range of frames) to a temporary video file.
 */
async function renderSegment(
  htmlPath: string,
  segment: SceneSegment,
  width: number,
  height: number,
  fps: number,
  codec: CodecId,
  outputPath: string,
  codecOverride?: CodecPreset,
): Promise<void> {
  const frameCount = segment.endFrame - segment.startFrame;
  const frameDurationMs = 1000 / fps;

  const session = await initCapture({
    width, height, fps,
    totalFrames: frameCount,
    htmlPath,
  });

  const encoder = startEncoder({
    fps,
    codec,
    outputPath,
    codecOverride,
    useHardwareAccel: false, // segments use software for reliability
  });

  // Capture frames for this segment's time range
  for (let f = 0; f < frameCount; f++) {
    const globalFrame = segment.startFrame + f;
    const timeMs = globalFrame * frameDurationMs;

    await session.page.evaluate((t) => {
      document.getAnimations().forEach(a => { a.currentTime = t; });
    }, timeMs);

    await session.page.waitForTimeout(5);

    const buffer = await session.page.screenshot({ type: 'jpeg', quality: 100 });
    await encoder.write(buffer as Buffer);
  }

  await closeCapture(session);
  await encoder.finish();
}

/**
 * Concatenate video segments using FFmpeg concat demuxer.
 */
async function concatSegments(segmentPaths: string[], outputPath: string): Promise<void> {
  const listPath = outputPath.replace(/\.mp4$/, '-concat.txt');
  const listContent = segmentPaths.map(p => `file '${p}'`).join('\n');
  writeFileSync(listPath, listContent);

  return new Promise((resolve, reject) => {
    const proc = spawn('ffmpeg', [
      '-y',
      '-f', 'concat',
      '-safe', '0',
      '-i', listPath,
      '-c', 'copy',
      outputPath,
    ], { stdio: ['pipe', 'pipe', 'pipe'] });

    proc.on('close', (code) => {
      // Clean up concat list
      try { unlinkSync(listPath); } catch {}
      if (code === 0) resolve();
      else reject(new Error(`FFmpeg concat exited with code ${code}`));
    });
  });
}

/**
 * Render video using parallel Playwright workers.
 * Falls back to sequential rendering if only 1 worker is needed.
 */
export async function renderParallel(opts: ParallelRenderOptions): Promise<void> {
  const workerCount = getWorkerCount(opts.scenes.length);

  // Not enough scenes for parallel — fall back
  if (workerCount <= 1) {
    return; // caller should use sequential render
  }

  const tmpDir = resolve(dirname(opts.outputPath), '.parallel-tmp');
  if (!existsSync(tmpDir)) mkdirSync(tmpDir, { recursive: true });

  console.log(`  Parallel render: ${workerCount} workers for ${opts.scenes.length} scenes`);

  const segmentPaths: string[] = [];
  let completedSegments = 0;

  // Process scenes in batches of workerCount
  for (let i = 0; i < opts.scenes.length; i += workerCount) {
    const batch = opts.scenes.slice(i, i + workerCount);
    const batchPromises = batch.map((scene, batchIdx) => {
      const segPath = resolve(tmpDir, `segment-${String(i + batchIdx).padStart(3, '0')}.mp4`);
      segmentPaths.push(segPath);

      return renderSegment(
        opts.htmlPath,
        scene,
        opts.width,
        opts.height,
        opts.fps,
        opts.codec,
        segPath,
        opts.codecOverride,
      ).then(() => {
        completedSegments++;
        opts.onProgress?.(completedSegments, opts.scenes.length);
      });
    });

    await Promise.all(batchPromises);
  }

  // Concatenate all segments
  console.log('  Concatenating segments...');
  await concatSegments(segmentPaths, opts.outputPath);

  // Clean up temp directory
  try {
    const { rmSync } = await import('fs');
    rmSync(tmpDir, { recursive: true });
  } catch {}
}

/**
 * Build scene segments from timeline scene data.
 * Each scene becomes a segment defined by its frame range.
 */
export function buildSceneSegments(
  scenes: Array<{ startMs: number; durationMs: number }>,
  fps: number,
): SceneSegment[] {
  return scenes.map((scene, i) => {
    const startFrame = Math.floor(scene.startMs / 1000 * fps);
    const endFrame = Math.ceil((scene.startMs + scene.durationMs) / 1000 * fps);
    return {
      sceneIndex: i,
      startFrame,
      endFrame,
      startMs: scene.startMs,
      endMs: scene.startMs + scene.durationMs,
    };
  });
}
