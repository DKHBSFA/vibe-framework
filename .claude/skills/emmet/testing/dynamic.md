# Dynamic Testing with Playwright

## Architecture

Test browser con architettura **single-window**: un unico BrowserContext riusato tra tutti i test, una sola page, esecuzione sequenziale, zero retries.

**Perche funziona meglio del default:**

| Default Playwright | Single-Window |
|---|---|
| Nuovo context per ogni test | 1 context per worker, page riusata |
| Parallel execution | Sequential (piu veloce con 1 context) |
| `retries: 2` nasconde test flaky | `retries: 0` forza il fix |
| 4+ minuti per 50 test | ~30 secondi per 50 test |

La velocita viene dal non creare/distruggere browser context. Il viewport si resetta tra test, lo stato auth persiste.

---

## File Structure

Quando Emmet genera test browser, crea questa struttura nel progetto target:

```
e2e/
  fixtures.ts              # Worker-scoped single-window fixture
  helpers.ts               # waitForPage, apiFetch, screenshot
  global-setup.ts          # Auth session caching (solo se map ha auth UC)
  inspect.ts               # Script debug standalone (opzionale)
  screenshots/             # Screenshot catturati durante i test
  .auth/
    session.json           # Sessione auth cached (gitignored)
  tests/
    [area-1].spec.ts       # Test per area funzionale (dalla map)
    [area-2].spec.ts
    ...
playwright.config.ts       # Config nella root del progetto
```

**IMPORTANTE:** `.auth/` va aggiunto a `.gitignore`.

---

## Worker-Scoped Single-Window Fixture

`e2e/fixtures.ts` — il cuore dell'architettura. Tutti i test importano da qui, **mai** da `@playwright/test` direttamente.

```typescript
import { test as base, expect, Page, BrowserContext } from "@playwright/test";

const VIEWPORT = { width: 1280, height: 900 };

export const test = base.extend<{}, { workerContext: BrowserContext }>({
  workerContext: [
    async ({ browser }, use) => {
      const ctx = await browser.newContext({
        viewport: VIEWPORT,
        // Se auth session esiste, caricala
        ...(fs.existsSync(AUTH_FILE) && { storageState: AUTH_FILE }),
      });
      await use(ctx);
      await ctx.close();
    },
    { scope: "worker" },
  ],

  // Override default context/page per riusare quelli del worker
  context: async ({ workerContext }, use) => {
    await use(workerContext);
  },

  page: async ({ workerContext }, use) => {
    const pages = workerContext.pages();
    const page = pages[0] || (await workerContext.newPage());
    await page.setViewportSize(VIEWPORT); // Reset tra test
    await use(page);
  },
});

export { expect };
```

**Meccanica:**
- `workerContext` ha scope `"worker"` — creato una volta, condiviso tra tutti i test
- `context` e `page` sono override dei fixture default di Playwright
- `page` riusa la pagina esistente (o ne crea una se e la prima)
- `setViewportSize()` resetta il viewport nel caso un test precedente l'abbia cambiato (es. test responsive)

---

## Auth Session Caching

`e2e/global-setup.ts` — esegue il login una volta sola, salva la sessione, la riusa per 24h.

**Genera questo file SOLO se la functional map contiene use case di autenticazione.**

