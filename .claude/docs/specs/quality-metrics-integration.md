# Spec: Integrazione metriche qualità da code-quality-security.md

**Data:** 2026-02-15
**Fonte:** `.claude/docs/specs/references/code-quality-security.md`
**Tipo:** Enhancement (3 micro-integrazioni in skill esistenti)

---

## Cosa

Integrare 3 concetti operativi dal documento di riferimento nelle skill Emmet e Heimdall. Nessuna nuova skill, nessun refactoring — solo aggiunte puntuali.

---

## Cambiamento 1: Cognitive Complexity in Emmet code-review

**File:** `.claude/skills/emmet/checklists/code-review.md`

**Problema:** La checklist code-review controlla nesting (< 4 livelli) e dimensioni (funzioni < 50 righe, file < 500 righe) ma non menziona la cognitive complexity, che misura la difficoltà di comprensione umana del codice — cosa diversa dalla cyclomatic complexity (percorsi di esecuzione).

**Modifica:** Aggiungere nella sezione "Code Quality (HIGH)" una voce per cognitive complexity con soglia ≤15 per metodo/funzione, e una nota che la distingue dalla cyclomatic complexity.

**Soglia:** ≤15 per metodo (standard SonarQube, ampiamente adottato).

---

## Cambiamento 2: Technical Debt Ratio in Emmet techdebt

**File:** `.claude/skills/emmet/SKILL.md` (sezione `/emmet techdebt`)

**Problema:** Il techdebt audit cerca pattern strutturali (duplicazioni, export orfani, file oversized) ma non produce una metrica sintetica. Il risultato è una lista di finding senza un indicatore aggregato di gravità.

**Modifica:** Aggiungere al report di `/emmet techdebt` un calcolo semplificato del Technical Debt Ratio ispirato a SQALE:

```
Debt Ratio = (issue stimati in minuti di fix) / (LOC × 0.5 min per riga) × 100
```

Rating derivato:
| Rating | Debt Ratio |
|--------|------------|
| A | ≤ 5% |
| B | 6-10% |
| C | 11-20% |
| D | 21-50% |
| F | > 50% |

Questo va nel template del report (`techdebt-report.md`), non nel SKILL.md. Il SKILL.md menziona solo che il report include un Debt Rating.

**Costo di fix stimato per tipo di issue:**
| Issue | Minuti stimati |
|-------|---------------|
| Funzione duplicata | 30 |
| Export orfano | 5 |
| Import non usato | 2 |
| Pattern ripetuto estraibile | 20 |
| File oversized (>300 righe) | 45 |

Questi valori sono stime ragionevoli, non standard assoluti. L'obiettivo è dare un ordine di grandezza, non precisione contabile.

---

## Cambiamento 3: ASVS scan depth in Heimdall audit

**File:** `.claude/skills/heimdall/SKILL.md` (sezione `/heimdall audit`)

**Problema:** `/heimdall audit` ha una sola modalità: scan completo. Non c'è modo di calibrare la profondità dell'analisi in base al rischio del progetto.

**Modifica:** Aggiungere 3 livelli di profondità ispirati a OWASP ASVS:

| Livello | Flag | Cosa fa |
|---------|------|---------|
| L1 — Quick | `--quick` | OWASP Top 10 + secrets + BaaS config. Veloce, per check rapidi. |
| L2 — Standard | (default, nessun flag) | L1 + iteration analysis + dependency audit + logic patterns. Comportamento attuale. |
| L3 — Deep | `--deep` | L2 + analisi cross-file dei flussi auth, data flow tracking, review completa di ogni file con complessità ciclomatica > 15. Per progetti ad alto rischio. |

L'audit attuale corrisponde a L2. L1 è un sottoinsieme più veloce. L3 aggiunge analisi che oggi non vengono fatte sistematicamente.

---

## File toccati

| File | Tipo modifica |
|------|---------------|
| `.claude/skills/emmet/checklists/code-review.md` | Aggiunta 2 righe sezione Code Quality |
| `.claude/skills/emmet/SKILL.md` | Aggiunta menzione Debt Rating in sezione techdebt |
| `.claude/skills/heimdall/SKILL.md` | Aggiunta tabella livelli in sezione `/heimdall audit` |

---

## Cosa NON fare

- Non importare il resto del documento di riferimento
- Non creare nuove skill
- Non aggiungere checklist ISO, vendor assessment, o materiale enciclopedico
- Non modificare i pattern di detection esistenti di Heimdall
- Non cambiare il formato dei report esistenti oltre a quanto specificato

---

## Verifica

Dopo l'implementazione:
1. Leggere i 3 file modificati e verificare che le aggiunte siano coerenti col resto
2. Verificare che nessun contenuto esistente sia stato rimosso o alterato
3. Verificare che il SKILL.md di Emmet e Heimdall non superi dimensioni ragionevoli
