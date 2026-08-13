# Non-Card Patterns

A landing page where every section is "icon + heading + 2-line description in a rounded-rectangle card with a 1px border" reads as AI slop. Real agency builds vary the containment. This file is the alternatives.

## The Card Rule

Maximum TWO sections per page may use the default card pattern (rounded rectangle, 1px border, padding, optional icon). All other sections use one of the patterns below.

The default card pattern is:
```css
.card {
    background: var(--surface);
    border: 1px solid rgba(0,0,0,0.06);
    border-radius: 16px;
    padding: 32px;
}
```

If you find yourself wrapping every section's contents in this, stop. Pick a different containment per section. The variance IS the design.

## 9 Patterns That Aren't Cards

### Pattern 1: Ledger

Rows separated by hairline rules. No card chrome. Each row is a row-as-information — name, value, sometimes a small note. Reads like a balance sheet, a menu, a receipt, a registry.

```html
<dl class="ledger">
    <div class="ledger__row">
        <dt class="ledger__term">Single-origin Koroneiki</dt>
        <dd class="ledger__value">Crete · 2024 harvest · 500ml</dd>
        <dd class="ledger__price">$68</dd>
    </div>
    <div class="ledger__row">
        <dt class="ledger__term">Single-origin Arbequina</dt>
        <dd class="ledger__value">Catalonia · 2024 harvest · 500ml</dd>
        <dd class="ledger__price">$64</dd>
    </div>
</dl>
```

```css
.ledger { display: grid; }
.ledger__row {
    display: grid;
    grid-template-columns: 2fr 3fr auto;
    gap: 32px;
    padding: 20px 0;
    border-bottom: 1px solid rgba(0,0,0,0.08);
    align-items: baseline;
}
.ledger__row:first-child { border-top: 1px solid rgba(0,0,0,0.08); }
.ledger__term { font-weight: 500; }
.ledger__value { color: var(--text-secondary); }
.ledger__price { font-variant-numeric: tabular-nums; font-weight: 500; }
```

Use for: product catalogs, menu items, specs, pricing line items, team rosters.

### Pattern 2: Definition list (term + description)

The web's oldest semantic element, almost never used. Two columns: term on the left (often colored or accented), description on the right. No borders, no boxes, just typography and spacing.

```html
<dl class="defs">
    <dt>Sliding window</dt>
    <dd>Tracks requests over a rolling time period. Best for smooth rate limits without artificial cliffs.</dd>

    <dt>Fixed window</dt>
    <dd>Resets the count at fixed intervals. Simpler, slightly less smooth at the boundary.</dd>

    <dt>Token bucket</dt>
    <dd>Allows bursts up to a cap, refills at a steady rate. Best for spiky traffic.</dd>
</dl>
```

```css
.defs {
    display: grid;
    grid-template-columns: 1fr 2fr;
    gap: 16px 48px;
}
.defs dt {
    font-weight: 500;
    color: var(--accent);
}
.defs dd {
    color: var(--text-secondary);
    line-height: 1.55;
}
```

Use for: feature explanations where each feature has a real definition, glossary-style sections, "what we mean by X" sections.

### Pattern 3: Editorial rule sections

Sections separated by a horizontal rule. Just typography. No containers. Reads like a long-form essay. Each section is a heading + paragraph + maybe a small detail beneath, with breathing room.

```html
<section class="prose">
    <h2 class="prose__heading">What we do</h2>
    <p class="prose__lead">We make products look as good online as they do on shelves. That's brand identity, packaging design, and Shopify builds — for DTC brands that have outgrown what they could build alone.</p>
    <hr class="prose__rule">

    <h2 class="prose__heading">How an engagement runs</h2>
    <p class="prose__lead">Twelve to sixteen weeks. One project at a time. We start with a positioning conversation, end with a launched site. Everything in between is iteration.</p>
    <hr class="prose__rule">

    <h2 class="prose__heading">Who this works for</h2>
    <p class="prose__lead">Brands doing five hundred thousand to ten million in revenue, with a product that works and a brand that doesn't yet match it.</p>
</section>
```

```css
.prose {
    max-width: 720px;
    margin: 0 auto;
}
.prose__heading {
    font-size: clamp(28px, 4vw, 40px);
    font-weight: 500;
    letter-spacing: -0.02em;
    margin: 0 0 16px;
}
.prose__lead {
    font-size: clamp(18px, 1.6vw, 22px);
    line-height: 1.55;
    color: var(--text-secondary);
    margin: 0 0 64px;
}
.prose__rule {
    border: 0;
    border-top: 1px solid rgba(0,0,0,0.12);
    margin: 0 0 64px;
    max-width: 64px;
}
```

