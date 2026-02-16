# UX/UI Audit Report — JOUELRY

**Data:** 2026-02-16
**Metodo:** Analisi codice sorgente + 47 screenshot Playwright (desktop light/dark, mobile, zoomed sections) + audit automatico spacing da codice
**Pagine analizzate:** Home, Search, Grade, Atlas, Vault, About, Contact, Register, Privacy, Terms, Outlook
**Copertura:** 11/11 pagine desktop light, 9/11 dark, 9/11 mobile, 18 zoom sezione

---

## Executive Summary

JOUELRY ha un design system solido con identità luxury coerente: tipografia serif/sans ben gerarchizzata, palette Oklch raffinata, border radius minimali. L'esperienza complessiva è professionale e curata. Tuttavia emergono **problemi significativi** in 5 aree: consistenza visiva tra pagine, accessibilità, responsive mobile, dark mode, e feedback utente nei form.

**Valutazione complessiva: 6.5/10**

| Area | Voto | Note |
|------|------|------|
| Visual Design & Brand | 8/10 | Forte identità luxury, coerente |
| Layout & Spacing | 6/10 | Inconsistenze tra pagine |
| Typography | 7.5/10 | Buona gerarchia, qualche incoerenza scale |
| Color System | 7/10 | Solido in light, problemi in dark |
| Responsive/Mobile | 5/10 | Criticità significative |
| Accessibility | 4.5/10 | Lacune importanti |
| Forms & Interaction | 5.5/10 | Feedback mancante, validazione debole |
| Navigation & IA | 7/10 | Chiara ma con gap |
| Data Visualization | 6.5/10 | Buona base, accessibilità carente |
| Dark Mode | 5/10 | Funzionale ma con problemi di contrasto |

---

## 1. CRITICAL — Problemi ad alto impatto

### 1.1 Search: Card jeweler senza immagini — effetto "griglia vuota"

**Screenshot:** `02-search-light.png`

Le card dei gioiellieri nella pagina search mostrano un rettangolo grigio placeholder dove dovrebbe esserci l'immagine. Su 18 card visibili, **tutte** hanno il placeholder vuoto. L'effetto visivo è di una pagina rotta/incompleta, non di un prodotto luxury.

**Impatto:** Primo contatto dell'utente con i jeweler — impressione devastante.

**Fix:** Implementare un placeholder illustrato con iniziali del brand (come avatar) o un'icona luxury. Aggiungere il campo immagine al profilo jeweler e renderlo prioritario nell'onboarding.

---

### 1.2 Dark mode: Contrasto insufficiente nelle card search

**Screenshot:** `02-search-dark.png`

In dark mode la pagina Search è quasi illeggibile. Le card jeweler hanno bordi appena percettibili, il testo delle specializzazioni (tags) è poco leggibile, e il bottone "View Profile" ha contrasto borderline. L'intera grid sembra un muro nero uniforme.

**Impatto:** Utenti dark mode (spesso >40% del traffico) avranno un'esperienza degradata.

**Fix:** Aumentare la luminosità dei bordi card in dark (`--border` da `oklch(0.22)` a `oklch(0.28)`). Aggiungere `bg-card` esplicito alle card con maggiore differenziazione dalla background.

---

### 1.3 Mobile: Header navigation troncata e cramped

**Screenshot:** `01-home-mobile.png`, `08-register-mobile.png`

L'header mobile mostra "JOUELRY" + icona search + theme toggle + globe + bandiera + hamburger, tutto compresso in 390px. Gli elementi sono troppo vicini, i touch target per gli icon button sono sotto i 44px raccomandati da Apple/Google.

**Impatto:** Frustrazione su tap errati, specialmente su device piccoli.

**Fix:** Raggruppare search/theme/language nel menu hamburger. Mantenere solo logo + hamburger nella barra principale. Usare `min-h-[44px] min-w-[44px]` per tutti i touch target.

---

### 1.4 Register: Form senza indicatori campi obbligatori

**Screenshot:** `08-register-light.png`

Il form di registrazione ha 6 campi (First Name, Last Name, Date of Birth, Email, Password, Confirm Password) ma nessun asterisco (*) o indicazione di quali siano obbligatori. Non c'è nemmeno un messaggio "All fields required". I label sono generic senza hint (es. formato password richiesto).

