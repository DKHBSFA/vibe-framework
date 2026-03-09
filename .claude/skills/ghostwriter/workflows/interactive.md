# Interactive Workflow

Step-by-step guide for running SEO-GEO-Copy skill interactively.

---

## Command: `/ghostwriter write`

### Phase 0: Reference Discovery (Automatic)

Before asking questions, check for reference materials:

```
1. Check if reference/ directory exists
2. If exists:
   - Read reference/brand.md (voice, tone, terminology)
   - Read reference/context.md (business goals, constraints)
   - List reference/products/ contents
3. Use this context to:
   - Pre-fill tone/audience questions if specified
   - Offer product selection if products exist
   - Apply brand rules during generation
```

**If reference materials found, inform user:**
```
Found reference materials:
- Brand guidelines: [loaded/not found]
- Project context: [loaded/not found]
- Products: [X files found]

Using these to inform content generation.
```

### Phase 1: Intake Questions

**Ask in sequence:**

```
1. What type of content?
   [ ] Article / Blog Post
   [ ] Landing Page
   [ ] Product Description
   [ ] FAQ Section
   [ ] Homepage
   [ ] Category Page
   [ ] About Page
   [ ] Other: ___

2. What is the topic or subject?
   [Free text]

3. Who is the target audience?
   - Demographics: ___
   - Expertise level: [ ] Beginner [ ] Intermediate [ ] Expert
   - Primary pain point: ___

4. What is the primary keyword?
   [Free text]
   (I'll suggest if blank based on topic)

5. What action should readers take?
   [ ] Learn / Understand
   [ ] Compare options
   [ ] Sign up / Subscribe
   [ ] Purchase / Buy
   [ ] Contact / Inquire
   [ ] Download / Get
   [ ] Other: ___

6. Any specific requirements?
   - Word count: [ ] Short (<500) [ ] Medium (500-1500) [ ] Long (1500+)
   - Tone: [ ] Formal [ ] Conversational [ ] Technical [ ] Friendly
   - Must include: ___
   - Must avoid: ___
```

### Phase 2: Research & Planning

**I do this automatically:**

1. Analyze keyword intent
2. Draft content structure
3. Identify related keywords
4. Plan internal linking opportunities
5. Select appropriate schema type

**Show user:**
```
## Content Plan

**Target keyword:** [keyword]
**Search intent:** [informational/commercial/transactional]
**Recommended word count:** [range]
**Content structure:**
1. [H2 section 1]
2. [H2 section 2]
3. [H2 section 3]
...

**Schema type:** [Article/Product/FAQ/etc.]

Proceed with this plan? [Yes / Adjust]
```

### Phase 3: Generation

**Generate content following:**
1. Load appropriate generation prompt from `/generation/[type].md`
2. Apply all output checklist items
3. Generate full content
4. Generate SEO metadata
5. Generate Schema.org JSON-LD

### Phase 4: Validation

**Run validation automatically:**
1. Load rules from `/validation/rules.md`
2. Apply all relevant rules
3. Generate validation report
4. If score < 90%, fix issues automatically
5. Re-validate after fixes

### Phase 4.5: Technical Infrastructure Gate (MANDATORY)

**After validation passes, run the Delivery Gate from SKILL.md before delivering.**

This gate ensures technical infrastructure is delivered as **generated code**, not deferred to a checklist.

```
For EVERY deliverable, verify and generate:

1. TITLE CHECK
   - Count characters (hard max 60)
   - Count brand occurrences (max 1)
   → If fail: rewrite title immediately

2. <head> META BLOCK
   - Canonical tag with real URL
   - ALL 6 OpenGraph tags as HTML code
   - Content freshness meta (og:updated_time / article:modified_time)
   - Twitter Card tags
   → If ANY missing: generate the complete HTML block

3. SCHEMA.ORG
   - JSON-LD present and valid for content type
   → If missing: generate from templates/schemas/

4. EXTERNAL LINKS
   - Landing pages: ≥1 external link
   - Articles: ≥2 external links
   → If zero: ADD authoritative external links to the content body

5. LINK INTEGRITY
   - No placeholder URLs (example.com, #, javascript:void)
   - No known-dead domains
   → If found: replace with real URLs or explicit [TODO] markers

6. SERVER CONFIG SECTION
   - robots.txt template included
   - Sitemap guidance included
   - WWW canonicalization snippet included (stack-specific)
   - Last-Modified header guidance included
   → If ANY missing: generate the code/config

RESULT: All checks pass → proceed to Phase 5.
         Any BLOCKER fails → fix, then re-check before proceeding.
```