Use for: agency about pages, services without dashboards, founder-led personal brands, manifestos, philosophy sections.

### Pattern 4: Side-by-side comparison (without cards)

Two columns separated by a vertical rule or generous space. No card chrome. Each side is a heading + a short list of differences. Reads like a Choose Your Own Adventure.

```html
<section class="versus">
    <div class="versus__side versus__side--neg">
        <h3 class="versus__heading">The old way</h3>
        <p>Hire a broker. Get three quotes a year apart. Lock everyone into the same plan. Lose the good employees who wanted choice.</p>
    </div>
    <div class="versus__side versus__side--pos">
        <h3 class="versus__heading">The Canopy way</h3>
        <p>Set a budget. Let everyone pick the plan they want. Stay out of insurance literacy. Keep the people you want to keep.</p>
    </div>
</section>
```

```css
.versus {
    display: grid;
    grid-template-columns: 1fr 1px 1fr;
    gap: 64px;
    align-items: start;
}
.versus__side--neg { opacity: 0.55; }
.versus::before {
    /* Use a pseudo-element or a styled divider */
    content: "";
    background: rgba(0,0,0,0.12);
    align-self: stretch;
    grid-column: 2;
}
```

Use for: problem/solution sections, before/after, us-vs-them. Way better than two cards side by side.

### Pattern 5: Inline-stat narrative

Stats embedded in prose, not in a 4-column counter strip. The stat IS the sentence.

```html
<section class="stat-narrative">
    <p class="stat-narrative__lead">
        Last year, <strong class="stat">2.8 billion</strong> requests passed through Arcjet's rate limiters.
        We blocked <strong class="stat">93 million</strong> bots, validated <strong class="stat">12 million</strong> email signups,
        and shipped one quiet attack-detection feature that none of our customers ever noticed —
        because nothing reached them.
    </p>
</section>
```

```css
.stat-narrative__lead {
    font-size: clamp(24px, 3vw, 36px);
    line-height: 1.45;
    max-width: 880px;
    margin: 0 auto;
    text-align: center;
    color: var(--text-secondary);
}
.stat-narrative__lead .stat {
    color: var(--text);
    font-weight: 500;
    font-variant-numeric: tabular-nums;
}
```

Use for: any "stats" section. Way better than a 4-column counter strip that screams "I am a SaaS landing page."

### Pattern 6: Single hero stat

One number, huge, with context beneath it. Replaces the 4-column counter strip with a single moment that lands.

```html
<section class="single-stat">
    <p class="single-stat__number">31%</p>
    <p class="single-stat__context">
        of cloud spend at the average company is wasted on idle resources, oversized instances,
        and forgotten dev environments. We find it and turn it off.
    </p>
</section>
```

```css
.single-stat__number {
    font-size: clamp(96px, 14vw, 180px);
    font-weight: 500;
    letter-spacing: -0.04em;
    line-height: 1;
    color: var(--accent);
    margin: 0 0 24px;
    font-variant-numeric: tabular-nums;
}
.single-stat__context {
    font-size: clamp(18px, 1.6vw, 22px);
    line-height: 1.55;
    max-width: 600px;
    color: var(--text-secondary);
}
```

Use for: pages with one anchor stat that frames everything. Way more impact than four 24px numbers with labels.

### Pattern 7: Table

Real HTML tables. Not divs styled to look like tables. Used for pricing, comparison, specs, plan tiers.

```html
<table class="spec-table">
    <thead>
        <tr>
            <th></th>
            <th>Free</th>
            <th>Pro</th>
            <th>Enterprise</th>
        </tr>
    </thead>
    <tbody>
        <tr><th scope="row">Requests / month</th><td>10K</td><td>1M</td><td>Custom</td></tr>
        <tr><th scope="row">Bot detection</th><td>—</td><td>✓</td><td>✓</td></tr>
        <tr><th scope="row">Shield</th><td>—</td><td>✓</td><td>✓</td></tr>
        <tr><th scope="row">SLA</th><td>—</td><td>99.9%</td><td>99.99%</td></tr>
    </tbody>
</table>
```

```css
.spec-table {
    width: 100%;
    border-collapse: collapse;
    font-variant-numeric: tabular-nums;
}
.spec-table th, .spec-table td {
    padding: 16px 20px;
    text-align: left;
    border-bottom: 1px solid rgba(0,0,0,0.08);
}
.spec-table th[scope="row"] {
    color: var(--text-secondary);
    font-weight: 400;
}
.spec-table thead th {
    font-weight: 500;
    padding-bottom: 12px;
    border-bottom: 1px solid rgba(0,0,0,0.16);
}
```

