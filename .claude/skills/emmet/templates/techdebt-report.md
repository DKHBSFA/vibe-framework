# Tech Debt Report Template

## Overview

Template per generare report techdebt con `/emmet techdebt`.

---

## Template

```markdown
# Tech Debt Report: [Scope]

**Date:** YYYY-MM-DD
**Auditor:** Claude (emmet skill)
**Scope:** [path auditato]
**LOC totali:** N

---

## Debt Rating

**Rating: X** (Debt Ratio: N%)

| Rating | Debt Ratio |
|--------|------------|
| A | ≤ 5% |
| B | 6-10% |
| C | 11-20% |
| D | 21-50% |
| F | > 50% |

### Calcolo

```
Debt Ratio = (minuti stimati di fix) / (LOC × 0.5) × 100
```

**Minuti stimati totali:** N min
**LOC × 0.5:** N min (capacità di sviluppo stimata)
**Debt Ratio:** N%

---

## Findings

### Funzioni duplicate o quasi-duplicate

| # | File A | File B | Similarità | Fix (min) |
|---|--------|--------|------------|-----------|
| 1 | path:line | path:line | N% | 30 |

### Export orfani

| # | File | Export | Fix (min) |
|---|------|--------|-----------|
| 1 | path:line | `functionName` | 5 |

### Import non usati

| # | File | Import | Fix (min) |
|---|------|--------|-----------|
| 1 | path:line | `moduleName` | 2 |

### Pattern ripetuti estraibili

| # | Pattern | Occorrenze | File | Fix (min) |
|---|---------|------------|------|-----------|
| 1 | [descrizione] | N | file1, file2, ... | 20 |

### File oversized (>300 righe)

| # | File | Righe | Responsabilità | Fix (min) |
|---|------|-------|----------------|-----------|
| 1 | path | N | [descrizione] | 45 |

---

## Summary

| Categoria | Issues | Minuti stimati |
|-----------|--------|----------------|
| Funzioni duplicate | N | N × 30 |
| Export orfani | N | N × 5 |
| Import non usati | N | N × 2 |
| Pattern ripetuti | N | N × 20 |
| File oversized | N | N × 45 |
| **Totale** | **N** | **N** |

---

## Recommendations

### Quick Wins (< 10 min ciascuno)
1. [Issue a basso costo]

### Refactoring Necessario
1. [Issue che richiede refactoring strutturale]

### Da Pianificare
1. [Issue complessa da discutere con il team]
```

---

## Costi di fix stimati per tipo

Valori usati nel calcolo del Debt Ratio. Sono stime ragionevoli, non standard assoluti. L'obiettivo e dare un ordine di grandezza.

| Issue | Minuti stimati |
|-------|---------------|
| Funzione duplicata | 30 |
| Export orfano | 5 |
| Import non usato | 2 |
| Pattern ripetuto estraibile | 20 |
| File oversized (>300 righe) | 45 |

---

## Usage

Quando `/emmet techdebt` viene invocato:

1. **Scan codebase** — Cerca i 5 tipi di issue
2. **Conta LOC** — Righe di codice nel scope
3. **Calcola fix time** — Somma minuti stimati per ogni issue trovato
4. **Calcola Debt Ratio** — `(fix time) / (LOC × 0.5) × 100`
5. **Assegna Rating** — A/B/C/D/F in base alla tabella
6. **Genera report** — Compila questo template
7. **Output** — Salva in `.emmet/techdebt-report.md`
