# Spec: Emmet Test — Polyglot-You E2E Patterns

**Data:** 2026-03-06
**Tipo:** Feature improvement
**Stato:** In attesa PROCEED

---

## Cosa sto facendo

Integro i pattern e2e collaudati in polyglot-you nel comando `/emmet test --browser`, mantenendo la functional map come source of truth per **cosa** testare ma adottando l'architettura di polyglot-you per **come** testare.

---

## Pattern da integrare

### 1. Worker-Scoped Fixture (single-window)
Un unico BrowserContext riusato tra tutti i test. Drasticamente piu veloce (30s vs 4min). La page viene riusata, il viewport resettato tra test.

### 2. Auth Session Caching
`global-setup.ts` con session file (`.auth/session.json`) e TTL 24h. Evita re-login ad ogni run. Supporta credenziali via env var.

### 3. Environment Targeting
`E2E_TARGET=production` per switchare tra local dev e produzione. Config Playwright condizionale (webServer solo in dev).

### 4. Helper Functions
- `waitForPage()` — networkidle + hydration check (body.innerText > threshold)
- `apiFetch()` — API call dal contesto browser (eredita auth cookies)
- `screenshot()` — wrapper con naming convention consistente

### 5. Report Markdown via Hooks
`afterEach` hook che genera report.md in tempo reale:
- PASS/FAIL con durata per ogni test
- Screenshot automatico su failure
- Summary finale con conteggi
- Lista issues trovati

### 6. Test Parametrizzati
Loop su array di dati (es. corsi, utenti, ruoli) per generare test identici su dataset diversi. Dalla map: ogni entita ripetuta diventa un parametro.

### 7. API Testing In-Browser
`apiFetch()` per testare endpoint API direttamente dal browser, ereditando cookies/auth. ~30% dei test possono essere API-only (data integrity).

### 8. Responsive Testing
Viewport espliciti per mobile (375x812) e tablet (768x1024) come test group dedicato.

### 9. Error/Edge Case Testing
Gruppo dedicato per 404, bad params, missing data, unauthorized access.

### 10. Inspect Script
Script standalone per debug/esplorazione: naviga pagine, cattura screenshot, logga console errors, network errors, conta elementi.

---

## File da toccare

| File | Cosa cambia |
|------|-------------|
| `testing/dynamic.md` | Riscrittura: aggiunge fixture pattern, helpers, report hooks, API testing, responsive, error testing, inspect script |
| `prompts/test.md` | Aggiorna step 3 (browser test) per usare i nuovi pattern; aggiunge generazione config e helpers |
| `testing/report-template.md` | Aggiorna per allinearsi al report via hooks (afterEach) |

---

## Cosa NON cambia

- **functional-map.md** resta la source of truth (cosa testare)
- **static.md** e **unit.md** invariati
- **SKILL.md** non tocco (i trigger/routing sono corretti)
- La map continua a guidare i use case; i pattern polyglot-you definiscono solo l'architettura dei test generati

---

## Come verifico

1. Leggo i file modificati e verifico coerenza interna
2. I pattern sono template/istruzioni per Claude, non codice eseguibile nel framework
3. Verifico che `/emmet test --browser` nel prompt generi test con i nuovi pattern
