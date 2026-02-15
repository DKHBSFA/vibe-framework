# Spec: Framework Update Safety + Rename

## Cosa
Rinominare `claude-update.sh` → `framework-update.sh` e aggiungere protezioni contro la perdita di dati.

## Perché
1. Il nome "claude-update" confonde — l'utente pensa di aggiornare Claude Code
2. Lo script attuale sovrascrive file senza backup, senza conferma, senza possibilità di preview

## Vettori di perdita dati identificati

| # | Rischio | Gravità | Fix |
|---|---------|---------|-----|
| 1 | Nessun backup prima della sovrascrittura | ALTA | Creare backup `.claude-backup-YYYYMMDD-HHMMSS/` prima di procedere |
| 2 | Nessun check su modifiche non committate | ALTA | Controllare `git status` nella target dir e avvisare |
| 3 | Nessun dry-run | MEDIA | Aggiungere `--dry-run` per preview senza modifiche |
| 4 | Nessuna conferma | MEDIA | Prompt interattivo con riepilogo prima di procedere |
| 5 | CLAUDE.md sempre sovrascritto | MEDIA | Rilevare diff utente e chiedere conferma, oppure creare CLAUDE.md.bak |
| 6 | File utente in `.claude/` non previsti nelle liste | BASSA | Lo script copia solo dal source, non elimina file target — già sicuro |

## Cosa cambia

### File
- `claude-update.sh` → eliminato (git rm)
- `framework-update.sh` → nuovo file (rinominato + migliorato)
- Aggiornare riferimenti in documentazione (se presenti)

### Nuove feature dello script

1. **`--dry-run`** — Mostra cosa verrebbe fatto senza toccare nulla
2. **Backup automatico** — Prima di qualsiasi sovrascrittura, copia i file target che verranno modificati in `.framework-backup-YYYYMMDD-HHMMSS/`
3. **Git status check** — Se la target dir è un repo git e ha modifiche non committate in `.claude/` o `CLAUDE.md`, avvisa e chiede conferma
4. **Conferma interattiva** — Riepilogo con conteggi (update/preserve/init) e prompt Y/N prima di procedere
5. **CLAUDE.md diff check** — Se l'utente ha modificato CLAUDE.md rispetto al source, avvisa e offre opzioni (sovrascrivi / mantieni / backup)
6. **Messaggio di backup** — Al termine, informa dove si trova il backup

### Logica backup
- Backup solo dei file che stanno per essere sovrascritti (non dell'intera `.claude/`)
- Struttura mirror del path originale dentro la cartella backup
- Il backup va nella target dir (non nella source)

## Come verifico
- Testare dry-run: nessun file modificato
- Testare su dir con file protetti: tutti preservati
- Testare su dir con CLAUDE.md modificato: warning mostrato
- Testare su dir con modifiche git uncommitted: warning mostrato
- Testare backup: file recuperabili dalla cartella backup
