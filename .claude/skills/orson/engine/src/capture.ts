// Playwright frame capture with Web Animations API time control
// CSS animations are paused, then currentTime is set per frame for deterministic capture.

import { chromium, type Page, type Browser, type BrowserContext } from 'playwright';

export type CaptureFormat = 'png' | 'jpeg';

export interface CaptureOptions {
  width: number;
  height: number;
  fps: number;
  totalFrames: number;
  htmlPath: string;
  /** Frame capture format: 'jpeg' is ~2x faster than 'png' (default: 'jpeg') */
  captureFormat?: CaptureFormat;
  onFrame?: (frame: number, total: number) => void;
}

export interface CaptureSession {
  browser: Browser;
  context: BrowserContext;
  page: Page;
}

export async function initCapture(opts: CaptureOptions): Promise<CaptureSession> {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: opts.width, height: opts.height },
    deviceScaleFactor: 1,
  });
  const page = await context.newPage();

  // Set render flag BEFORE page loads — this prevents the preview controller
  // from executing (it checks window.__VIDEO_RENDER__ and skips if true)
  await page.addInitScript(() => {
    (window as any).__VIDEO_RENDER__ = true;
  });

  // Load the generated HTML
  await page.goto(`file://${opts.htmlPath}`, { waitUntil: 'load' });

  // Let fonts/styles settle
  await page.waitForTimeout(100);

  // Pause all CSS animations — we'll control time manually via Web Animations API
  await page.evaluate(() => {
    document.getAnimations().forEach(a => a.pause());
  });

  return { browser, context, page };
}

export async function captureFrames(
  session: CaptureSession,
  opts: CaptureOptions,
  writeFn: (buffer: Buffer) => Promise<void>,
): Promise<void> {
  const frameDurationMs = 1000 / opts.fps;

  for (let frame = 0; frame < opts.totalFrames; frame++) {
    const timeMs = frame * frameDurationMs;

    // Set all animations to this point in time
    // Also sync any PiP <video> elements to the same timestamp
    await session.page.evaluate((t) => {
      document.getAnimations().forEach(a => { a.currentTime = t; });
      // Sync PiP video elements
      document.querySelectorAll('video[data-pip]').forEach(v => {
        const video = v as HTMLVideoElement;
        const timeSec = t / 1000;
        if (timeSec <= video.duration) {
          video.currentTime = timeSec;
        }
      });
    }, timeMs);

    // Brief wait for the browser to repaint
    await session.page.waitForTimeout(5);

    const fmt = opts.captureFormat ?? 'jpeg';
    const buffer = await session.page.screenshot(
      fmt === 'jpeg' ? { type: 'jpeg', quality: 100 } : { type: 'png' },
    );
    await writeFn(buffer as Buffer);

    opts.onFrame?.(frame + 1, opts.totalFrames);
  }
}

export async function closeCapture(session: CaptureSession): Promise<void> {
  await session.browser.close();
}
