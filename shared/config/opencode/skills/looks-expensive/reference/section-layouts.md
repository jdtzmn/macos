# Section Layout Patterns

**This is a thinking-aid, not a menu.** Picking patterns 1, 3, 7, 9 by number for every project produces the same skeleton across briefs. Better practice: describe what each section needs to do (compare options? show a process? introduce a person? prove credibility?), then design the layout for that need. The 16 patterns below are reference for what's possible — they are NOT a checklist to populate.

The numbering is alphabetical-ish for findability, not a recommendation order. Don't reach for Pattern 1 just because it's first.

16 layout patterns + 9 non-card containment patterns (see reference/non-card-patterns.md). Use at least 4 DIFFERENT patterns per page. Never the same pattern twice in a row.

## Card-Grid Discipline

The default "3 cards in a row" / "4 cards in a 2x2 grid" is the most overused layout in AI-generated landing pages. Before you reach for a card grid, ask: is there a better pattern for this content?

**Try first:**
- Ledger (rows separated by hairlines) for catalogs, menus, plans, specs
- Definition list for feature explanations
- Editorial rule sections for philosophy, services, manifestos
- Table for pricing, comparison, plans
- Inline-stat narrative for stats

**Card grids are appropriate when:**
- Items are discrete objects in a true collection (products, team members, locations)
- Each card needs a real image or rich mockup
- Items genuinely have equal weight and parallel structure

**Card grids are wrong when:**
- The "cards" contain only text and an icon
- You're using cards because you couldn't think of another container
- Every section on the page is also cards

See reference/non-card-patterns.md for 9 specific alternatives to the card grid.

---

## 1. Bento Grid — DEFAULT TO ZERO
Mixed-size modular cards with DIFFERENT dimensions. See `reference/bento-grids.md` for exact CSS.

**Default: NO bento on the page.** Bento was the most overused layout in early iterations and reads as "I am an AI-generated landing page." Bento is only permitted when ONE feature is genuinely more important than the others AND the section needs embedded mockups that benefit from differential sizing. Justify in one sentence in DESIGN.md before using. Most pages should have ZERO bento. Maximum one ever.

- MUST have at least one card using `grid-column: span 2` AND `grid-row: span 2` (both, not just one)
- MUST have at least 2 different card sizes
- Large cards MUST contain real visuals (CSS mockup, chart, code block, embedded image) — not empty gradients or just text
- Gap: 16-24px
- Best for: a single feature-overview section where one feature is genuinely the primary
- **Anti-pattern: equal-column grid labeled `.bento-grid` — if no card spans, it's NOT a bento. Use a regular grid or a different pattern entirely.**
- **Anti-pattern: bento on every page. Bento is one tool in a kit, not the kit.**

## 2. Asymmetric Split (Large Left + Stacked Right)
One large element (55-65%) beside 2-3 stacked smaller elements (35-45%).
- Grid: `grid-cols-12` with `col-span-7` + `col-span-5`
- Best for: feature highlights, product demos, case studies
- Why it works: creates focal point with supporting detail

## 3. Zigzag Alternating
Image/text pairs alternating sides. Row 1: image left, text right. Row 2: reversed.
- Grid: 2-column, alternating `flex-direction: row-reverse`
- Gap: 48-80px between rows
- Best for: how it works, process, feature walkthroughs
- Why it works: creates reading rhythm, keeps engagement through direction changes

## 4. Full-Width Feature Spotlight
Single feature fills the entire section width. Large visual + supporting text.
- Grid: single column, content 70-90% viewport
- Best for: key feature announcements, hero products, before/after
- Why it works: commands attention through scale

## 5. Numbered Timeline (Vertical)
Steps connected by a vertical line with numbers.
- Grid: single column with left-aligned number rail
- Connecting line: 1px, accent or muted color
- Best for: process flows, getting started, onboarding
- Why it works: clear sequence, directional, scannable

## 6. Numbered Timeline (Horizontal)
Steps laid out horizontally with connecting line.
- Grid: equal-width columns (3-5) with line connecting them
- Best for: 3-5 step processes on desktop
- Collapses to vertical on mobile
- Why it works: fits naturally in the reading flow

## 7. Compact Stat Strip
Single horizontal row of 4-6 key metrics.
- Grid: flex or grid, equal columns, 16-24px gap
- Large number (28-40px) + small label below (12px)
- Subtle dividers between items
- Best for: social proof, achievements, key numbers
- Why it works: numbers grab attention, dense info in small space

## 8. Editorial Two-Column
Main content (60-70%) with sidebar or pull quotes (30-40%).
- Grid: `grid-cols-12` with `col-span-8` + `col-span-4`
- Best for: case studies, long-form features, testimonial highlights
- Why it works: magazine-like sophistication
- For article mastheads, long-form micro-typography, and the sticky scrollspy TOC that lives in the 30-40% column, see reference/typography-editorial.md (gated to editorial products only)