**Impatto:** Utente scopre gli errori solo dopo il submit — alto tasso di abbandono form.

**Fix:** Aggiungere `*` ai campi obbligatori con legenda. Mostrare requisiti password inline. Aggiungere validazione real-time.

---

### 1.5 Contact: Form off-center e sproporzionato

**Screenshot:** `07-contact-light.png`

Il form contatto occupa ~50% della larghezza pagina su desktop 1440px, spostato leggermente a sinistra. L'area textarea "Message" è enorme rispetto ai due campi sopra. Il risultato è una pagina con troppo spazio bianco a destra e un layout sbilanciato.

**Impatto:** Percezione di pagina incompleta, non luxury.

**Fix:** Centrare il form con `max-w-lg mx-auto`. Aggiungere informazioni di contatto (email, indirizzo, orari) nella colonna destra per bilanciare. Ridurre il min-height della textarea.

---

## 2. HIGH — Problemi significativi

### 2.1 Inconsistenza spacing tra sezioni

**Osservato su:** Home, Grade, Atlas, About

Lo spacing tra le macro-sezioni varia senza logica:
- Home "How It Works" → "Every Jeweler": ~96px (corretto, usa `--space-section`)
- Grade "A Score from 0 to 100" → "Comprehensive Analysis": ~80px
- Atlas "7 Data Products" → "Predictive Analytics Layer": ~64px
- About: spacing molto più compresso, sezioni quasi attaccate

Il design system definisce `--space-section: 6rem (96px)` ma non è applicato uniformemente.

**Fix:** Standardizzare `py-[var(--space-section)]` come classe per tutti i `<section>` wrapper. Creare un componente `<Section>` riutilizzabile.

---

### 2.2 Grade page: Testo "0-100" nel box non responsive

**Screenshot:** `03-grade-mobile.png`

Il numero "0-100" nel box illustrativo occupa quasi tutta la larghezza mobile. Il testo "Continuous scoring scale with no artificial tiers" sotto è molto piccolo. I tre score range (90+, 80-89, 60-69) sono impilati verticalmente e occupano lo schermo intero, perdendo il confronto visivo side-by-side che funziona su desktop.

**Fix:** Su mobile, convertire i range in una lista compatta o un accordion. Ridurre il font-size del "0-100" display.

---

### 2.3 Outlook (Industry Report): Grafici troppo piccoli e colori incoerenti

**Screenshot:** `11-outlook-light.png`

La pagina report contiene ~8 grafici diversi (line chart, bar chart, doughnut, pie) con stili visivi eterogenei. Alcuni usano colori vivi (turchese, arancio, rosso) che non appartengono alla palette luxury definita nel design system. I grafici sono molto piccoli nella preview — la pagina sembra un report PDF forzato nel web.

**Fix:** Applicare la palette `--analytics-*` e `--chart-*` definita nei token a TUTTI i grafici. Usare `chartColor()` e `getChartPalette()` in modo uniforme. Aumentare le dimensioni minime dei chart container.

---

### 2.4 Vault: Copy troppo aggressivo, layout denso

**Screenshot:** `05-vault-light.png`

L'hero della vault page usa un headline tutto maiuscolo "YOUR JEWELRY'S DIGITAL TWIN — AND YOUR PROOF OF OWNERSHIP" che è lungo e overwhelming. Il layout sotto è una tabella di feature comparison densa senza chiara gerarchia. La sezione "How It Works" (1. SNAP, 2. MINT, 3. CONTROL) è l'unico elemento chiaro.

**Fix:** Headline più corto e impattante. Convertire la tabella feature in card con icone. Dare più breathing room tra le sezioni.

---

### 2.5 About: Foto team circolari generiche

**Screenshot:** `06-about-light.png`

La sezione team mostra 6 avatar circolari neri con lettere bianche (placeholder). Stesso problema delle card search — senza foto reali il prodotto sembra incompleto. La sezione "987+" in alto usa un font-size enorme che domina lo spazio.

**Fix:** Aggiungere foto reali del team. Se non disponibili, usare un layout che non richieda foto (solo nomi + ruoli in griglia). Bilanciare il numero "987+" con il resto della sezione.

---

### 2.6 Footer: "SYSTEM OPERATIONAL" inutile per l'utente