**Why this gate exists:** In previous audits (Rank Math 68/100), all failing items were covered by existing rules but were output as "checklist items for later" instead of generated code. This gate forces code generation.

### Phase 5: Delivery

**Present to user:**
```
## Generated Content

[Full content]

---

## SEO Metadata

[Title, description, URL slug]

---

## Schema.org JSON-LD

[JSON-LD code block]

---

## Validation Report

[Summary scores and any remaining issues]

---

## Next Steps

- [ ] Review and approve content
- [ ] Add to CMS
- [ ] Add internal links from existing pages
- [ ] Schedule publication
```

---

## Command: `/ghostwriter optimize`

### Phase 1: Input Collection

```
1. Provide the content to optimize:
   [ ] File path: ___
   [ ] URL: ___
   [ ] Directory: ___

2. What is the target keyword? (optional — I'll identify from content)
   [Free text]

3. What type of content is this?
   [ ] Article / Blog Post
   [ ] Landing Page
   [ ] Product Description
   [ ] Category Page
   [ ] Homepage
   [ ] Full site / multiple pages
```

### Phase 2: Audit (Automatic)

**I do this automatically and save results to `.ghostwriter/audit-report.md`:**

1. **SEO Analysis**
   - Title tag, meta description, H1 optimization
   - Keyword placement and density
   - Internal/external linking structure
   - Technical factors (canonical, schema, OG tags, freshness)

2. **GEO Analysis**
   - Answer-first structure assessment
   - Chunk retrievability score
   - Entity clarity evaluation
   - Citation potential rating

3. **Copywriting Analysis**
   - Hook strength
   - Value proposition clarity
   - Call-to-action effectiveness
   - Persuasion framework identification

4. **Validation** against `validation/rules.md` (52 rules)

**Output: `.ghostwriter/audit-report.md`** with scores, BLOCKER issues, and prioritized recommendations with generated fix code.

### Phase 3: Optimization Spec

**Present before making changes:**

```
## Optimization Spec: [Title]

### Current Score: X/52 (X%)

### BLOCKER Issues (Must Fix)
1. [Issue] - [Generated code to fix]

### Proposed Changes

**SEO:** [list with current → proposed]
**GEO:** [list with rationale]
**Copy:** [list with expected impact]
**Infra:** [missing schema/meta/OG/robots/llms.txt]

### Impact Estimate
- Score: X → Y (+Z%)
```

### Phase 4: PROCEED Gate

User approves, customizes, or stops here (audit-only use case).

### Phase 5: Execution

1. Apply approved changes
2. Generate missing infra (schema, meta, OG, robots.txt, llms.txt)
3. Re-validate against `validation/rules.md`
4. Update `.ghostwriter/audit-report.md` with post-fix scores

---

## Error Handling

### If User Provides Incomplete Info

```
I need a bit more information to create [high-quality content type]:

Missing: [specific field]
Why it matters: [brief explanation]

Please provide: ___
```

### If Validation Fails Repeatedly

```
I'm having trouble getting this above 90% quality. The main issues are:

1. [Persistent issue]
2. [Persistent issue]

Options:
[ ] Accept current version (X% score)
[ ] Provide additional information about: [what's needed]
[ ] Adjust requirements to: [suggestion]
```

### If Content Type Not Supported

```
I don't have a specific generation prompt for [type], but I can:

[ ] Adapt the Article template
[ ] Adapt the Landing Page template
[ ] Create custom structure based on your needs

Which approach would you prefer?
```