```typescript
import { chromium, type FullConfig } from "@playwright/test";
import fs from "fs";
import path from "path";

const BASE = process.env.E2E_TARGET === "production"
  ? "https://PRODUCTION_URL"    // <-- dal progetto target
  : "http://localhost:PORT";     // <-- dal progetto target

// Credenziali da env var con fallback
const EMAIL = process.env.E2E_EMAIL ?? "test@example.com";
const PASSWORD = process.env.E2E_PASSWORD ?? "testpassword";

export const AUTH_FILE = path.join(__dirname, ".auth/session.json");
const MAX_AGE_MS = 24 * 60 * 60 * 1000; // 24h

function isSessionFresh(): boolean {
  try {
    return Date.now() - fs.statSync(AUTH_FILE).mtimeMs < MAX_AGE_MS;
  } catch {
    return false;
  }
}

async function globalSetup(_config: FullConfig) {
  // Inizializza report
  const reportPath = path.join(__dirname, "report.md");
  const now = new Date().toLocaleString();
  fs.writeFileSync(reportPath, `# E2E Report — ${now}\n\n---\n\n`);

  // Riusa sessione se fresca
  if (isSessionFresh()) {
    console.log("Reusing existing session (< 24h old)");
    return;
  }

  console.log("Running auth flow...");
  fs.mkdirSync(path.dirname(AUTH_FILE), { recursive: true });

  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();

  // --- ADATTARE AL FLUSSO AUTH DEL PROGETTO TARGET ---
  await page.goto(`${BASE}/login`);
  await page.fill('[name="email"]', EMAIL);
  await page.fill('[name="password"]', PASSWORD);
  await page.click('button[type="submit"]');
  await page.waitForURL("**/dashboard/**", { timeout: 15000 });
  // --- FINE SEZIONE DA ADATTARE ---

  await page.context().storageState({ path: AUTH_FILE });
  console.log("Session saved");
  await browser.close();
}

export default globalSetup;
```

**Adattamento al progetto target:**
- URL base (produzione e locale)
- Selectors del form login (dipende dall'UI del progetto)
- URL di redirect post-login
- Provider auth (Clerk, NextAuth, Supabase, custom) — il flusso cambia
- Credenziali di default

---

## Environment Targeting

Pattern per testare sia in locale che in produzione con una sola config.

```typescript
// playwright.config.ts
const isProduction = process.env.E2E_TARGET === "production";

export default defineConfig({
  // ... (vedi Config Reference sotto)
  use: {
    baseURL: isProduction ? "https://PRODUCTION_URL" : "http://localhost:PORT",
    // ...
  },
  // webServer SOLO in locale — avvia il dev server automaticamente
  ...(!isProduction && {
    webServer: {
      command: "npm run dev",  // <-- adattare allo stack del progetto
      url: "http://localhost:PORT",
      reuseExistingServer: true,
      timeout: 30000,
    },
  }),
});
```

**Adattamento allo stack:**

| Stack | `webServer.command` | Note |
|-------|---------------------|------|
| Next.js | `npx next dev` | Aggiungere `NODE_ENV=test` se serve |
| Vite/React | `npx vite` | Default port 5173 |
| Express/Node | `node server.js` | O `npm run dev` se usa nodemon |
| SvelteKit | `npx vite dev` | |
| Altro | `npm run dev` | Leggere `package.json` scripts |

**Uso:**
```bash
# Locale (avvia dev server automaticamente)
npx playwright test

# Produzione
E2E_TARGET=production npx playwright test
```

---

## Helper Functions

`e2e/helpers.ts` — utility condivise da tutti i test file.

### waitForPage

Attende che la pagina sia completamente caricata e idratata. Piu affidabile di `waitForLoadState('networkidle')` da solo.

```typescript
export async function waitForPage(page: Page, timeout = 15000) {
  await page.waitForLoadState("networkidle", { timeout });
  // Verifica che il contenuto sia effettivamente renderizzato
  await page.waitForFunction(
    () => document.body.innerText.length > 100,
    { timeout: 10000 }
  );
}
```

**Adattamento al framework:**
- **SPA (React, Vue, Svelte):** `innerText.length > 100` funziona bene
- **SSR (Next.js, Nuxt):** Aggiungere check hydration (es. `__NEXT_DATA__` presente)
- **MPA tradizionale:** `networkidle` puo bastare da solo

### apiFetch

Chiama API dal contesto browser, ereditando cookie e sessione auth. Permette di testare endpoint API senza client HTTP separato.

```typescript
export async function apiFetch(
  page: Page,
  method: "GET" | "POST" | "PUT" | "DELETE",
  urlPath: string,
  body?: Record<string, unknown>
): Promise<{ status: number; body: any }> {
  return page.evaluate(
    async ({ method, path, body }) => {
      const opts: RequestInit = {
        method,
        headers: { "Content-Type": "application/json" },
      };
      if (body) opts.body = JSON.stringify(body);
      const r = await fetch(path, opts);
      const text = await r.text();
      let parsed;
      try { parsed = JSON.parse(text); } catch { parsed = text; }
      return { status: r.status, body: parsed };
    },
    { method, path: urlPath, body }
  );
}
```

**Uso tipico:** Verificare data integrity dopo un'azione UI, testare endpoint direttamente, validare risposte API.

### screenshot

Screenshot full-page con naming consistente.

```typescript
export async function screenshot(page: Page, name: string) {
  await page.screenshot({
    path: path.join(__dirname, "screenshots", `${name}.png`),
    fullPage: true,
  });
}
```

**Naming convention:**
- Feature state: `[feature]-[entity].png` (es. `dashboard-course-1.png`)
- Failure: `fail-[N].png` (generato automaticamente dall'afterEach hook)

---

## Report Real-Time via Hooks

Ogni test file include hooks `afterEach`/`afterAll` che generano il report durante l'esecuzione, non dopo.

```typescript
import fs from "fs";
import path from "path";