## 9. Card Grid (2x3 or 3x2)
Equal-sized cards in a clean grid. The standard, done well.
- Grid: `grid-cols-2 lg:grid-cols-3` with consistent gap
- Card: icon/illustration + title + one-line description
- Best for: features list, integrations, team members
- Important: only use if cards genuinely need equal weight. If one feature is more important, use bento or asymmetric instead.
- If cards share title+body+footer, align internal rows with subgrid — see reference/modern-css.md (Cross-Card Row Alignment); `grid-auto-rows: 1fr` equalizes whole-card height only, NOT internal rows.

## 10. Horizontal Scroll Strip
Cards overflow horizontally, inviting scroll/swipe.
- Container: `overflow-x: auto` with snap points
- Items: fixed width (280-320px), 16-24px gap
- Show 3.5 items on desktop (hint to scroll)
- Best for: testimonials, featured content, integrations
- For logos, use Pattern 16 (Logo Wall) — a horizontal scroll strip is the wrong container for social proof; proof should be instantly legible, not swiped through.
- Why it works: partial visibility hints at more content

## 11. Overlapping Card Stack
3-5 cards stacked with offset, creating depth.
- Cards: `translate(Y: -20px)` or `margin-top: -40px` per card
- Slight rotation: 2-5 degrees
- Hover: selected card rises (z-index), others fade
- Best for: testimonials, visual highlights, interactive showcases
- Why it works: 3D depth without 3D rendering

## 12. Tab Content Switcher
Horizontal tabs above, content swaps below.
- Tabs: equal or content-width, centered or left-aligned
- Active: bold underline or filled background
- Content: single pane that transitions on tab click
- Best for: pricing tiers, feature categories, use case breakdowns
- Why it works: dense information without long scroll

## 13. Comparison Table
Clean table with feature rows and plan columns.
- Grid: 3-4 columns (feature name + 2-3 plans)
- Checkmarks for included, dashes for excluded
- Recommended plan highlighted with `--accent-ink` background (if text is near-white) or a tinted `--accent` background at 8-12% opacity with regular ink text. NEVER base `--accent` at full saturation behind near-white text — fails WCAG AA. See SKILL.md Color System step 5 (ACCENT-FILL CONTRAST CHECK).
- Best for: pricing, competitive comparison, plan selection
- Why it works: enables direct comparison, aids decision-making

## 14. Full-Width Color Block Stripes
Full-bleed horizontal sections alternating background colors.
- Each section: 100vw background, content centered in max-width
- Alternates: light > dark > light > tinted > dark
- Padding: 80-120px vertical
- Best for: multi-section homepages, feature explanations
- Why it works: visual rhythm through background contrast
- For Vibrant / Bold-classified consumer brands, up to TWO saturated hues from the same brand family (not arbitrary multi-hue) may fill adjacent blocks, governed by an OKLCH chroma ceiling (C ≤ 0.20) and the existing AA contrast checks. No blocks-per-viewport framework, no maximalism vocabulary.

## 15. List with Side Illustration
Text list (60-70%) beside a fixed or scrolling illustration (30-40%).
- Grid: asymmetric two-column
- Illustration can pin on scroll while text moves — for the full pinned, step-synced treatment see reference/animations.md section 13 (Pinned-Figure Narration)
- Best for: feature lists, benefit breakdowns, workflow steps
- Why it works: visual interest without overwhelming the content

## Selection Guide

