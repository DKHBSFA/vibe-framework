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
| 1 | 2026-02-03 | — | Refactoring | Migrazione audiosculpt da Tone.js a Strudel | [audiosculpt-strudel-migration.md](specs/audiosculpt-strudel-migration.md) | completato |
| 2 | 2026-02-03 | — | Feature | Audiosculpt v2: Impact Frame, Parametric Templates, Voiceover Mode, Voice Leading Tables | [audiosculpt-v2-enhancements.md](specs/audiosculpt-v2-enhancements.md) | completato |
| 3 | 2026-02-03 | — | Feature | Audiosculpt v2 P2+P3: Preset Inheritance, Loop Variations, Feel Profiles, Soft Constraints | [audiosculpt-v2-enhancements.md](specs/audiosculpt-v2-enhancements.md) | completato |
| 4 | 2026-02-04 | — | Bug fix | video-craft: keyframes mancanti per animazioni multi-fase (scale-word, fade-out) | - | completato |
| 5 | 2026-02-04 | — | Bug fix | video-craft: scene names duplicati + contrasto zero con design tokens | - | completato |
| 6 | 2026-02-04 | 15:30 | Feature | Creazione 5 webvideo HTML su Kimi K2.5 (5 tipologie diverse) | - | completato |
| 7 | 2026-02-04 | — | Research | Analisi frame-by-frame video vs HTML per identificare bug video-craft | [video-craft-bug-fixes.md](specs/video-craft-bug-fixes.md) | completato |

---

*Questo file è aggiornato automaticamente da Claude ad ogni richiesta che modifica il codebase.*