const REPORT_PATH = path.join(__dirname, "report.md");
const SCREENSHOT_DIR = path.join(__dirname, "screenshots");

let passCount = 0;
let failCount = 0;
const issues: string[] = [];

function reportAppend(line: string) {
  fs.appendFileSync(REPORT_PATH, line + "\n");
}

test.afterEach(async ({ page }, testInfo) => {
  const title = testInfo.titlePath.join(" > ");
  const duration = `${(testInfo.duration / 1000).toFixed(1)}s`;

  if (testInfo.status === "passed") {
    passCount++;
    reportAppend(`- PASS ${title} (${duration})`);
  } else {
    failCount++;
    const screenshotName = `fail-${failCount}`;
    try {
      await page.screenshot({
        path: path.join(SCREENSHOT_DIR, `${screenshotName}.png`),
        fullPage: true,
      });
    } catch { /* page may be closed */ }

    const errorMsg = testInfo.error?.message?.split("\n")[0] ?? "unknown error";
    reportAppend(`\n### FAIL #${failCount}: ${title}`);
    reportAppend(`- **Durata:** ${duration}`);
    reportAppend(`- **Errore:** \`${errorMsg}\``);
    reportAppend(`- **Screenshot:** ![${screenshotName}](screenshots/${screenshotName}.png)`);
    reportAppend("");

    issues.push(`${title}: ${errorMsg}`);
  }
});

test.afterAll(() => {
  reportAppend("\n---\n");
  reportAppend("## Summary\n");
  reportAppend("| | Count |");
  reportAppend("|---|---|");
  reportAppend(`| Passed | ${passCount} |`);
  reportAppend(`| Failed | ${failCount} |`);
  reportAppend(`| Total | ${passCount + failCount} |`);

  if (issues.length > 0) {
    reportAppend("\n## Issues Found\n");
    for (const issue of issues) {
      reportAppend(`- ${issue}`);
    }
  }
});
```

**Il report e inizializzato in `global-setup.ts`** (header con data/ora e target URL). Ogni test file appende i suoi risultati.

---

## Test Organization — Dalla Map ai Test

La functional map guida **cosa** testare. Questa sezione definisce **come** organizzare i test.

### Map -> Test Groups

| Elemento nella map | Tipo di test generato |
|---|---|
| Use case (UC-001, UC-002...) | Flow test: sequenza di azioni dal flusso principale |
| UC con flussi alternativi | Test case separati per ogni flusso alternativo |
| Entita ripetute (N corsi, N prodotti, N utenti) | Test parametrizzati con `for` loop |
| API endpoints | `apiFetch()` test per data integrity |
| Note "responsive" nella map | Gruppo dedicato con viewport mobile/tablet |
| Error flows nella map | Gruppo dedicato per 404, bad params, unauthorized |

### Test Parametrizzati

Quando la map contiene entita ripetute (es. N corsi, N categorie), generare test parametrizzati:

```typescript
// Entita estratte dalla map
const ENTITIES = [
  { id: "entity-1", name: "First Entity", expectedField: "value1" },
  { id: "entity-2", name: "Second Entity", expectedField: "value2" },
  // ...
] as const;