| Content Type | Best Patterns | Avoid |
|-------------|--------------|-------|
| 3 features | Bento, Asymmetric Split | Card Grid (too generic for 3) |
| 6 features | Bento, Card Grid (2x3) | Stat Strip (too compact for descriptions) |
| How it works (3-4 steps) | Numbered Timeline, Zigzag | Card Grid (loses sequence) |
| Stats/metrics | Stat Strip, Bento | Full-Width Spotlight (overkill) |
| Testimonials | Horizontal Scroll, Overlapping Stack | Card Grid (boring for quotes) |
| Pricing | Tab Switcher, Comparison Table | Bento (confusing for pricing) |
| Single key feature | Full-Width Spotlight | Card Grid (dilutes focus) |
| Process/workflow | Zigzag, Numbered Timeline | Stat Strip (can't show detail) |


## 16. Logo Wall (social proof) — optical sizing, no chrome

The near-universal "trusted by" band, and the AI default is a dead giveaway: every logo scaled to the same pixel height, each one boxed in its own bordered card, on a tinted strip, under an uppercase "TRUSTED BY" pill. Build it the opposite way.

This pattern supersedes the "logos" use of Pattern 10. A horizontal scroll strip is the wrong container for social proof — proof should be instantly legible, not something the user has to swipe through.

**The non-negotiables:**

- **Optical weight, not bounding box.** This is the whole craft. Do NOT force every logo to the same pixel height. A wide wordmark (e.g. a 6-letter logotype) and a square glyph at identical height will read as wildly different visual weights — the wordmark dominates, the square mark looks tiny. Instead, size each logo by aspect ratio so they read as *equal weight* inside one fixed-height row. Wide marks get a smaller max-height; square/tall marks get a larger one. (This is documented design discipline — search "optical adjustment logo" — not a stylistic opinion.)
- **One ink, theme-aware.** Render every logo monochrome at a single ink color via `currentColor` or a `filter`, so the wall stays coherent and works in BOTH light and dark sections. Do not hardcode an opacity that only looks right on one background.
- **No chrome.** No borders, no cards, no boxes, no per-logo background. Plain surface. Large gap (48-72px). The logos sit directly on the section like type.
- **A label or a stat above, never an eyebrow pill.** "Trusted by 340 engineering teams" or "Processing $2.1B annually" — a real sentence or number, not a "TRUSTED BY" pill (respect the max-1-eyebrow rule).
- **Real or realistic names only.** Actual company logos, or realistic typeset wordmarks. NEVER gray placeholder rectangles — those are the loudest tell in this pattern.

```html
<section class="logos">
  <p class="logos__label">Trusted by 340 engineering teams</p>
  <div class="logos__row">
    <!-- inline SVGs use fill="currentColor"; <img> logos use the filter below -->
    <svg class="logo logo--wide" viewBox="0 0 240 48" aria-label="Northwind">…</svg>
    <svg class="logo logo--square" viewBox="0 0 64 64" aria-label="Harbor">…</svg>
    <svg class="logo logo--wide" viewBox="0 0 200 40" aria-label="Cedar Freight">…</svg>
    <svg class="logo logo--tall" viewBox="0 0 80 72" aria-label="Atlas">…</svg>
  </div>
</section>
```

```css
.logos__row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;          /* optical centering on a shared baseline-ish line */
  justify-content: center;
  gap: 56px;
  height: 64px;                 /* ONE fixed-height row; logos size within it */
}
.logo {
  width: auto;
  color: var(--text);           /* inline SVGs inherit this via fill="currentColor" */
  opacity: 0.6;                 /* flat monochrome wall — see note: hover is OPTIONAL */
  transition: opacity 180ms cubic-bezier(0.2, 0, 0, 1);
}
/* OPTICAL sizing: per-aspect max-height so all marks read as equal weight */
.logo--wide   { max-height: 22px; }   /* long wordmarks sit smaller */
.logo--square { max-height: 36px; }   /* compact marks sit larger */
.logo--tall   { max-height: 40px; }
/* If using raster/<img> logos instead of currentColor inline SVG: */
.logo--img { filter: grayscale(1) brightness(0) invert(var(--logo-invert, 0)); }
```

**Optional hover reveal (not mandatory):** opacity 0.6 → 1 (or grayscale → color) on `:hover`, 150-200ms. A flat monochrome wall with NO hover is equally correct and often *more* premium — don't add the hover reflexively.

**Guardrails so it doesn't become a new tell:**
- The wall is ONE row/band on the page, not a pattern you repeat in three sections.
- The logo wall is borderless — it does NOT count against the 2-card containment budget.
- Hover color-reveal is optional. Flat is fine. Pick deliberately.

**Marquee — default to OFF.** An auto-scrolling logo strip is itself becoming a template reflex. Default to a static wall. IF a marquee is genuinely warranted (20+ logos that won't fit), it must be: a slow single loop (~30-40s), monochrome, pause-on-hover, with an edge `mask-image` fade on both sides, and FROZEN under `prefers-reduced-motion` (animation paused or replaced with a static wrap). A fast or looping-twice marquee is worse than no marquee.

Exemplar: Vercel's customers page — borderless logos on a plain background under a one-line heading, no cards or frames, theme-adaptive single-color marks. That's the target.

**Regulated categories (banking/fintech, health, legal, insurance):** a generic logo wall is the wrong proof. Surface 1-2 real credentials as a designed element near the hero instead — a member-bank/FDIC/FSCS lockup, a deposit/switch guarantee, board-certification + institutional pedigree — rendered as a typographic lockup or via the inline-stat narrative (reference/non-card-patterns.md Pattern 5/6) for credibility metrics ("$2T+ volume", "99.999% uptime"). Max 2-3 trust elements; a 4+ badge row is badge-soup. See the "Regulated-category trust signals" subsection in reference/ux-writing.md for the full rules and guardrails.