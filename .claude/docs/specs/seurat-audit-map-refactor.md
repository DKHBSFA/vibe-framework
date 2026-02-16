# Spec: Seurat Audit/Map Refactor

**Data:** 2026-02-16
**Stato:** completato

---

## Cosa

Riorganizzare i comandi di audit, analisi e migrazione di Seurat: allineare alla convenzione Emmet (`audit` + `map`), definire il processo audit completo basato sull'esempio JOUELRY, consolidare i comandi di migrazione, pulire validation.md.

---

## Modifiche

### 1. Rinominare `analyze-project` → `map`

- `/seurat map` — mappa strutturale del progetto (archetipi UI)
  - Classifica pagine per archetipo (Entry, Discovery, Detail, Action, Management, System)
  - Inventario elementi UI per pagina
  - Mappa routes → archetipi
- Output: `.seurat/project-map.md` (invariato)
- **Non scopre le pagine** — usa la mappa di `/emmet map` come fonte per la lista pagine/route
- **Prerequisito:** `/emmet map` deve esistere. Se manca, proporre all'utente di eseguirlo.

### 2. Consolidare `/seurat audit`

- `/seurat audit` → audit completo del progetto (tutte le pagine)
- `/seurat audit [file]` → audit mirato su file singolo (scope ridotto, vedi §5.2)

### 3. Consolidare `/seurat migrate`

- `/seurat migrate` (senza argomenti) → migrazione completa del progetto ai token del design system
  - Controlla prerequisiti (tokens.css)
  - Crea piano prioritizzato (Foundation → Global → Critical paths → Secondary → Admin)
  - Guida migrazione file per file con tracker
  - Include status check del progresso
- `/seurat migrate [pattern]` → migra un pattern specifico nel codebase con tracker

### 4. Comandi da rimuovere/riassorbire

| Comando attuale | Destino |
|---|---|
| `/seurat analyze-project` | → `/seurat map` |
| `/seurat compliance` | → parte di `/seurat audit` |
| `/seurat migrate-project` | → `/seurat migrate` |
| `/seurat migration-status` | → parte di `/seurat migrate` (status automatico) |

### 5. Processo audit completo (`/seurat audit`)

Basato sull'audit JOUELRY (`.claude/docs/specs/references/audit-esempio.md`). Tre fasi:

#### Fase 0: Prerequisiti

| Prerequisito | Obbligatorio | Comportamento se manca |
|---|---|---|
| `/emmet map` (mappa pagine/route) | Sì | Proporre all'utente: "Serve la mappa delle pagine. Eseguo `/emmet map`?" (o `/emmet map update` se esiste ma è vecchia) |
| `.seurat/tokens.css` | No | L'audit funziona solo per le aree che non richiedono confronto con token. Le aree che richiedono compliance (Layout & Spacing, Color System) segnalano "no design system definito — impossibile verificare compliance" |
| Dev server attivo | Sì (per screenshot) | Controllare se c'è già un server attivo sulla porta del progetto. Se no, avviarlo. Se impossibile, skip screenshot e segnalare nelle limitazioni |

#### Fase 1: Raccolta dati

| Fonte | Cosa | Come |
|---|---|---|
| Codice sorgente | Token definiti vs valori hardcoded, spacing, padding, gap, colori, font | Grep + lettura file CSS/SCSS/TSX |
| Screenshot Playwright | Rendering reale a 3 viewport | Desktop 1440x900 (light + dark), Mobile 390x844, Zoom sezioni critiche |
| Audit automatico | Contrasto WCAG, touch target, aria attributes | Lighthouse / axe-core se disponibili |

**Screenshot:**
- Salvati in `.seurat/screenshots/`
- Naming: `[##]-[page-name]-[viewport]-[theme].png`
  - Viewport: `desktop`, `mobile`
  - Theme: `light`, `dark`
  - Esempio: `01-home-desktop-light.png`, `01-home-mobile-light.png`, `01-home-desktop-dark.png`
- Zoom sezioni: `zoom-[page]-[section].png`
  - Esempio: `zoom-home-header.png`, `zoom-search-cards-row1.png`
- Lista pagine da screenshottare: ricavata da `/emmet map`

#### Fase 2: Aree di analisi

##### 5.1 Audit completo (`/seurat audit`)