Use for: pricing where a 3-tier card layout would be the default. A clean table reads as confident and direct.

### Pattern 8: Inline pricing

Don't always build a pricing section as three cards in a row. Sometimes pricing is one line of confident copy.

```html
<section class="pricing-inline">
    <h2>Pricing</h2>
    <p class="pricing-inline__line">
        <span class="pricing-inline__amount">$42,000</span>
        for a six-month engagement. Twelve sessions, unlimited async between them, one in-person day per quarter.
    </p>
    <p class="pricing-inline__note">We take four new clients per year. The 2026 cohort opens in September.</p>
</section>
```

```css
.pricing-inline__line {
    font-size: clamp(22px, 2.4vw, 28px);
    line-height: 1.45;
    max-width: 720px;
    margin: 0 0 24px;
}
.pricing-inline__amount {
    font-weight: 500;
    font-variant-numeric: tabular-nums;
}
```

Use for: services, coaching, one-product brands, anything where a 3-tier table would feel like marketing fluff.

### Pattern 9: Index/Contents

A numbered or unnumbered list of what the page contains, styled like a table of contents. Works as both navigation and as content scaffolding. Anchors to sections below.

```html
<nav class="index">
    <ol class="index__list">
        <li class="index__item">
            <a href="#what">
                <span class="index__num">1</span>
                <span class="index__title">What we build</span>
            </a>
        </li>
        <li class="index__item">
            <a href="#how">
                <span class="index__num">2</span>
                <span class="index__title">How we work</span>
            </a>
        </li>
        <li class="index__item">
            <a href="#cost">
                <span class="index__num">3</span>
                <span class="index__title">What it costs</span>
            </a>
        </li>
    </ol>
</nav>
```

Use for: agency sites, long-form pages, structured services. Reads as editorial, not as a SaaS landing page.

For a long-form page, this index doubles as a sticky scroll-spy "on this page" TOC: give each target section `scroll-margin-top` equal to the sticky header height, and drive the active-link state with an IntersectionObserver (no scroll-jacking). See reference/navigation.md for the engineered-header + drawer spec it pairs with.

## Section Containment Variance Rule

For a 7-section page, your section containment should include at LEAST 3 different patterns from this list (or combine with the section-layouts.md list). For example:

- Section 1 (hero): photo + text overlay
- Section 2 (overview): editorial rule (Pattern 3)
- Section 3 (products): ledger (Pattern 1)
- Section 4 (philosophy): inline-stat narrative (Pattern 5)
- Section 5 (process): can be cards (one of the two allowed)
- Section 6 (pricing): table or inline pricing (Pattern 7 or 8)
- Section 7 (CTA): typography-led, no card

If your page has cards in 5+ sections, redesign.

## When Cards Are Earned

Cards work when:
- The card contains a rich CSS mockup that genuinely benefits from a contained frame
- The card represents a discrete object (a product, a plan, a person) that lives in a collection
- The card has a real image that needs a frame

Cards do NOT work when:
- The card contains just text — that's a paragraph, not a card
- Every section in the page is cards
- The card has a thin colored top stroke "for visual interest" (this is a tell)
- The card has a single-line subtitle in a pill above its heading (also a tell)


## Footer Architecture

A footer is a containment problem, so it lives here, not in a footer catalog. The old rule was "strip decorative footers," which the model read as "ship a 3-link strip or omit the footer." On a multi-area product that strip IS the cheap tell. A footer should be exactly as substantial as the site's information architecture warrants — no more, no less.

### The binding rule: footer type follows category

Decide footer type from category BEFORE choosing components. Do not start from "what does a footer look like" — start from "how much real IA does this site have."

- **Multi-area SaaS / fintech / devtools** (real product surface, docs, pricing, resources) → **fat sitemap**: 3-8 link groups, hairline separators NOT cards, tight type scale, muted-to-full-ink hover. Add a utility strip (status / theme toggle / region) ONLY for the utilities the product actually has. Exemplars verified live: Vercel (8 groups + live status indicator + system/light/dark toggle), Linear (6 groups + dedicated bottom legal row), Stripe (8 groups, hairline separators, region/language selector "United States (English)").
- **Agency / luxury / editorial** (thin IA, the brand IS the content) → **typographic or office-segmented footer, NO sitemap columns**. Oversized words-as-nav, or contact segmented by office. Exemplar: Pentagram (London / NY / Austin / Berlin new-business inquiries, not a SaaS grid).
- **Single-page / brochure / thin IA** → **minimal utility footer**: wordmark + 3-5 real links + legal. NEVER fabricate a fake 8-column grid to look substantial. A 5-section site does not have 40 destinations; pretending it does is the tell.