test.describe("Entity pages", () => {
  for (const entity of ENTITIES) {
    test(`${entity.name} -- page loads correctly`, async ({ page }) => {
      await page.goto(`/entities/${entity.id}`);
      await waitForPage(page);

      await expect(page.getByRole("heading")).toContainText(entity.name);
      await screenshot(page, `entity-${entity.id}`);
    });
  }
});
```

### API Testing In-Browser

Per endpoint nella map, testare data integrity direttamente:

```typescript
test.describe("API integrity", () => {
  test("GET /api/entities returns valid data", async ({ page }) => {
    await page.goto("/"); // Necessario per avere il contesto browser
    const res = await apiFetch(page, "GET", "/api/entities");

    expect(res.status).toBe(200);
    expect(res.body).toBeInstanceOf(Array);
    expect(res.body.length).toBeGreaterThan(0);

    // Validazione struttura
    for (const item of res.body) {
      expect(item.id).toBeTruthy();
      expect(item.name).toBeTruthy();
    }
  });
});
```

### Responsive Testing

Gruppo dedicato con viewport espliciti:

```typescript
test.describe("Responsive", () => {
  test("mobile layout (375x812)", async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 });
    await page.goto("/");
    await waitForPage(page);

    // Verificare hamburger menu, layout stacked, etc.
    await screenshot(page, "mobile-home");
  });

  test("tablet layout (768x1024)", async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.goto("/");
    await waitForPage(page);

    await screenshot(page, "tablet-home");
  });
});
```

### Error/Edge Case Testing

```typescript
test.describe("Error handling", () => {
  test("404 for non-existent page", async ({ page }) => {
    const res = await page.goto("/non-existent-page-xyz");
    // Verificare 404 page o redirect
  });

  test("API with bad params returns error", async ({ page }) => {
    await page.goto("/");
    const res = await apiFetch(page, "GET", "/api/entities/non-existent");
    expect(res.status).toBe(404);
  });
});
```

---

## Selectors Strategy

### Ordine di priorita

1. `data-testid` — Esplicito per testing, non si rompe con cambi di stile
2. `role` + name — Basato su accessibilita
3. `text` — Contenuto visibile all'utente
4. `css` — Ultimo resort

### Esempi

```typescript
// Preferito: data-testid
page.locator('[data-testid="submit-button"]')

// Buono: role + name
page.getByRole('button', { name: 'Submit' })

// Buono: testo visibile
page.getByText('Submit')

// Evitare: selettori fragili
page.locator('.btn-primary.mt-4')       // Si rompe con cambio stile
page.locator('#app > div > div:nth-child(3)') // Si rompe con cambio struttura
```

---

## Inspect Script

Script standalone per debug ed esplorazione. **Non fa parte della pipeline di test.** Utile per capire la struttura di una pagina prima di scrivere test.

```typescript
// e2e/inspect.ts — eseguire con: npx tsx e2e/inspect.ts
import { chromium } from "playwright";

async function inspect() {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();

  await page.goto("http://localhost:PORT/");
  await page.waitForLoadState("networkidle");

  // Logga struttura pagina
  const text = await page.locator("body").innerText();
  console.log("Page text length:", text.length);
  console.log("Headers:", await page.locator("h1, h2, h3").allInnerTexts());
  console.log("Links:", await page.locator("a").count());
  console.log("Buttons:", await page.locator("button").count());
  console.log("Forms:", await page.locator("form").count());

  // Cattura console errors
  page.on("console", msg => {
    if (msg.type() === "error") console.log("CONSOLE ERROR:", msg.text());
  });

  // Screenshot
  await page.screenshot({ path: "e2e/screenshots/inspect.png", fullPage: true });

  await browser.close();
}

inspect();
```

**Quando usarlo:** Prima di scrivere test per una pagina sconosciuta, per catturare errori console, per verificare che gli elementi attesi esistano.

---

## Config Reference

```typescript
// playwright.config.ts (root del progetto target)
import { defineConfig } from "@playwright/test";