**Screenshot:** Tutte le pagine

In basso a destra del footer c'è un indicatore verde "SYSTEM OPERATIONAL". Questo è un'informazione interna/DevOps che non ha senso per un utente consumer di una piattaforma luxury.

**Fix:** Rimuovere l'indicatore dal frontend pubblico. Se necessario per monitoring, esporlo solo in `/admin`.

---

## 3. MEDIUM — Miglioramenti importanti

### 3.1 Home hero: CTA primaria non immediatamente visiva

Il pulsante principale nell'hero è un campo search con placeholder text. Non c'è un CTA button esplicito tipo "Explore Jewelers" o "Search Now" visibile above-the-fold. I filter tags sotto la search bar (1700+ Verified Jewelers, Rated & Reviewed, 100% Independent) sono informativi ma non cliccabili — spreco di interaction opportunity.

### 3.2 Navigation: "RANKINGS" link mancante nel header

Il nav principale mostra: RANKINGS, AWARDS, STORIES, VAULT, ATLAS. Ma la pagina Grade (/grade) non è linkato direttamente — si raggiunge solo dalla homepage. "RANKINGS" porta a /grade ma il naming è incoerente col URL.

### 3.3 Search filters: Sidebar troppo alta senza sticky

Su desktop, la sidebar filtri a sinistra ha 7 dropdown (Min GemScore, Location, Services, Jewelry Types, Brands, Materials, Experience) che si estende molto in verticale. Non è sticky, quindi scrollando la grid di risultati si perde il contesto dei filtri applicati.

### 3.4 Register: Progress bar poco visibile

La barra di progresso in cima al form (step 1 di N) è una sottile linea gialla/gold su sfondo card. Minima visibilità, nessun indicatore numerico o testuale dello step corrente.

### 3.5 Privacy/Terms: Layout puramente testuale senza design

Le pagine Privacy e Terms sono puro testo con heading e bullet points. Nessun box, card, o elemento visivo per migliorare la leggibilità. La pagina Privacy ha un box con informazioni di contatto — unico elemento strutturato.

### 3.6 Mobile search: Pagina troppo lunga (11617px)

Lo screenshot mobile della pagina search è alto 11617px — l'utente deve scrollare enormemente. I filtri sono collassati in accordion (bene) ma i risultati mostrano tutte le card senza lazy loading visivo o "Load more" button.

### 3.7 Typography: Serif headings inconsistenti

La home usa serif per "Find The World's Best Jewelers" e sezioni, Atlas usa serif per "ATLAS", Grade usa serif per "Every Jeweler, Rated & Verified" — ma la Vault usa serif solo per "Ownership" nel subtitle. Le pagine legali non usano serif. Definire regole chiare: H1 sempre serif? Solo hero? Solo landing page?

---

## 4. LOW — Polish e refinement

### 4.1 Home "How It Works": Icone senza contesto

Le tre card (Search & Compare, Read Reviews, Visit with Confidence) usano icone minimaliste (search, document, shield?) che sono troppo piccole e astratte. In un prodotto luxury, queste card meritano illustrazioni o icone più elaborate.

### 4.2 Rating Tiers: Badge circolari troppo piccoli

I tre tier (Diamond, Platinum, Gold) mostrano badge circolari piccoli con label troncata. Su desktop si legge, su mobile è al limite.

### 4.3 Atlas "How It Works": Steps list troppo semplice

La sezione mostra 5 bullet points con cerchi numerati. Per una pagina che vende un prodotto analytics premium, la visualizzazione è troppo piatta. Merita un diagramma flow o cards con icone.

### 4.4 Footer link columns: Spacing non uniforme

Le colonne PLATFORM, COMPANY, LEGAL hanno spacing diverso tra i link. PLATFORM ha 4 voci, COMPANY 3, LEGAL 3 — ma lo spacing verticale non si equalizza.

### 4.5 Dark mode Grade page: Gold text su nero funziona bene

