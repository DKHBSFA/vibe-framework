 
 
   
Ecco l'elenco completo delle certificazioni ISO, framework NIST e altri standard per la sicurezza del codice software, cybersecurity, audit e controllo fornitori IT:

---

## **STANDARD ISO PER LA SICUREZZA DEL SOFTWARE**

### **ISO/IEC 27034 - Application Security**
Standard internazionale focalizzato sulla sicurezza delle applicazioni durante tutto il ciclo di vita. Include:
- **Parte 1**: Panoramica e concetti (Organization Normative Framework - ONF, Application Security Controls - ASC)
- **Parte 2**: Organization Normative Framework
- **Parte 3**: Processo di gestione della sicurezza applicativa
- **Parte 5**: Protocolli e strutture dati ASC
- **Parte 6**: Casi di studio
- **Parte 7**: Framework di predizione dell'assicurazione 

### **ISO/IEC 15408 - Common Criteria (CC)**
Standard internazionale per la valutazione della sicurezza dei prodotti IT. Utilizza:
- **Evaluation Assurance Levels (EAL 1-7)**: Livelli di valutazione dell'assicurazione (EAL7 è il più stringente)
- **Protection Profiles (PP)**: Profili di protezione specifici per tecnologia
- **Collaborative Protection Profiles (cPP)**: Riconosciuti dai 31 paesi firmatari del CCRA 

### **ISO/IEC 27001:2022 - Controlli per lo Sviluppo Sicuro**
Annex A controlli specifici per software:
- **A.8.25**: Secure Development Life Cycle (SDLC) - 10 requisiti per costruire software sicuro 
- **A.8.26**: Application Security Requirements
- **A.8.27**: Secure Architecture and Engineering  
- **A.8.28**: Secure Coding (standard di codifica sicura per linguaggio)
- **A.8.29**: Security Testing in Development and Acceptance (SAST, SCA, DAST, IAST, penetration testing) 

### **ISO/IEC 29147 - Vulnerability Disclosure**
Linee guida per la divulgazione delle vulnerabilità nei prodotti e servizi, incluse:
- Ricezione di report sulle vulnerabilità
- Divulgazione delle informazioni di remediation
- Tecniche e considerazioni policy per vulnerability disclosure 

### **ISO/IEC 30111 - Vulnerability Handling**
Processi di gestione delle vulnerabilità che coprono:
- Verifica e triage delle vulnerabilità
- Sviluppo e test delle remediation
- Release e post-release
- Considerazioni sulla supply chain 

### **ISO/IEC 27036 - Supplier Relationships Security**
Serie multi-parte per la gestione della sicurezza nei rapporti con fornitori IT:
- **Parte 1**: Overview e concetti
- **Parte 2**: Requisiti per relazioni acquirente-fornitore (18 processi di lifecycle)
- **Parte 3**: Linee guida per supply chain hardware, software e servizi
- **Parte 4**: Linee guida per sicurezza cloud services 

---

## **FRAMEWORK NIST**

### **NIST Cybersecurity Framework (CSF) 2.0**
Framework strutturato su quattro pilastri:
- **Policies**: Direttive organizzative su approccio al rischio
- **Controls**: Azioni tecniche e procedurali
- **Detection**: Metodi e tecnologie di identificazione
- **Response**: Azioni documentate per incidenti
Utilizza ciclo PDCA (Plan-Do-Check-Act) per miglioramento continuo 

### **NIST SP 800-53 - Security and Privacy Controls**
Catalogo completo di 20 famiglie di controlli per sistemi federali:
- **AC**: Access Control
- **AU**: Audit and Accountability  
- **AT**: Awareness and Training
- **CM**: Configuration Management
- **IA**: Identification and Authentication
- **IR**: Incident Response
- **RA**: Risk Assessment
- **SC**: System and Communications Protection
- **SI**: System and Information Integrity
- **SR**: Supply Chain Risk Management 

### **NIST SP 800-171 - Protecting CUI**
17 famiglie di requisiti per proteggere Controlled Unclassified Information in sistemi non-federali:
- Access Control, Audit and Accountability, Configuration Management
- System and Information Integrity (flaw remediation, malicious code protection)
- Supply Chain Risk Management 

### **NIST SSDF (Secure Software Development Framework)**
SP 800-218 - Framework per sviluppo software sicuro con pratiche di:
- Secure coding
- Software integrity
- Supply chain security 

---

## **FRAMEWORK E MODELLI DI MATURITY**

### **OWASP SAMM (Software Assurance Maturity Model)**
Modello di maturità per la sicurezza software con 5 funzioni di business:
- **Governance**: Strategy, Policy, Education
- **Design**: Threat Assessment, Security Requirements, Secure Architecture  
- **Implementation**: Secure Build, Secure Deployment, Defect Management
- **Verification**: Architecture Assessment, Requirements-driven Testing, Security Testing
- **Operations**: Incident Management, Environment Management, Operational Management