const isProduction = process.env.E2E_TARGET === "production";

export default defineConfig({
  testDir: "./e2e/tests",
  fullyParallel: false,         // Sequential: piu veloce con single-window
  forbidOnly: !!process.env.CI,
  retries: 0,                   // No retries: trova i test flaky, non nasconderli
  workers: 1,                   // Single worker: un context per tutti i test
  timeout: 60000,               // 60s per test (generoso per pagine lente)
  reporter: [["html", { open: "never" }], ["list"]],
  globalSetup: "./e2e/global-setup.ts",

  use: {
    baseURL: isProduction
      ? "https://PRODUCTION_URL"    // <-- adattare
      : "http://localhost:PORT",     // <-- adattare
    screenshot: "only-on-failure",
    trace: "retain-on-failure",
    viewport: { width: 1280, height: 900 },
    headless: false,
  },

  projects: [
    {
      name: "chromium",
      use: { browserName: "chromium" },
    },
  ],

  // Dev server: solo in locale
  ...(!isProduction && {
    webServer: {
      command: "npm run dev",     // <-- adattare allo stack
      url: "http://localhost:PORT",
      reuseExistingServer: true,
      timeout: 30000,
    },
  }),
});
```

**Perche queste scelte:**
- `fullyParallel: false` + `workers: 1` — Con single-window fixture, sequential e piu veloce di parallel (niente overhead creazione context)
- `retries: 0` — I retries nascondono test flaky. Meglio trovarli e fixarli
- `headless: false` — Claude vede i fallimenti. In CI, sovrascrivere con `headless: true`
- Single browser (chromium) — Sufficiente per test funzionali. Cross-browser testing e un concern separato
- `screenshot: only-on-failure` — Riduce spazio disco, i pass non servono screenshot

---

## BrowserMCP Backend

**Playwright e il backend default.** Se il progetto ha BrowserMCP configurato come MCP server, puo essere usato come alternativa per **visual assertions**.

### Auto-detection

```
1. Verifica se MCP server `browser` e disponibile
2. Se si → usa BrowserMCP per test che richiedono validazione visiva
3. Se no → Playwright (default)
```

### Quando usare BrowserMCP

| Scenario | Backend |
|----------|---------|
| Test funzionali, regression, CI/CD | Playwright |
| Visual regression, UX validation | BrowserMCP |
| Test rapidi durante sviluppo | Playwright |
| Debugging interattivo | BrowserMCP |

BrowserMCP e complementare: Claude "vede" la pagina e puo fare assertions visive che Playwright non supporta (es. "il layout sembra corretto", "i colori sono consistenti"). Ma non genera report via hooks e non supporta la fixture single-window.

---

## Completeness Checklist

**Dopo aver letto la functional map**, consultare queste tabelle per verificare di non aver dimenticato categorie di test. Se la map non copre una categoria rilevante per il progetto, aggiungere test specifici.

### User Flows

| Flow | Cosa testare |
|------|-------------|
| Authentication | Login, logout, password reset, session expiry |
| Registration | Signup, email verification, profile setup |
| Navigation | Menu, breadcrumbs, deep links, back button |
| Forms | Validation, submission, error display |
| Search | Query, filters, results, pagination |
| CRUD | Create, read, update, delete di entita |

### UI Interactions

| Interaction | Cosa verificare |
|-------------|----------------|
| Click | Elemento risponde, stato cambia |
| Hover | Tooltip, dropdown appaiono |
| Focus | Navigazione tastiera funziona |
| Scroll | Infinite scroll, lazy load |
| Drag & Drop | Elementi si spostano correttamente |
| Resize | Comportamento responsive |

### State Management

| Stato | Cosa verificare |
|-------|----------------|
| Loading | Spinner, skeleton visibili |
| Empty | Empty state mostrato correttamente |
| Error | Messaggi errore visibili |
| Success | Feedback successo appare |
| Offline | Gestione offline funziona (se applicabile) |
