# Landing Page Generation Prompt

## Pre-Generation Questions

### Required
1. **Product/Service**: What are you selling/offering?
2. **Primary CTA**: What action should visitors take? (buy, signup, demo, contact)
3. **Target audience**: Who is this for? (demographics, pain points, awareness level)
4. **Key differentiator**: Why choose this over alternatives?

### Optional
5. **Price point**: (affects copy strategy - high ticket vs impulse buy)
6. **Social proof available**: Reviews, testimonials, logos, numbers?
7. **Objections to address**: Common hesitations?
8. **Tone**: (default: confident, benefit-focused)
9. **Urgency elements**: Limited time/quantity? (use only if genuine)

---

## Generation Template (Above the Fold)

```markdown
# [HEADLINE: Primary benefit + target audience clarity]
## [SUBHEADLINE: Expand on how, or address key objection]

[Hero paragraph: 2-3 sentences. Problem → Solution → Outcome.
Be specific. "Save 10 hours/week" beats "Save time".]

[PRIMARY CTA BUTTON: Action verb + benefit. "Start Free Trial" not "Submit"]

[Trust signal: "Trusted by 10,000+ teams" or "No credit card required"]
```

## Generation Template (Body)

```markdown
## [Problem Section Header - Agitate the pain]

[Describe the current painful state. Be specific and empathetic.
Use "you" language. Make them feel understood.]

- Pain point 1 with emotional weight
- Pain point 2 with specific scenario
- Pain point 3 with consequences

## [Solution Section Header - Present the transformation]

[Introduce your product as the bridge from pain to desired state.
Focus on outcomes, not features.]

### [Feature 1 → Benefit]
[What it does → What they get. Always connect to their life/work.]

### [Feature 2 → Benefit]
[Same pattern. Specific > Vague.]

### [Feature 3 → Benefit]
[Same pattern.]

## [Social Proof Section]

> "[Testimonial that addresses key objection or confirms key benefit]"
> — **Name**, Title at Company

[Or: Logos of recognizable customers]
[Or: "[X] customers served" with specific number]

## [Objection Handling / FAQ]

**[Common objection as question]?**
[Direct answer that reframes or resolves]

**[Another objection]?**
[Direct answer]

## [Final CTA Section]

### [Restate core value proposition]

[Final persuasive paragraph. Summarize transformation.
Create urgency only if genuine.]

[PRIMARY CTA BUTTON - Same as above]

[Risk reversal: "30-day money-back guarantee" or "Cancel anytime"]
```

---

## Framework Selection Guide

Choose based on awareness level:

| Audience Awareness | Framework | Why |
|--------------------|-----------|-----|
| Unaware of problem | PAS | Need to establish pain first |
| Problem-aware | AIDA | They know pain, show solution |
| Solution-aware | BAB | Show your specific transformation |
| Product-aware | PASTOR | Full persuasion, overcome objections |
| Most aware | Direct CTA | They're ready, don't oversell |

---

## Output Checklist

### Conversion (6 checks)
- [ ] Headline communicates core benefit in <10 words
- [ ] CTA is visible above fold
- [ ] Value proposition clear within 5 seconds of reading
- [ ] Social proof present
- [ ] Objections addressed
- [ ] Risk reversal included (guarantee, free trial, etc.)

### SEO (4 checks)
- [ ] Primary keyword in H1 and first paragraph
- [ ] Meta title ≤55 chars, meta description 120-155 chars (count characters precisely)
- [ ] Page has sufficient content for ranking (500+ words)
- [ ] Minimum 4 H2 sections for content structure

### GEO (4 checks)
- [ ] Opening paragraph is extractable as product summary
- [ ] Features/benefits stated clearly (not hidden in clever copy)
- [ ] Specific claims (numbers, percentages, timeframes)
- [ ] Brand and product names stated explicitly

### Copy Quality (4 checks)
- [ ] No jargon without explanation
- [ ] "You" language dominates over "we"
- [ ] Benefits > Features throughout
- [ ] One clear CTA (not multiple competing actions)

---

## Example Output Format

```
## Generated Landing Page

[The page content with sections marked]

---

## Conversion Elements

**Primary CTA:** [The button text]
**Secondary CTA:** [If applicable]
**Risk Reversal:** [Guarantee/trial/etc.]
**Key Social Proof:** [What's used]

---

## SEO Metadata

**Title tag:** [≤55 chars] — Character count: [X]/55
**Meta description:** [120-155 chars] — Character count: [X]/155
**Target keyword:** [keyword]

---

## Schema.org JSON-LD

[Appropriate schema - Product, Service, or Organization]

---

## Technical Infrastructure Code (MANDATORY)

**This section is NOT a checklist — it is generated code that MUST be included in the deliverable.**
If any block is missing, the deliverable is incomplete. These are BLOCKER items.

### `<head>` Meta Block

Generate this COMPLETE block with real values (not placeholders, except og:image which needs user input):

```html
<!-- Canonical -->
<link rel="canonical" href="https://[domain]/[path]" />

<!-- Open Graph (ALL 6 REQUIRED) -->
<meta property="og:title" content="[title tag content]" />
<meta property="og:description" content="[meta description content]" />
<meta property="og:image" content="[TODO: provide image URL — 1200x630px recommended]" />
<meta property="og:url" content="https://[domain]/[path]" />
<meta property="og:type" content="website" />
<meta property="og:site_name" content="[brand name]" />

<!-- Content Freshness -->
<meta property="article:published_time" content="[YYYY-MM-DDTHH:MM:SSZ]" />
<meta property="og:updated_time" content="[YYYY-MM-DDTHH:MM:SSZ]" />

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="[title tag content]" />
<meta name="twitter:description" content="[meta description content]" />
<meta name="twitter:image" content="[same as og:image]" />
```

### robots.txt Template

```
User-agent: *
Allow: /

# AI Search Bots (allow for visibility)
User-agent: OAI-SearchBot
Allow: /

User-agent: ChatGPT-User
Allow: /

User-agent: ClaudeBot
Allow: /

User-agent: PerplexityBot
Allow: /

# Sitemap
Sitemap: https://[domain]/sitemap.xml
```

### WWW Canonicalization

**Choose ONE canonical domain and redirect the other with 301.**

For Next.js/Vercel (`next.config.js`):
```js
async redirects() {
  return [{ source: '/:path*', has: [{ type: 'host', value: 'www.[domain]' }], destination: 'https://[domain]/:path*', permanent: true }]
}
```

For nginx:
```nginx
server { server_name www.[domain]; return 301 https://[domain]$request_uri; }
```

### Sitemap Reminder

If the framework does not auto-generate a sitemap:
- Next.js: use `next-sitemap` package or app router `sitemap.ts`
- Static: generate `sitemap.xml` manually listing all public URLs
- Submit to Google Search Console AND Bing Webmaster Tools after deploy

### Server Headers Note

Configure `Last-Modified` header for content freshness:
- Vercel: automatic for static assets; for SSR, set `res.setHeader('Last-Modified', new Date().toUTCString())`
- nginx: `add_header Last-Modified $date_gmt;`

### Content Link Minimums

- [ ] At least **1 external link** to authoritative source (BLOCKER — 0 external links is a Rank Math failure)
- [ ] At least **8 internal links** for landing pages
- [ ] Run broken link scan post-deploy: `npx broken-link-checker https://[domain] --ordered --recursive`

---

## Validation Score

Conversion: X/6
SEO: X/4
GEO: X/4
Copy: X/4
Total: X/18

Issues found:
- [List any failures]
```