4 livelli di maturità (0-3): Inactive → Initial → Defined → Mastery 

### **BSIMM (Building Security In Maturity Model)**
Modello descrittivo basato su dati reali da 100+ organizzazioni:
- **Governance**: Sponsorizzazione esecutiva, metriche, policy
- **Intelligence**: Knowledge base di minacce e framework
- **SSDL Touchpoints**: Security in design e code review
- **Deployment**: Monitoraggio, testing, risposta in produzione

Maturità su 4 livelli: Emerging → Defined → Measured → Optimized 

### **OWASP ASVS (Application Security Verification Standard)**
Standard di verifica con livelli di verifica:
- **Level 1**: Opportunistic (basic security)
- **Level 2**: Standard (most applications)
- **Level 3**: Advanced (high value, high assurance)

Copre: Architettura, Autenticazione, Access Control, Input Validation, Cryptography, Error Handling, Data Protection, Communications, Malicious Controls, Business Logic, File Upload, Configuration 

---

## **CHECKLIST E CONTROLLI OPERATIVI**

### **Checklist ISO 27001:2022 per SDLC** 
1. **Security Requirements Definition**: Definire e documentare requisiti di sicurezza
2. **Threat Modelling**: Modellazione delle minacce iniziale e periodica
3. **Secure Design Principles**: Principi di secure-by-design
4. **Code Review & Static Analysis**: Revisione codice e SAST
5. **Security Testing**: Penetration testing, vulnerability scanning, CI/CD integration
6. **Secure Coding Practices**: Standard di codifica sicura, training continuo
7. **Configuration Management**: Gestione centralizzata configurazioni sicure
8. **Change Management**: Processo di change management con security impact assessment
9. **Security Awareness**: Training regolare e tracking
10. **Incident Response**: Piani di risposta agli incidenti testati

### **Checklist Vendor Assessment ISO 27036** 
- Validità certificazione ISO 27001 e scope
- Statement of Applicability con mapping controlli SDLC (A.8.25-A.8.29)
- Evidenze CI/CD: SAST, SCA, DAST/IAST, policy gates
- Separazione ambienti dev/test/prod, accesso ristretto a produzione
- Secure coding standards, training records, secret scanning
- Cloud baselines: encryption, logging, key management, change control
- Vulnerability management workflow, SLAs, scope e frequenza pen test
- Clausole sicurezza fornitori, right-to-audit, onboarding assessment

### **CIS Controls** 
18 controlli critici di sicurezza con focus su:
- Inventory and Control of Enterprise Assets
- Secure Configuration Management
- Continuous Vulnerability Management
- Audit Log Management
- Email and Web Browser Protections
- Malware Defenses
- Data Recovery Capabilities
- Security Awareness and Skills Training
- Application Software Security
- Incident Response Management
- Penetration Testing

---

## **STANDARD PER PENETRATION TESTING E CODE AUDIT**

- **OWASP Testing Guide**: Metodologia di penetration testing per applicazioni web
- **PTES (Penetration Testing Execution Standard)**: Standard di esecuzione per penetration test
- **OSSTMM (Open Source Security Testing Methodology Manual)**: Metodologia completa per security testing
- **ISSAF (Information Systems Security Assessment Framework)**: Framework per valutazione sicurezza sistemi informativi

---

## **CERTIFICAZIONI PER FORNITORI E SOFTWARE**

### **SOC 2 Type II** 
Attestazione sui controlli di sicurezza con 5 Trust Services Criteria:
- **Security** (obbligatorio)
- **Availability**
- **Processing Integrity** 
- **Confidentiality**
- **Privacy**

Type II valuta design e operational effectiveness nel tempo (3-12 mesi).

### **PCI DSS (Payment Card Industry Data Security Standard)**
Requisiti specifici per software che elaborano transazioni di pagamento:
- Secure software development
- Penetration testing requirements
- Secure coding guidelines

---

## **MAPPING INTEGRATO PER CONTROLLO FORNITORI IT**

| **Area** | **Standard/Framework** | **Controlli Chiave** |
|----------|------------------------|---------------------|
| **Secure Development** | ISO 27001 A.8.25-A.8.29, NIST SSDF | SDLC, secure coding, security testing |
| **Vulnerability Management** | ISO 29147, ISO 30111 | Disclosure handling, remediation process |
| **Supplier Assessment** | ISO 27036-2, ISO 27036-3 | Due diligence, contractual requirements, monitoring |
| **Code Security** | OWASP ASVS, SAMM, BSIMM | Verification levels, maturity assessment |
| **Federal/Defense** | NIST 800-171, NIST 800-53 | CUI protection, control baselines |
| **Attestation** | SOC 2 Type II | Trust services criteria, operational effectiveness |
| **Product Evaluation** | ISO 15408 (Common Criteria) | EAL levels, protection profiles |