| # | Area | Cosa verifica | Condizionale |
|---|---|---|---|
| 1 | Visual Design & Brand | Identità coerente, no AI slop, Mandate tests (Swap, Squint, Signature, Token) | Sempre |
| 2 | Layout & Spacing | Spacing scale rispettata, card padding coerente, grid gap standardizzati, allineamento contenuto, vertical rhythm | Sempre |
| 3 | Typography | Gerarchia, scale coerente, regole serif/sans chiare | Sempre |
| 4 | Color System | Palette coerente, contrasto WCAG >= 4.5:1, color-only indicators | Sempre |
| 5 | Responsive/Mobile | Padding orizzontale coerente, layout collapse corretto, pagine non infinite | Sempre |
| 6 | Accessibility | Skip-to-content, aria-invalid/errormessage, aria-label, focus ring, keyboard navigation, tab order, focus trap, Escape key | Sempre |
| 7 | Forms & Interaction | Campi obbligatori indicati, validazione real-time, feedback errori/successo/loading, stati vuoti/errore | Sempre |
| 8 | Navigation & IA | Link coerenti, naming URL-consistent, sticky sidebar se necessario | Sempre |
| 9 | Data Visualization | Palette chart unificata, aria-label, data table fallback | Solo se il progetto ha chart/grafici |
| 10 | Dark Mode | Contrasto bordi, warm tones, accents leggibili, no neon | Solo se il progetto ha dark mode |
| 11 | Flussi interattivi | Submit form, loading states, modali, toast, wizard multi-step, skeleton loading | Sempre |
| 12 | Internazionalizzazione | RTL layout, lingue lunghe (overflow/troncamento) | Solo se il progetto supporta i18n |
| 13 | Performance percepita | LCP, CLS, pagine lunghe, lazy loading | Sempre |

##### 5.2 Audit singolo file (`/seurat audit [file]`)

Scope ridotto — solo le aree applicabili a un singolo componente/pagina:

| # | Area | Applicabile |
|---|---|---|
| 1 | Visual Design & Brand | Sì |
| 2 | Layout & Spacing | Sì |
| 3 | Typography | Sì |
| 4 | Color System | Sì |
| 5 | Responsive/Mobile | Sì |
| 6 | Accessibility | Sì |
| 7 | Forms & Interaction | Se il file contiene form |
| 8 | Navigation & IA | No |
| 9 | Data Visualization | Se il file contiene chart |
| 10 | Dark Mode | Se il progetto ha dark mode |
| 11 | Flussi interattivi | Se il file contiene stati interattivi |
| 12 | Internazionalizzazione | No |
| 13 | Performance percepita | No |

#### Fase 3: Output

Report strutturato in `.seurat/audit-report.md`:

1. **Executive Summary** — Voto per area (1-10), valutazione complessiva
2. **CRITICAL** — Problemi ad alto impatto (bloccano UX)
3. **HIGH** — Problemi significativi
4. **MEDIUM** — Miglioramenti importanti
5. **LOW** — Polish e refinement
6. **Spacing granulare** — Tabelle comparative codice vs design system (come sezione 8 dell'esempio)
7. **Accessibility findings** — Sezione dedicata
8. **Dark mode findings** — Sezione dedicata (se applicabile)
9. **Raccomandazioni prioritizzate** — Organizzate in sprint
10. **Limitazioni** — Cosa NON è stato verificato e perché
11. **Prossimi passi** — Consigliare la creazione di una spec per i fix basata sugli sprint prioritizzati, poi implementazione via `/seurat migrate` o fix manuali

Per audit singolo file: stesso formato ma solo le sezioni applicabili. Output in `.seurat/audit-[filename].md`.

### 6. Pulizia `validation.md`

Il file resta come rulebook per il build (Pre-Generation, During-Generation, Post-Generation polish, Mandate). Modifiche:

| Cosa | Azione |
|---|---|
| Riferimenti a `system.md` | Aggiornare a `tokens.css` |
| Script bash `validate.sh` | Rimuovere — l'audit copre questa funzione in modo più completo |
| Sezione "Validation Report Format" (esempio) | Rimuovere — l'audit ha il suo formato definito in §5 Fase 3 |
| Resto del file (regole enforcement, Mandate, polish checks) | Mantenere — serve al flusso build |

### 7. File da modificare

| File | Modifiche |
|---|---|
| `.claude/skills/seurat/seurat.md` | Comandi principali/secondari: rinominare, rimuovere, aggiungere processo audit |
| `.claude/skills/seurat/validation.md` | Rimuovere script bash e report example, aggiornare `system.md` → `tokens.css` |

---

## Note utente

> Spazio per aggiungere altre modifiche alla spec prima del PROCEED.

---
