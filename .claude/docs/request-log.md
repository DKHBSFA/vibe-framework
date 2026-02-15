# Request Log

Registro incrementale di tutte le richieste gestite dal framework.

---

## Tipologie

| Codice | Descrizione |
|--------|-------------|
| `Feature` | Nuova funzionalità |
| `Bug fix` | Correzione bug |
| `Refactoring` | Ristrutturazione codice |
| `Research` | Ricerca/analisi |
| `Config` | Configurazione |
| `Doc` | Documentazione |

## Stati

| Stato | Significato |
|-------|-------------|
| `in sospeso` | Pianificato con documento di progetto, non ancora iniziato |
| `in corso` | Lavoro avviato |
| `completato` | Tutti i task del documento di progetto completati |
| `annullato` | Richiesta annullata dall'utente |

---

## Log

| # | Data | Ora | Tipologia | Descrizione | Doc riferimento | Stato |
|---|------|-----|-----------|-------------|-----------------|-------|
| 1 | 2026-02-15 | - | Feature | Integrazione metriche qualità: cognitive complexity in code-review, Debt Rating in techdebt, ASVS scan depth in Heimdall | `specs/quality-metrics-integration.md` | completato |
| 2 | 2026-02-15 | - | Doc | Allineamento CLAUDE.md, README.md, .claude/README.md: 6 fix (regole GW 46→50, flag Heimdall, Debt Rating, greeting, ElevenLabs, Morpheus) | - | completato |
| 3 | 2026-02-15 | - | Feature | Rename claude-update.sh → framework-update.sh + protezioni anti-perdita dati (backup, dry-run, git check, conferma, CLAUDE.md diff) | `specs/framework-update-safety.md` | completato |
| 4 | 2026-02-15 | - | Refactoring | Forge audit fix: 6 skill fixes (Orson coherence matrix trim, Heimdall dir merge + v2.0 integration, Ghostwriter project-specific data cleanup, Seurat Visual QA dedup, Emmet Visual Testing trim + KNOWLEDGE.md ref, Forge progressive-disclosure routing) | `.forge/forge-audit.md` | completato |

---

*Questo file è aggiornato automaticamente da Claude ad ogni richiesta che modifica il codebase.*