Questo insieme di standard copre l'intero ciclo di vita: dalla definizione dei requisiti di sicurezza, allo sviluppo sicuro, al testing, alla gestione delle vulnerabilità, fino alla valutazione e monitoraggio dei fornitori IT.

 
 
Ecco l'analisi completa sulle **best practice per la scrittura di codice sicuro**, la loro copertura normativa ISO e la variabilità per linguaggio:

---

## **COPERTURA NORMATIVA ISO DELLE BEST PRACTICE DI CODING**

### **ISO/IEC TS 17961:2013 - C Secure Coding Rules**
L'unico standard ISO **specifico per linguaggio** che definisce regole di codifica sicura. È una **Technical Specification** (non uno standard internazionale completo) che:
- Specifica regole per la sicurezza in linguaggio C
- Fornisce esempi di codice compliant e non-compliant
- È progettato per essere **enforceable da analizzatori statici** (SAST)
- È stato confermato valido nel 2024 

**Limitazione**: Copre **solo il linguaggio C**, non è applicabile ad altri linguaggi.

### **ISO/IEC 27001:2022 - Annex A.8.28 Secure Coding**
Il controllo ISO per la sicurezza del codice è **linguaggio-agnostic** ma **richiede adattamento specifico**:

> *"Secure software coding principles should be tailored to each programming language and techniques used"* 

**Requisiti ISO 27001 per secure coding** :
1. **Adozione di standard espliciti**: Non basta dire "codifichiamo in modo sicuro", ma citare framework specifici (OWASP Top 10, SANS Top 25, CERT, PEP 8, etc.)
2. **Input validation**: La "regola d'oro" - mai fidarsi dell'input utente
3. **Supply chain security**: Controllo vulnerabilità nelle librerie di terze parti
4. **Tooling automatizzato**: SAST, IDE plugin, SCA tools
5. **Training annuale obbligatorio** per sviluppatori e reviewer 

### **ISO/IEC 27034 - Application Security**
Fornisce il framework **ONF (Organization Normative Framework)** che include:
- Secure coding practices nei **Security Policies**
- **Application Security Control Baselines** con pratiche di codifica sicura
- Threat modeling e secure design integrati nello sviluppo 

---

## **STANDARD NON-ISO SPECIFICI PER LINGUAGGIO**

Poiché ISO copre solo C in modo specifico, l'industria si affida a questi standard **de facto**:

### **CERT Secure Coding Standards**
Mantenuti dal Software Engineering Institute della Carnegie Mellon University:
- **CERT C** (2016) - Allineato con ISO/IEC TS 17961
- **CERT C++** (2016)
- **CERT Java**
- **CERT Android**
- **CERT Perl**

**Struttura**: Regole (obbligatorie) vs Raccomandazioni (opzionali) 

### **MISRA C/C++**
Originariamente per automotive, ora adottato in aerospace, medical, industrial:
- **MISRA C:2012 Amendment 1**: Aggiunge 14 regole focalizzate sulla **sicurezza** (oltre alla safety)
- Allineato con ISO C Secure Guidelines
- Richiesto da standard funzionali come **ISO 21434** (cybersecurity automotive) e **IEC 81001** 

### **OWASP Secure Coding Practices**
- **Language-agnostic** ma con focus su web/mobile (Java, JavaScript, Python)
- **OWASP ASVS**: Verification Standard con livelli di compliance
- **OWASP Top 10**: Riferimento obbligatorio per ISO 27001 

### **NIST SP 800-218 (SSDF)**
Secure Software Development Framework con linee guida di codifica sicura supportate dal governo US 

---

## **VARIABILITÀ PER LINGUAGGIO: SÌ, CAMBIANO SOSTANZIALMENTE**

Le best practice **variano significativamente** da linguaggio a linguaggio. Ecco il mapping:

| **Linguaggio** | **Standard Specifico** | **Vulnerabilità Principali** | **Best Practice Chiave** |
|----------------|------------------------|------------------------------|--------------------------|
| **C** | ISO/IEC TS 17961, CERT C, MISRA C | Buffer overflow, memory leaks, use-after-free | Gestione manuale memoria, bounds checking, evitare funzioni unsafe (strcpy, gets) |
| **C++** | CERT C++, MISRA C++:2008, AUTOSAR C++ | Memory corruption, exception handling | RAII, smart pointers, evitare raw pointers |
| **Java** | Google Java Style Guide, CERT Java | Injection, serialization flaws, XXE | Type safety, sandboxing JVM, secure deserialization |
| **Python** | PEP 8, OWASP Python | Injection, dependency confusion, dynamic typing issues | Input validation, type hints, virtual environments |
| **JavaScript/TypeScript** | Google JS/TS Style Guide | XSS, prototype pollution, NPM vulnerabilities | CSP, strict mode, dependency scanning |
| **C#** | Microsoft C# Coding Conventions | Injection, deserialization, misconfiguration | .NET security APIs, LINQ injection prevention |
| **Rust** | Rust API Guidelines, Cargo | Logic errors, unsafe blocks (anche se raro) | Ownership system, borrow checker, evitare unsafe |
| **Go** | Effective Go | Logic errors, race conditions | Goroutine safety, context management |
| **Swift** | Apple Swift Guidelines | Null pointer, memory safety | Optionals, ARC (Automatic Reference Counting) |
| **PHP** | WordPress PHP Standards | SQL injection, XSS, RFI | Prepared statements, output encoding |

### **Esempio Concreto: Buffer Overflow**
- **C/C++**: Possibile e comune → Richiede controlli manuali bounds, uso di `strncpy` vs `strcpy`
- **Java/C#/Python/Rust**: Impossibile per design (memory safety) → Il problema non esiste a livello di codice utente 

### **Memory Safety vs Logic Security**
Secondo l'analisi delle vulnerabilità:
- **C**: 47% di tutte le vulnerabilità segnalate (maggiore esposizione)
- **PHP**: 23%
- **Python**: 6% (più basso) 

