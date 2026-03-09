# Ghostwriter Post-Audit Hardening — COMPLETATO 2026-03-09

## What
Strengthen Ghostwriter skill enforcement so that technical SEO items are delivered as code, not just listed as checkboxes. Based on Rank Math audit (68/100) showing 5 failures all covered by existing rules that weren't enforced.

## Root Cause Analysis

The Rank Math report for polyglot.you showed:

| Failure | Ghostwriter Rule | Status |
|---------|-----------------|--------|
| WWW Canonicalization missing | TECH-008 | Rule exists, not enforced |
| OpenGraph tags incomplete | TECH-005 | Rule exists, not enforced |
| No XML Sitemap | TECH-006 | Rule exists, not enforced |
| Broken links | TECH-003 | Rule exists, too narrow (internal only) |
| No content freshness signals | GEO-014 | Partial — misses og:updated_time, Last-Modified |
| Title brand duplication ("Polyglot You | Polyglot You") | SEO-001 | Rule mentions it but not strict enough |
| 0 external links | SEO-011 | Rule exists, not enforced |
| Response time >0.8s | — | Out of scope (server config) |

**Pattern:** Rules exist but the generation workflow outputs them as a "checklist for later" instead of generating the actual code/config.

## Changes

### 1. `validation/rules.md` — New + strengthened rules

**New rules:**
- **TECH-010: Content Freshness Meta** — Page must include `og:updated_time` or `article:modified_time` meta tag. Deliverable must include HTTP `Last-Modified` header guidance.
- **TECH-011: External Link Scan** — All links in generated content must be verified reachable (no placeholder URLs, no known-dead domains). Guidance to user to scan post-deploy.

**Strengthen existing:**
- **SEO-001**: Add explicit brand duplication gate — if brand appears 2+ times in title, auto-fail
- **TECH-005**: Add "MUST generate complete OG tag block as HTML code in deliverable, not just mention in checklist"
- **TECH-003**: Expand from "internal links" to "all links" — no placeholder or dead URLs

### 2. `generation/landing-page.md` — Make tech infra a code deliverable

Replace the "Technical Infrastructure Checklist" (checkboxes) with a **"Technical Infrastructure Code"** section that generates:
- Complete `<head>` meta block with OG, Twitter Card, canonical, freshness meta
- robots.txt template
- Sitemap entry example
- WWW canonicalization config snippet (Vercel/Next.js/nginx)
- External link reminder with minimum count

### 3. `SKILL.md` — Add "Delivery Gate" concept

Add a new section "Delivery Gate" under Operational Framework:
- Before delivering ANY generated content, verify all TECH-* rules pass
- If any TECH rule fails, the deliverable MUST include the fix as generated code
- Mark items as BLOCKER (delivery halted) vs WARNING (noted but deliverable)

### 4. `workflows/interactive.md` — Add Phase 4.5: Technical Infrastructure Gate

Between Validation and Delivery, add a mandatory gate:
1. Check: Are all 6 OG tags present as code? → If not, generate them
2. Check: Is sitemap guidance included? → If not, add it
3. Check: Is robots.txt guidance included? → If not, add it
4. Check: Is WWW canonicalization addressed? → If not, add stack-specific snippet
5. Check: Content freshness meta present? → If not, add it
6. Check: ≥1 external link for landing, ≥2 for articles? → If not, flag as BLOCKER

### 5. `references/seo-rules.md` — Add content freshness + external links

- Add content freshness to Indexability Checklist
- Add external link minimum to Crawlability Checklist

## Files to touch

1. `.claude/skills/ghostwriter/validation/rules.md`
2. `.claude/skills/ghostwriter/generation/landing-page.md`
3. `.claude/skills/ghostwriter/SKILL.md`
4. `.claude/skills/ghostwriter/workflows/interactive.md`
5. `.claude/skills/ghostwriter/references/seo-rules.md`

## How to verify

After changes, mentally run the landing page generation flow and confirm that every Rank Math failure from the report would be caught and fixed before delivery.