Nota positiva: la pagina Grade in dark mode è la meglio riuscita. Il gold (#brand-gold) su nero crea un effetto luxury coerente e leggibile. Usare questo come reference per le altre pagine dark.

---

## 5. Accessibility — Findings specifici

### 5.1 CRITICO: Nessun skip-to-content link
L'header ha navigation con 5+ link prima del contenuto principale. Non c'è skip link per keyboard/screen reader.

### 5.2 CRITICO: Form senza aria-invalid/aria-errormessage
I form (contact, register) non comunicano errori di validazione a screen reader. Nessun `aria-invalid`, nessun `aria-describedby` per messaggi di errore.

### 5.3 CRITICO: Diamond rating senza aria-label per valore
Il componente DiamondRating ha interazione custom ma nessun `aria-label` per comunicare "3 su 5 diamanti".

### 5.4 HIGH: Colore come unico indicatore di stato
I badge DPP nel vault usano dot colorati (verde/giallo/rosso) senza testo. Le trend arrows nel ranking usano solo colore (verde up, rosso down).

### 5.5 HIGH: Focus ring non visibile su alcune card
Le jeweler card nella search hanno hover states ma il focus ring per keyboard navigation non è visibile nelle card clickabili.

### 5.6 MEDIUM: Chart.js senza testo alternativo
I grafici nella pagina Outlook non hanno `aria-label` o data table fallback.

---

## 6. Dark Mode — Findings specifici

### 6.1 Search page: Quasi inutilizzabile (vedi 1.2)

### 6.2 Card borders troppo deboli
In dark mode `--border: oklch(0.22)` è quasi invisibile su `--background: oklch(0.10)`. La differenza di luminosità è solo 0.12 — dovrebbe essere almeno 0.18.

### 6.3 Home page dark: Buona ma hero troppo scuro
L'hero section perde il warm alabaster che definisce il brand. Il passaggio a nero piatto toglie personalità. Considerare un `oklch(0.12 0.005 85)` — nero caldo con hint di warm tone.

### 6.4 Gold accents funzionano bene
I brand-gold in dark mode sono ben calibrati e leggibili. Estendere questo pattern (gold on dark) come firma del dark theme.

---

## 7. Raccomandazioni prioritizzate

### Sprint 1 (Quick wins, alto impatto)
1. **Jeweler card placeholder** — Sostituire rettangolo grigio con avatar lettere/icona branded
2. **Dark mode border fix** — `--border` da `oklch(0.22)` a `oklch(0.28)`
3. **Skip-to-content link** — 1 riga HTML
4. **Rimuovere "SYSTEM OPERATIONAL"** dal footer pubblico
5. **Register form: asterischi obbligatori** + hint password

### Sprint 2 (Consistenza design)
6. **Standardizzare section spacing** — Componente `<Section>` con spacing consistente
7. **Contact page layout** — Centrare + aggiungere info colonna destra
8. **Search sidebar sticky** — `position: sticky; top: 80px`
9. **Mobile header** — Collassare icone nel hamburger
10. **Form validation aria** — `aria-invalid` + `aria-describedby` su tutti i form

### Sprint 3 (Polish)
11. **Chart palette unificata** — Forzare `chartColor()` su tutti i grafici Outlook
12. **Vault hero** — Headline più corto, spaziatura sezioni
13. **About team section** — Foto reali o layout senza foto
14. **Register progress bar** — Step indicator numerico visibile
15. **Mobile search pagination** — "Load more" invece di pagina infinita

### Sprint 4 (Accessibility compliance)
16. **DiamondRating aria-label** per valore corrente
17. **Color-only indicators** — Aggiungere testo a badge status
18. **Chart accessibility** — `aria-label` + data table fallback
19. **Focus management** nei wizard multi-step
20. **Keyboard navigation** custom dropdowns (Escape key)

---

## 8. LAYOUT & SPACING — Analisi granulare

### 8.1 Caos nello spacing scale: il design system è definito ma ignorato

Il progetto definisce una scala spacing semantica in CSS variables:
```
--space-micro: 1rem (16px)
--space-element: 1.5rem (24px)
--space-card: 2rem (32px)
--space-group: 4rem (64px)
--space-section: 6rem (96px)
```

Ma nell'implementazione reale, i valori Tailwind hardcoded dominano. Il risultato è frammentazione totale:

| Dove | Spacing usato | Dovrebbe essere |
|------|--------------|-----------------|
| Home hero → How It Works | `py-24` + `py-32` = ~128-152px | `--space-section` (96px) |
| How It Works → Every Jeweler | `py-32` = 128px | `--space-section` (96px) |
| Grade hero → scoring | ~200px di vuoto (visivo) | `--space-section` (96px) |
| Atlas CTA → 7 Data Products | ~180px di vuoto (visivo) | `--space-group` (64px) |
| Contact form → footer | ~150px di vuoto | Eccessivo |
| Register card → footer | ~200px di vuoto | Eccessivo |

**Problema visivo confermato da screenshot:** Lo spazio tra "REGISTER TO ACCESS ATLAS" e "7 Data Products" nella pagina Atlas (`zoom-atlas-products.png`) è visivamente enorme — circa 180px di bianco. Stessa cosa nella homepage tra sezioni.

**Root cause nel codice:** `home-content.tsx` usa `py-32 px-8` per le sezioni (128px verticale) mentre il design system dice 96px. Ogni componente sceglie il suo spacing.

---

### 8.2 Card padding: 4 standard diversi

Dall'audit del codice emergono almeno 4 pattern di card padding:

| Componente | Padding interno | Note |
|------------|----------------|------|
| Card UI base | `py-6 px-6` (24px) | Lo standard dal componente |
| Home "How It Works" cards | `p-10` (40px) | Override pesante |
| Jeweler card (search) | `p-4 pb-2 / p-4 pt-2` (16px/8px) | Molto stretto, asimmetrico |
| Atlas data product cards | `p-6` (24px) | Coerente con base |

**Visivamente confermato:** Nello zoom delle search cards, il nome jeweler è schiacciato contro il bordo superiore dell'area testo (8px di gap). Confrontato con le home cards dove c'è 40px di respiro. La differenza è stridente.

---

### 8.3 Grid gap: nessun pattern coerente

| Contesto | Gap | Tailwind |
|----------|-----|----------|
| Home "How It Works" (3 col) | 48px | `gap-12` |
| Home "Every Jeweler" (2 col) | 80px | `gap-20` |
| Search card grid (3 col) | ~24px | `gap-6` |
| Atlas data products (3 col) | ~24px | `gap-6` |
| Grade "Comprehensive Analysis" (3 col) | ~48px | `gap-12` |
| Footer columns | 48px | `gap-12` |
| Ranking podium (3 col) | 32px | `gap-8` |

**Problema:** Non c'è un valore standard per "grid di 3 card". A volte 24px, a volte 48px, a volte 80px. Il gap-20 (80px) nella home "Every Jeweler" è enorme e crea una separazione visiva confusa tra testo e card esempio.

---

### 8.4 Allineamento contenuto: mix centrato/sinistra senza logica

**Visivamente confermato nei zoom:**

| Sezione | Allineamento titolo | Allineamento body |
|---------|-------------------|-------------------|
| Home hero | Sinistra | Sinistra |
| Home "How It Works" | Sinistra (con label destra) | Card centrate |
| Home "Every Jeweler" | Sinistra | Split 2 colonne |
| Grade hero | Centro | Centro |
| Grade scoring | Mix (titolo centro, cards sinistra-destra) | — |
| Atlas hero | Centro | Centro |
| Atlas data products | Centro (titolo) → Sinistra (cards) | — |
| Vault hero | Centro | Centro |
| Contact | Centro | Centro (form sinistra nel contenitore) |

**Problema:** La homepage alterna sinistra e centrato tra sezioni adiacenti. La pagina Grade parte centrata, poi il layout "0-100" è un mix sinistra/destra con card score a destra. Non c'è una regola chiara: "landing pages = centrato, dashboard = sinistra".

---

### 8.5 Vertical rhythm rotto: gap label→contenuto inconsistente

Dall'audit codice e screenshot:

| Elemento | Label → Titolo | Titolo → Body | Body → CTA |
|----------|---------------|---------------|------------|
| Home section header | 24px (`pb-6`) | 64px (`mb-16`) | Varia |
| Grade section | ~8px | ~24px | ~40px |
| Atlas section | ~8px (gold label) | ~16px | ~48px |
| Contact form | 0 (label su titolo) | ~24px | — |

Il `SectionHeader` component usa `mb-16` (64px) dopo la linea divisoria — ma poi il contenuto sotto ha il suo padding `pt-*` che si somma. In certi casi lo spazio effettivo tra la linea e il primo elemento è >100px.

---

### 8.6 Header: gap troppo largo tra logo e nav

**Confermato in `zoom-home-header.png`:** Il gap tra "JOUELRY" e "RANKINGS" è `gap-16` (64px). Poi tra i nav items è `gap-10` (40px). Il risultato è che il nav sembra "flottare" nel centro, non collegato al logo. Su schermi 1440px funziona, ma su 1024px (tablet landscape) i link sarebbero compressi o il gap sarebbe sproporzionato.

---

### 8.7 Form field spacing: Register vs Contact

**Confermato negli zoom:**

| Form | Gap tra campi | Label → Input | Note |
|------|--------------|---------------|------|
| Register | ~16px (`space-y-4`) | ~4px | Campi vicini, compatti |
| Contact | ~24px (`space-y-6`) | ~8px | Più respiro |

Due form nello stesso sito con spacing diverso. Il register è particolarmente stretto — i campi Password e Confirm Password sembrano un unico blocco. Il contact ha più aria ma la textarea domina visivamente (altezza ~200px vs input ~36px).

---

### 8.8 Footer: spacing colonne non allineato

**Confermato in `zoom-home-footer.png`:** La colonna PLATFORM ha 4 link (AI Grade, Rankings, Market Atlas, The Vault), COMPANY ne ha 3, LEGAL ne ha 3. Il gap verticale tra link è `space-y-4` (16px) — coerente. Ma la colonna PLATFORM è più alta, e il logo JOUELRY a sinistra è allineato al top, creando uno sbilanciamento verticale nel footer.

Le social icons (Instagram, Mail, Globe) sono `h-5 w-5` (20px) — sotto il minimo touch target di 44px. I link footer non hanno padding extra per il tap mobile.

---

### 8.9 Search page: sidebar-grid alignment mismatch

**Confermato in `zoom-search-cards-row1.png`:** La sidebar filtri inizia da "Filters" (h2) che è allineata con "Showing 18 of 3585 jewelers" nella zona grid. Ma la search input della sidebar non è allineata verticalmente con la prima riga di card. C'è uno sfasamento di ~20px tra il top della prima card e il top del primo filtro dropdown.

La sidebar occupa ~280px su 1440px di viewport. La zona card ha 3 colonne nel rimanente ~1100px. Il gap sidebar→grid è ~40px ma non è una variabile definita.

---

### 8.10 Mobile: spacing orizzontale non responsive

**Problema grave confermato su tutti i mobile screenshot:**

La maggior parte delle pagine usa `px-8` (32px) per il padding orizzontale. Su mobile 390px, questo lascia solo 326px per il contenuto. Ma la search page usa `px-4` (16px), la contact page sembra avere `px-6` (24px).

| Pagina mobile | Padding laterale stimato | Contenuto utile |
|---------------|------------------------|-----------------|
| Home | 32px | 326px |
| Search | 16px | 358px |
| Grade | 32px | 326px |
| Atlas | ~24px | 342px |
| Contact | ~24px | 342px |
| Register | ~24px | 342px |

Nessuna consistenza. La home perde 64px totali di spazio utile per padding eccessivo.

---

### 8.11 Vault mobile: layout collassa male

**Confermato in `05-vault-mobile.png`:** La sezione "FROM RECEIPT TO RESALE-READY IN ONE SCAN" su desktop è una tabella 3 colonne. Su mobile diventa una lista lineare dove ogni voce (Prove & Transfer, Digital Product Passport, Seamless Service Booking, etc.) è un singolo item con titolo bold. Ma la sezione "Your Jewelry Gains Value" non ha separatore dal blocco sopra — tutto si fonde in un muro di testo.

La sezione "How It Works" (1. SNAP, 2. MINT, 3. CONTROL) mantiene il layout card anche su mobile — buono. Ma le card sono molto strette (326px) con padding interno, lasciando ~260px per il testo.

---

### 8.12 Outlook mobile: 13942px di altezza — pagina infinita

**Confermato in `11-outlook-mobile.png`:** La pagina Industry Report è alta quasi 14000px su mobile. I grafici Chart.js non sono responsive — i doughnut chart occupano la stessa dimensione che su desktop ma con meno spazio orizzontale, creando uno stacking verticale estremo. Non c'è table of contents, anchor navigation, o modo di saltare sezioni.

---

### 8.13 Dark mode Register: bottone "Next" quasi invisibile

**Confermato in `08-register-dark.png`:** Il bottone "Next" è `bg-primary` che in dark mode diventa quasi bianco su sfondo card dark. Funziona. Ma i bordi degli input sono quasi invisibili — stessa issue della search page. Il campo Date of Birth ha l'icona calendario che scompare nel dark.

---

### 8.14 Dark mode Outlook: grafici con colori "al neon"

**Confermato in `11-outlook-dark.png`:** I grafici della pagina Industry Report in dark mode hanno colori molto saturi che creano un effetto "neon" — particolarmente il turchese, il rosa, e il giallo del line chart hero. Questi colori non usano la palette `--chart-*` dark e creano un contrasto stridente con il tono luxury della piattaforma.

---

## 9. SPACING — Raccomandazioni tecniche

### 9.1 Creare componente `<PageSection>` obbligatorio

```tsx
function PageSection({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <section className={cn(
      "py-[var(--space-section)] px-4 sm:px-6 lg:px-8",
      className
    )}>
      <div className="max-w-7xl mx-auto">
        {children}
      </div>
    </section>
  );
}
```

Tutte le sezioni di tutte le pagine DEVONO usare questo wrapper. Elimina il caos `py-24/py-32/px-8`.

### 9.2 Standardizzare card padding

```
Regola: Tutte le card usano p-6 (24px).
Eccezione: Card compatte (jeweler list) usano p-4 (16px).
Vietato: p-10, p-8, p-4 pb-2 pt-2 e altre varianti custom.
```

### 9.3 Standardizzare grid gap

```
Card grid (3 col): gap-6 (24px)
Feature grid (2-3 col): gap-8 (32px)
Section split (2 col asimmetrico): gap-12 (48px)
Vietato: gap-20 (80px) — troppo per qualsiasi contesto
```

### 9.4 Standardizzare form field spacing

```
Tra campi: space-y-5 (20px) — compromesso tra register (16px) e contact (24px)
Label → Input: gap-2 (8px) — già definito nel FormItem, rispettarlo ovunque
Gruppi logici: space-y-8 (32px) tra gruppi (es. "Dati personali" / "Password")
```

### 9.5 Mobile padding: responsive obbligatorio

```
px-4 (16px) su mobile
sm:px-6 (24px) su tablet
lg:px-8 (32px) su desktop
```

Applicare a TUTTI i container. Zero eccezioni.

---

## 10. Limitazioni dell'audit — Cosa NON è stato verificato

Questo audit ha copertura parziale. I seguenti aspetti **non sono stati analizzati** e richiedono verifiche dedicate:

### Non coperto — Pagine
- **Pagine autenticate** — Dashboard, Settings, Admin panel, Jeweler profile dettaglio. Serve login con credenziali reali per catturare screenshot.
- **Pagine awards** — Awards overview, category detail, winner showcase. Non raggiungibili senza dati.
- **Pagine stories** — Stories listing, article detail view.
- **Jeweler profile singolo** — La pagina profilo completa di un jeweler (jeweler-profile-enhanced).
- **Dark mode** — Privacy e Terms non coperte in dark (9/11).
- **Mobile** — Privacy e Terms non coperte in mobile (9/11).

### Non coperto — Interazioni
- **Flussi interattivi** — Submit form (errori, successo, loading states), step onboarding wizard completo, notifiche toast, apertura/chiusura modali, sheet laterali.
- **Stati vuoti/errore/loading** — Empty states reali (search senza risultati, vault vuoto, atlas senza dati), skeleton loading visibile, error boundaries.
- **Navigazione keyboard** — Tab order reale, focus trap nei dialog, Escape key nei dropdown, skip-to-content funzionante.
- **Animazioni e transizioni** — Hover states in azione, transition-luxury effettivo, scroll-to-top behavior.

### Non coperto — Internazionalizzazione
- **RTL layout** — Arabo e Ebraico hanno supporto dichiarato ma il layout RTL non è stato verificato visivamente. Potenziali problemi: header invertito, form alignment, icon direction, chart labels.
- **Lingue lunghe** — Tedesco e Russo tendono ad avere parole più lunghe. Non verificato se i layout reggono senza overflow/troncamento.

### Non coperto — Metriche oggettive
- **Contrasto WCAG** — I ratio colore sono stati stimati a occhio, non misurati con tool automatico (axe, Lighthouse). Particolarmente critico per `--muted-foreground` su `--background` e bordi dark mode.
- **Performance percepita** — LCP, CLS, FID non misurati. Le pagine lunghe (Outlook 14000px mobile) potrebbero avere problemi di performance.
- **Touch target** — Dimensioni stimate visivamente, non misurate. I 44px Apple/Google HIG non sono stati verificati con precision tool.

### Prossimi step per copertura completa
1. **Autenticazione** — Creare script Playwright con login per catturare dashboard/settings/admin
2. **Flussi interattivi** — Script Playwright che compila form, triggera errori, naviga wizard
3. **RTL check** — Screenshot in arabo/ebraico per tutte le pagine principali
4. **Contrast audit automatico** — Lighthouse accessibility audit + axe-core scan
5. **Keyboard navigation audit** — Script che verifica tab order e focus management

---

## Appendice: Screenshot Reference

| File | Viewport | Tema |
|------|----------|------|
| `01-home-light.png` | 1440x900 | Light |
| `01-home-dark.png` | 1440x900 | Dark |
| `01-home-mobile.png` | 390x844 | Light |
| `02-search-light.png` | 1440x900 | Light |
| `02-search-dark.png` | 1440x900 | Dark |
| `02-search-mobile.png` | 390x844 | Light |
| `03-grade-light.png` | 1440x900 | Light |
| `03-grade-dark.png` | 1440x900 | Dark |
| `03-grade-mobile.png` | 390x844 | Light |
| `04-atlas-light.png` | 1440x900 | Light |
| `04-atlas-dark.png` | 1440x900 | Dark |
| `05-vault-light.png` | 1440x900 | Light |
| `06-about-light.png` | 1440x900 | Light |
| `07-contact-light.png` | 1440x900 | Light |
| `08-register-light.png` | 1440x900 | Light |
| `08-register-mobile.png` | 390x844 | Light |
| `09-privacy-light.png` | 1440x900 | Light |
| `10-terms-light.png` | 1440x900 | Light |
| `11-outlook-light.png` | 1440x900 | Light |

### Round 2 — Zoomed sections
| File | Area |
|------|------|
| `zoom-home-header.png` | Header + hero (spacing analisi) |
| `zoom-home-howitworks.png` | How It Works section transition |
| `zoom-home-everyJeweler.png` | Section transition + card layout |
| `zoom-home-cta.png` | CTA + Rating Tiers spacing |
| `zoom-home-footer.png` | Footer column alignment |
| `zoom-search-cards-row1.png` | Sidebar + first card row |
| `zoom-search-cards-row2.png` | Card details + tag spacing |
| `zoom-grade-hero.png` | Hero → scoring system gap |
| `zoom-grade-scores.png` | Score boxes layout |
| `zoom-grade-analysis.png` | Analysis grid |
| `zoom-atlas-products.png` | CTA → data products gap |
| `zoom-atlas-predictive.png` | Predictive layer layout |
| `zoom-register-form.png` | Form field spacing |
| `zoom-contact-form.png` | Form centering + spacing |
| `zoom-vault-hero.png` | Hero layout |
| `zoom-vault-features.png` | Feature grid spacing |
| `zoom-about-stats.png` | Stats section |
| `zoom-about-team.png` | Timeline + team |

### Round 2 — Dark mode (remaining)
| File | Viewport | Tema |
|------|----------|------|
| `05-vault-dark.png` | 1440x900 | Dark |
| `06-about-dark.png` | 1440x900 | Dark |
| `07-contact-dark.png` | 1440x900 | Dark |
| `08-register-dark.png` | 1440x900 | Dark |
| `11-outlook-dark.png` | 1440x900 | Dark |

### Round 2 — Mobile (remaining)
| File | Viewport | Tema |
|------|----------|------|
| `04-atlas-mobile.png` | 390x844 | Light |
| `05-vault-mobile.png` | 390x844 | Light |
| `06-about-mobile.png` | 390x844 | Light |
| `07-contact-mobile.png` | 390x844 | Light |
| `11-outlook-mobile.png` | 390x844 | Light |

Screenshot salvati in `/tmp/ux-audit-screenshots/`