**Nota**: Linguaggi memory-safe (Java, C#, Go, Rust) eliminano intere classi di vulnerabilità (buffer overflow, use-after-free) ma **non proteggono da**:
- SQL injection
- Authentication bypass
- Business logic flaws
- Logic errors (es. CVE-2024-045537 in Go) 

---

## **CHECKLIST INTEGRATA PER COMPLIANCE ISO 27001 + BEST PRACTICE LINGUAGGIO-SPECIFICHE**

### **Fase 1: Pianificazione (Before Coding)**
- [ ] Definire **secure coding standard specifico per linguaggio** (CERT C per C, PEP 8 per Python, etc.)
- [ ] Configurare IDE con plugin di sicurezza (SonarLint, etc.)
- [ ] Threat modeling per identificare attack surface
- [ ] Training annuale obbligatorio per sviluppatori 

### **Fase 2: Sviluppo (During Coding)**
- [ ] **Input validation** specifico per linguaggio (allowlist, type checking, sanitization)
- [ ] **Pair programming** e **code review** obbligatori
- [ ] **No hardcoded secrets** (usare vault/secrets management)
- [ ] **Dependency scanning** (SCA) per librerie di terze parti
- [ ] Documentazione del codice e rimozione defect immediata 

### **Fase 3: Verifica (After Coding)**
- [ ] **SAST** integrato in CI/CD (Controllo ISO 27001 A.8.29)
- [ ] **DAST** per testing runtime
- [ ] Penetration testing per applicazioni high-risk
- [ ] Code review security-focused (OWASP Top 10, CWE Top 25) 

### **Fase 4: Manutenzione**
- [ ] Monitoraggio log per errori e attacchi sospetti
- [ ] Gestione vulnerabilità reportate (ISO 29147, ISO 30111)
- [ ] Aggiornamento continuo delle librerie
- [ ] Review retrospettiva emergency changes entro 48h 

---

## **SINTESI**

| **Aspetto** | **Copertura ISO** | **Gap** | **Soluzione Industria** |
|-------------|-------------------|---------|-------------------------|
| **Standard specifico linguaggio** | Solo C (ISO/IEC TS 17961) | Altri linguaggi non coperti | CERT, MISRA, Google Style Guides, PEP 8 |
| **Framework generale secure coding** | ISO 27001 A.8.28, ISO 27034 | Troppo generico | OWASP, NIST SSDF, BSIMM, SAMM |
| **Verifica compliance** | Audit ISO 27001 | Nessuno standard di codifica universalmente applicabile | Adozione multi-standard per linguaggio |
| **Training & certificazione** | Richiesto da ISO 27001 | Nessun certificato ISO specifico per developer | Certificazioni vendor (ISC2, SANS, EC-Council) |

**Conclusione**: Le best practice di secure coding **variano necessariamente** da linguaggio a linguaggio. ISO fornisce il framework di governance (ISO 27001/27034) e uno standard tecnico solo per C. Per gli altri linguaggi, le organizzazioni devono adottare standard di settore (CERT, MISRA, OWASP) e dimostrare durante gli audit ISO 27001 come questi siano integrati nel SDLC con training, tool e verifiche specifiche.

 
Perfetto, ecco l'integrazione completa sulle **best practice per codice pulito (clean code)** e la loro relazione con gli standard ISO:

---

## **CODICE PULITO VS CODICE SICURO: DUE FACCE DELLA STESSA MEDAGLIA**

### **Definizioni ISO**

Secondo la famiglia **ISO/IEC 25000 (SQuaRE)** - *System and Software Quality Requirements and Evaluation*:

- **Codice Pulito** → rientra nelle caratteristiche di **Maintainability** (manutenibilità) e **Reliability** (affidabilità)
- **Codice Sicuro** → rientra nella caratteristica di **Security** (sicurezza)

Entrambe sono **qualità interne** del software misurabili a livello di codice sorgente .

---

## **STANDARD ISO PER LA QUALITÀ DEL CODICE (CLEAN CODE)**

### **1. ISO/IEC 25010:2011/2022 - Modello di Qualità Software**
Definisce 8/9 caratteristiche di qualità, di cui **4 misurabili a livello codice**:

| **Caratteristica** | **Sub-caratteristiche rilevanti per Clean Code** | **Cosa significa per il codice** |
|-------------------|--------------------------------------------------|----------------------------------|
| **Maintainability** | Modularity, Reusability, Analysability, Modifiability, Testability | Codice leggibile, ben strutturato, facile da modificare e testare  |
| **Reliability** | Maturity, Availability, Fault Tolerance, Recoverability | Codice robusto, gestione errori, nessun crash imprevisto |
| **Performance Efficiency** | Time Behaviour, Resource Utilization, Capacity | Codice ottimizzato, non spreca risorse |
| **Security** | Confidentiality, Integrity, Non-repudiation | Codice che protegge dati e funzionalità |

**Criticità ISO 25010**: Lo standard **non include esplicitamente** proprietà come *leggibilità*, *struttura interna* e *pulizia del codice* nel modello di qualità, considerato un grave deficit da esperti .

### **2. ISO/IEC 5055:2021 - Automated Source Code Quality Measures**
Questo è lo **standard ISO più importante per il codice pulito**. Definisce **misure automatizzate** della qualità interna del codice analizzando:

- **Violazioni di buone pratiche architetturali e di coding**
- **Weaknesses strutturali** che impattano su 4 fattori critici:
  1. **Security** (sicurezza)
  2. **Reliability** (affidabilità)
  3. **Performance Efficiency** (efficienza)
  4. **Maintainability** (manutenibilità → **codice pulito**) 

**Come funziona**:
- Analisi statica del codice (SAST)
- Conteggio violazioni regole (es. dipendenze circolari, error handling scadente, complessità eccessiva)
- Trasformazione in metriche comparabili (densità di weakness, livello sigma) 

**Esempi di weakness rilevabili** :
- "Ban Unintended Paths" (architettural weakness che viola sicurezza)
- Dipendenze circolari (impattano manutenibilità)
- Poor error handling (impatta affidabilità)

### **3. ISO/IEC 25000 (SQuaRE) - Series Complete**
Serie di 20+ standard che coprono:
- **ISO 25010**: Quality Model
- **ISO 25023**: External Quality Measures (comportamentali)
- **ISO 25030**: Quality Requirements
- **ISO 25040**: Quality Evaluation

**Gap critico**: ISO 25023 misura qualità **comportamentale** (es. ore di availability), mentre **ISO 5055** misura qualità **strutturale** del codice (es. flaw che causano downtime) .

---

## **CODICE PULITO: VARIA PER LINGUAGGIO? SÌ, MA CON PRINCIPI COMUNI**

### **Principi Universali (Language-Agnostic)**
Secondo ISO 5055 e best practice industry:

1. **Modularity** → Componenti indipendenti, basso accoppiamento
2. **Analysability** → Facile da capire, documentato
3. **Modifiability** → Cambiamenti localizzati, nessun effetto collaterale
4. **Testability** → Codice testabile automaticamente
5. **Reusability** → Componenti riutilizzabili 

### **Pratiche Specifiche per Linguaggio**

| **Linguaggio** | **Standard Clean Code** | **Focus Specifico** | **Metriche ISO 5055 applicabili** |
|----------------|-------------------------|---------------------|-----------------------------------|
| **C/C++** | MISRA C/C++, CERT C, ISO TS 17961 | Gestione memoria, bounds checking, no undefined behavior | Memory leaks, buffer overflow, pointer errors  |
| **Java** | Google Java Style, CERT Java | OOP patterns, exception handling, concurrency | Cyclomatic complexity, coupling, cohesion |
| **Python** | PEP 8, Google Python Style | Readability, dynamic typing safety, indentation | Code duplication, function length, import structure |
| **JavaScript/TypeScript** | Google JS/TS Guide, Airbnb Style | Async patterns, module systems, type safety | Callback hell, dependency complexity |
| **C#** | Microsoft C# Conventions | .NET patterns, LINQ, async/await | Class coupling, method complexity |
| **Rust** | Rust API Guidelines, Rustfmt | Ownership, borrowing, unsafe blocks | Unsafe block usage, lifetime complexity |
| **Go** | Effective Go | Concurrency patterns, error handling, formatting | Goroutine leaks, error handling consistency |

### **Esempio: Gestione Errori**
- **C**: Richiede controllo manuale return codes (ISO TS 17961)
- **Java**: Eccezioni checked vs unchecked (CERT Java)
- **Rust**: Result<T,E> pattern (linguaggio enforce error handling)
- **Go**: `if err != nil` pattern idiomatico

Tutti validi secondo ISO 5055, ma **implementazione linguaggio-specifica** .

---

## **MAPPING CLEAN CODE + SECURE CODE NEGLI STANDARD**

### **ISO 27001:2022 - Integrazione Clean + Secure**
**Annex A.8.28 Secure Coding** richiede:
- Standard di codifica sicura **per linguaggio** (CERT, OWASP, MISRA)
- **Ma implica anche**: standard di qualità del codice (leggibilità, manutenibilità) perché:
  - Codice pulito = meno bug = meno vulnerabilità
  - Codice complesso = difficile da auditare security 

### **Checklist Integrata ISO 5055 + ISO 27001**

| **Fase** | **Clean Code (ISO 5055)** | **Secure Code (ISO 27001/27034)** |
|----------|---------------------------|-----------------------------------|
| **Design** | Modularity, low coupling | Threat modeling, secure architecture |
| **Coding** | Naming conventions, comments, formatting | Input validation, no hardcoded secrets |
| **Review** | Code review (readability, complexity) | Security review (SAST, vulnerability scan) |
| **Testing** | Unit tests, coverage >80% | Penetration testing, DAST |
| **Deploy** | Configuration management | Secure deployment, secrets management |
| **Monitor** | Technical debt tracking | Vulnerability disclosure handling |

---

## **CERTIFICAZIONI E VALUTAZIONE**

### **Non esiste "Certificazione ISO di Clean Code"**
Ma esistono **valutazioni conformi a ISO 5055**:
- **CISQ (Consortium for IT Software Quality)**: Ha sviluppato le misure poi approvate come ISO 5055
- **Tool conformi ISO 5055**: SonarQube, CAST, CodeScene (misurano le 4 caratteristiche ISO 5055)
- **Audit ISO 25000**: Valutazione terza parte della qualità software 

### **Metriche Chiave ISO 5055 per Clean Code** 

1. **Maintainability Index**:
   - Densità di weakness per KLOC (thousand lines of code)
   - Complessità ciclomatica media
   - Technical debt ratio

2. **Reliability Index**:
   - Error handling coverage
   - Exception management quality
   - Resource leak detection

3. **Performance Efficiency Index**:
   - Resource utilization patterns
   - Algorithmic complexity

---

## **SINTESI: RELAZIONE TRA STANDARD**

```
┌─────────────────────────────────────────────────────────────┐
│                    ISO/IEC 25000 (SQuaRE)                   │
│              Framework generale qualità software              │
├─────────────────────────────────────────────────────────────┤
│  ISO 25010 (Quality Model)        ISO 5055 (Code Measures)  │
│  - 8 caratteristiche qualità      - Misure automatizzate    │
│  - Maintainability                - 4 fattori critici       │
│  - Security                       - Weaknesses detection    │
│  - Reliability                    - Language-independent    │
│  - Performance                    - Applicabile a tutti     │
│                                   - linguaggi               │
├─────────────────────────────────────────────────────────────┤
│              ISO 27001 (Information Security)               │
│   - Annex A.8.28 Secure Coding (richiede entrambi)          │
│   - Integra qualità codice + sicurezza                      │
└─────────────────────────────────────────────────────────────┘
```

**Conclusione**: 
- **ISO 5055** è lo standard chiave per il **codice pulito** (maintainability, reliability)
- **ISO 27001/27034** per il **codice sicuro**
- **Entrambi necessari**: Codice pulito facilita la sicurezza; codice sicuro richiede buona qualità strutturale
- **Variano per linguaggio**: I principi ISO sono universali, ma le regole specifiche (naming, patterns, costrutti vietati) sono linguaggio-specifiche e definite da standard complementari (CERT, MISRA, Google Style, PEP 8) 

 
Ecco il panorama completo dei **framework, linee guida e strumenti per codice pulito** che esistono al di fuori delle ISO, con metriche concrete e standard di fatto:

---

## **FRAMEWORK E STANDARD INDUSTRIALI PER CODICE PULITO**

### **1. SQALE (Software Quality Assessment based on Lifecycle Expectations)**
Il metodo dietro le metriche di SonarQube, diventato **standard de facto**:

**Metriche chiave**:
- **Technical Debt**: Costo per fixare i problemi di manutenibilità (in minuti/giorni)
- **Technical Debt Ratio**: `debito tecnico / (costo sviluppo per riga × righe codice)`
- **Maintainability Rating** (scala A-E):
  - **A** = 0-5% debito tecnico
  - **B** = 6-10%
  - **C** = 11-20%
  - **D** = 21-50%
  - **E** = >50%

**Soglia default**: Costo sviluppo 1 riga = 30 minuti 

---

### **2. Maintainability Index (MI) - Standard Microsoft/Industriale**
Formula matematica per misurare manutenibilità:

**Formula originale**:
```
MI = 171 - 5.2 × ln(Halstead Volume) - 0.23 × (Cyclomatic Complexity) - 16.2 × ln(Lines of Code)
```

**Formula normalizzata** (0-100):
```
MI = MAX(0, (formula sopra) × 100 / 171)
```

**Interpretazione** (Visual Studio/Microsoft):
| **Valore** | **Colore** | **Significato** |
|------------|------------|-----------------|
| 0-9 | Rosso | Bassa manutenibilità |
| 10-19 | Giallo | Moderata |
| 20-100 | Verde | Buona manutenibilità |

**Variante Testwell** (CMT++/CMTJava):
- ≥85: Buona manutenibilità
- 65-85: Moderata
- <65: Difficile da mantenere
- Negativo: Codice molto grave 

---

### **3. SonarQube Quality Model - Clean Code Standard**
SonarQube (piattaforma leader) definisce **3 qualità del software**:

| **Qualità** | **Cosa misura** | **Metriche** |
|-------------|-----------------|--------------|
| **Maintainability** | Code smells, technical debt | Debt ratio, rating A-E, remediation effort |
| **Reliability** | Bugs, errori runtime | Bug count, rating A-E, stability |
| **Security** | Vulnerabilità, hotspot | Vuln count, rating A-E, review status |

**Code Smells rilevati**:
- Duplicazioni codice
- Complessità ciclomatica eccessiva
- Metodi troppo lunghi
- Classi con troppi responsabilità (God Class)
- Commenti insufficienti 

---

### **4. CAST Imaging - Analisi Strutturale Avanzata**
Tool enterprise che implementa **ISO 5055** con:
- **Structural Rules**: Regole predefinite di qualità codice
- **Flaw Detection**: Security Flaws, Performance Flaws, Error Handling Flaws
- **Remediation Path**: Percorso guidato per fixare i problemi

**Allineamento ISO 5055**: Misura le 4 caratteristiche (Security, Reliability, Performance, Maintainability) tramite analisi statica strutturale 

---

## **METRICHE STANDARDIZZATE PER CODICE PULITO**

### **Metriche di Base (Universalmente riconosciute)**

| **Metrica** | **Descrizione** | **Tool che la implementano** | **Soglia buona** |
|-------------|-----------------|------------------------------|------------------|
| **Cyclomatic Complexity** | Numero percorsi indipendenti nel codice | Tutti (SonarQube, CAST, CMT++) | ≤10 per metodo |
| **Cognitive Complexity** | Difficoltà di comprensione umana | SonarQube | ≤15 per metodo |
| **Lines of Code (LOC)** | Dimensione codebase | Tutti | Dipende da contesto |
| **Code Duplication** | Percentuale codice duplicato | SonarQube, CAST | <3% |
| **Comment Density** | Rapporto linee commento/codice | Tutti | 20-30% |
| **Depth of Inheritance** | Livelli gerarchia classi | CMT++, Visual Studio | ≤3 |
| **Coupling** | Grado dipendenza tra moduli | CAST, CMT++ | Basso accoppiamento |
| **Halstead Volume** | Misura dimensione "mentale" codice | CMT++, tool accademici | Basso = meglio |
| **Maintainability Index** | Indice sintetico 0-100 | Visual Studio, CMT++ | ≥20 (o ≥65) |



---

## **LINEE GUIDA E FRAMEWORK SPECIFICI PER LINGUAGGIO**

### **Principi Universali (Language-Agnostic)**
1. **Single Responsibility Principle**: Una classe/metodo = una responsabilità
2. **DRY (Don't Repeat Yourself)**: Nessuna duplicazione
3. **KISS (Keep It Simple, Stupid)**: Semplicità > complessità
4. **SOLID principles**: Design patterns orientati alla manutenibilità

### **Standard Specifici per Linguaggio**

| **Linguaggio** | **Style Guide ufficiale/de facto** | **Focus Clean Code** |
|----------------|-----------------------------------|---------------------|
| **Python** | PEP 8 (Python Enhancement Proposal 8) | Indentazione, naming conventions, line length (79 char), docstrings |
| **Java** | Google Java Style Guide, Oracle Code Conventions | CamelCase, class length, method ordering, Javadoc |
| **C#** | Microsoft C# Coding Conventions | PascalCase vs camelCase, brace style, LINQ formatting |
| **JavaScript/TypeScript** | Airbnb JavaScript Style Guide, Google TS Guide | ES6+ features, async/await patterns, type safety |
| **C/C++** | MISRA C/C++, Google C++ Style | Naming, scoping, memory management, no goto |
| **Go** | Effective Go (ufficiale) | Idiomatic Go, goroutine patterns, error handling |
| **Rust** | Rust API Guidelines, Rustfmt | Ownership patterns, unsafe block minimization |
| **Ruby** | Ruby Style Guide (bbatsov) | Metaprogramming guidelines, DSL design |
| **PHP** | PSR-1/PSR-2 (PHP Standards Recommendations) | Autoloading, naming, coding style |

---

## **CERTIFICAZIONI E PROGRAMMI DI VALUTAZIONE**

### **Non esistono certificazioni ISO per "Clean Code"**, ma esistono:

| **Programma** | **Ente** | **Focus** | **Riconoscimento** |
|---------------|----------|-----------|-------------------|
| **CISQ (Consortium for IT Software Quality)** | OMG (Object Management Group) | Standard per misurazione qualità codice (ISO 5055) | Industria IT enterprise |
| **SonarQube Developer Certification** | SonarSource | Utilizzo piattaforma quality gate | Aziende tech |
| **CAST Software Analysis** | CAST Software | Valutazione conformità ISO 5055 | Enterprise, governo |
| **CodeScene Certification** | CodeScene | Code health, technical debt management | Team engineering |

---

## **CHECKLIST OPERATIVA: CLEAN CODE + ISO 5055**

### **Prima dello sviluppo**
- [ ] Definire **Quality Gate** (es. SonarQube): max 3% duplicazione, MI ≥20, 0 blocker issues
- [ ] Scegliere **style guide** specifico per linguaggio
- [ ] Configurare IDE con linter (ESLint, Pylint, Checkstyle, etc.)
- [ ] Setup pre-commit hooks per formattazione automatica

### **Durante lo sviluppo**
- [ ] **Naming**: nomi descrittivi (intenti rivelativi, non `x`, `y`, `data`)
- [ ] **Funzioni**: <20 linee, 1 responsabilità, max 3 parametri
- [ ] **Classi**: <200 linee, coesione alta, accoppiamento basso
- [ ] **Commenti**: spiegano il "perché", non il "cosa" (il codice deve essere auto-esplicativo)
- [ ] **Formattazione**: consistenza indentazione, spazi, parentesi

### **Code Review**
- [ ] **Cyclomatic Complexity** ≤10 per metodo
- [ ] **Cognitive Complexity** ≤15
- [ ] **Code Coverage** ≥80% (unit test)
- [ ] **0 Code Smells** critici (SonarQube blocker/critical)
- [ ] **Technical Debt Ratio** <5% per nuovo codice

### **Post-deploy**
- [ ] Monitoraggio **Maintainability Index** trend
- [ ] Tracking **Technical Debt** backlog
- [ ] Refactoring continuo quando MI scende sotto 20

---

## **SINTESI: STANDARD VS ISO**

| **Aspetto** | **ISO 5055** | **Standard Industria (SQALE, MI, SonarQube)** |
|-------------|--------------|-----------------------------------------------|
| **Leggibilità** | Indiretta (via Maintainability) | Diretta (code smells, naming conventions) |
| **Struttura interna** | Sì (architectural weaknesses) | Sì (complexity, coupling, cohesion) |
| **Pulizia codice** | Sì (manutenibilità) | Sì (technical debt, code smells) |
| **Misurazione** | Automatizzata (SAST) | Automatizzata + Quality Gates |
| **Linguaggio-specifico** | No (generico) | Sì (regole per linguaggio) |
| **Certificazione** | Valutazione terza parte | Badge SonarQube, report CAST |

**Conclusione**: Non esiste una ISO dedicata esclusivamente al "clean code" come concetto di leggibilità e stile, ma **ISO 5055** copre la qualità strutturale e manutenibilità, mentre gli **standard industriali (SQALE, MI, SonarQube)** forniscono il framework operativo, le metriche concrete e le soglie di accettabilità usate quotidianamente nelle aziende tech.