If you cannot name the real IA behind each column, you do not have a fat-sitemap footer — you have a thin site, so build the minimal footer instead.

### Canonical sitemap footer (hairlines, not cards)

One snippet, not six. Every group names a real area of the product. No card chrome, no nested boxes — defer to the card-section cap above.

```html
<footer class="site-footer">
  <nav class="footer-grid" aria-label="Footer">
    <div class="footer-col">
      <h2 class="footer-col__head">Product</h2>
      <ul>
        <li><a href="/features">Features</a></li>
        <li><a href="/changelog">Changelog</a></li>
        <li><a href="/pricing">Pricing</a></li>
      </ul>
    </div>
    <!-- 2-7 more columns, each a REAL IA area -->
  </nav>
  <div class="footer-utility">
    <a class="footer-status" href="/status"><span class="dot" aria-hidden="true"></span> All systems operational</a>
    <button class="theme-toggle" aria-label="Theme">System</button>
    <span class="footer-region">United States (English)</span>
  </div>
  <div class="footer-base">
    <span class="footer-wordmark">Acme</span>
    <p class="footer-legal"><a href="/privacy">Privacy</a> · <a href="/terms">Terms</a> · © 2026 Acme, Inc.</p>
  </div>
</footer>
```

```css
.site-footer { padding: 80px 0 32px; }
.footer-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 40px 48px;
  padding-bottom: 40px;
  border-bottom: 1px solid rgba(0,0,0,0.08); /* hairline, not a card edge */
}
.footer-col__head { font-size: 13px; font-weight: 500; margin: 0 0 16px; }
.footer-col ul { list-style: none; margin: 0; padding: 0; display: grid; gap: 10px; }
.footer-col a {
  font-size: 14px;
  color: var(--text-secondary);   /* muted at rest */
  text-decoration: none;
  transition: color .15s ease;
}
.footer-col a:hover { color: var(--text); }   /* muted -> full ink */
.footer-col a:focus-visible { outline: 2px solid var(--accent); outline-offset: 3px; border-radius: 2px; }
.footer-utility {
  display: flex; flex-wrap: wrap; gap: 24px; align-items: center;
  padding: 24px 0; border-bottom: 1px solid rgba(0,0,0,0.08);
}
.footer-status .dot { width: 8px; height: 8px; border-radius: 50%; background: #16a34a; display: inline-block; }
.footer-base { display: flex; justify-content: space-between; align-items: baseline; padding-top: 24px; gap: 24px; }
```

The link-list `<li>`s are navigation and do NOT count against the page bullet budget (same exemption as nav). Tabular type scale (13px heads, 14px links) reads as a confident sitemap, not a marketing block.

### Oversized cropped wordmark — OPT-IN, with an anti-tell guard

The full-width (~100vw) wordmark cropped from below — grounding the page like a masthead, resolving the page into one final chord — is a real, documented pattern (the Wix Studio "big footers" trend). That is exactly the risk: it is a *current trend*, so overuse makes it a new-AI tell.

Use it ONLY when the brand mark can carry it AND the page genuinely resolves into it. Never on a thin one-pager. Never as the default.

```css
.footer-wordmark--oversized {
  font-size: clamp(96px, 28vw, 420px);
  font-weight: 600;
  letter-spacing: -0.04em;
  line-height: 0.82;
  margin: 0;
  overflow: clip;                                  /* crop, don't scroll */
  -webkit-mask-image: linear-gradient(to bottom, #000 55%, transparent);  /* luminance fade into the page edge */
          mask-image: linear-gradient(to bottom, #000 55%, transparent);
}
```

No italics. The mark must stay on-brand — this is the wordmark, not a decorative slogan.

### Hard guardrails (baked in, not optional)

- **Label specificity.** Columns name real IA. Ban a vague "Resources" / "Misc" as the sole catch-all bin for links you couldn't categorize. If a column would only hold orphans, you have fewer groups than you think — merge.
- **No fabricated groups to fill a grid.** Empty or padded columns are the "earn your pixel" violation in footer form. A real 4-group footer beats a fake 8-group one.
- **WCAG AA on every link:** 4.5:1 contrast at rest (muted ≠ invisible), 44px touch target, visible `:focus-visible` ring. The muted-to-ink hover must never drop below AA at rest.
- **No card chrome, no nested boxes.** Hairlines separate the regions. The footer does not consume your 2-card-section budget.
- **Skip the footer entirely in logged-in dashboards / app shells.** A marketing sitemap inside a product UI is noise.
- **Utilities must be real.** Only show a status indicator if there's a status page; only a region selector if the product is localized; only a theme toggle if the site themes. A fake "All systems operational" pill on a brochure site is a tell.