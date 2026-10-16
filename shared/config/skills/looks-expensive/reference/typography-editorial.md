# Editorial Long-Form Apparatus

The grammar that makes a page read as a real publication instead of a marketing landing page. This file is **OFF by default.** It is gated hard — see the gate below. If you load this on a SaaS site, an agency site, or any page that is selling rather than reading, you have created a new AI tell. Don't.

## The Gate (read FIRST — most pages fail it)

This apparatus is permitted ONLY when ALL of these are true:

1. **Serif was already earned in Phase 3.** This file does not grant new permission to go serif. If the SKILL.md Phase 3 serif gate said all-sans, stop here — none of this applies.
2. **The product itself is editorial.** A publication, an essay site, a personal/thought-leader writing site, a documentation or long-read product, a press/book imprint. NOT a marketing landing page. NOT a SaaS site that happens to have a blog. NOT an agency site with a "journal." A blog attached to a product is not an editorial product.
3. **The page is a genuine long-form article**, not a section on a homepage.

If any one of the three is false, do not use the masthead, the drop cap, or the pull quotes. The display-serif roster (section A) is the only part that may apply to an earned-serif page that isn't a full article — and only as a pairing upgrade, not a new permission.

When the gate passes, the page is one of the rare cases where text measure (65-75ch, already covered in SKILL.md "Layout" — do not re-document) and reading rhythm are the whole design.

---

## A. Premium display-serif roster (the part you'll use most)

The SKILL.md serif list (Fraunces, Cormorant, Playfair Display, Lora, Libre Baskerville, Spectral) is all web-safe Google serifs. They are fine. But the sites that read as *expensive editorial* pair an agency-grade display serif for headlines with a grotesque body. **When serif is already earned per Phase 3, reach for these instead.**

| Display serif (H1/H2, deck) | Grotesque body | Reads as | Verified on |
|---|---|---|---|
| **Tiempos Headline** (Klim) | **Söhne** / **Untitled Sans** | Newsroom, serious journalism | Pitchfork, Neuralink, Enterprise Tech 30 |
| **Canela** (Commercial Type) | **Untitled Sans** / Söhne | Glossy culture magazine, art/fashion editorial | — |
| **GT Sectra** (Grilli Type) | **GT America** / Söhne | Calligraphic, literary, long essay | — |

Notes:
- These are **licensed** faces. If the project can't license, the closest web-safe substitutes are: Tiempos Headline → Fraunces (opsz high) or Spectral; Canela → Playfair Display; GT Sectra → Lora. Document the substitution in DESIGN.md.
- Still **ONE display family + ONE body family.** This is not permission to mix three. The pairing is serif-display + grotesque-body — exactly the structure SKILL.md already allows for earned-serif briefs.
- Body stays grotesque/sans. **No serif body** unless Phase 3 explicitly granted serif-body (rare, literary brands only). Serif headline + sans body is the premium default; serif everything reads as legacy magazine.
- Frame in DESIGN.md as: *"Serif earned in Phase 3; using [face] / [body] as the premium editorial pairing."* Not as a fresh decision to go serif.

```css
:root {
  --font-display: "Tiempos Headline", Fraunces, Georgia, serif;
  --font-body: "Söhne", "Untitled Sans", system-ui, sans-serif;
}
.article h1, .article h2, .deck { font-family: var(--font-display); }
.article p, .article li, .byline, .figure__caption { font-family: var(--font-body); }
```

---

## B. The masthead stack (article header)

This is the documented pattern that belongs inside the **Editorial Two-Column** layout (section-layouts.md #8). Do NOT create new reference files for it — it lives here and is referenced from there.

The newsroom masthead anatomy, top to bottom:

1. **Kicker** — a flat, uppercase, letter-spaced text label (e.g. `INTERVIEW`, `LONGREAD`, `FIELD NOTES`). This is a category label, NOT a marketing eyebrow pill.
2. **Headline** — oversized, display serif, the biggest type on the page.
3. **Deck / standfirst** — a larger-than-body summary sentence, 1-2 lines, that sits between headline and byline. Set in body family at ~1.4-1.6× body size, secondary ink.
4. **Byline + dateline + read-time** — small, body family, tertiary ink, separated by middots.

```html
<header class="masthead">
  <p class="masthead__kicker">Interview</p>
  <h1 class="masthead__headline">The quiet engineering behind a calm interface</h1>
  <p class="masthead__deck">A decade after shipping their first editor, the team explains why they keep deleting features faster than they add them.</p>
  <p class="masthead__meta">
    <span class="masthead__author">Jordan Ellison</span>
    <span aria-hidden="true">·</span>
    <time datetime="2026-05-18">May 18, 2026</time>
    <span aria-hidden="true">·</span>
    <span>9 min read</span>
  </p>
</header>
```

```css
.masthead { max-width: 60ch; margin: 0 auto; }
.masthead__kicker {
  font-family: var(--font-body);
  text-transform: uppercase;
  letter-spacing: 0.14em;
  font-size: 0.8125rem;
  font-weight: 600;
  /* Contrast: 0.8125rem ≈ 13px, weight 600 — BELOW the WCAG large-text threshold (≥18px regular OR ≥14px bold), so 4.5:1 applies.
     `color: var(--accent)` ONLY passes 4.5:1 if your --accent is at L ≤ 0.55 against your paper at L=0.97-0.99.
     If your --accent is L=0.60-0.70 (vibrant), USE `color: var(--text-2)` instead — the kicker is carried by tracking + weight + size, not by accent color.
     See SKILL.md Color System step 5 + LABEL CONTRAST rule. */
  color: var(--text-2);
  margin: 0 0 1.25rem;
  /* NO background. NO border. NO border-radius. NO padding box. */
}
.masthead__headline {
  font-family: var(--font-display);
  font-size: clamp(2.5rem, 6vw, 4.5rem);
  line-height: 1.05;
  letter-spacing: -0.02em;
  font-weight: 600;
  margin: 0 0 1.5rem;
}
.masthead__deck {
  font-family: var(--font-body);
  font-size: clamp(1.25rem, 2.2vw, 1.5rem);
  line-height: 1.45;
  color: var(--text-2);
  margin: 0 0 2rem;
  /* weight/size/color carry the standfirst — NOT italics. */
}
.masthead__meta {
  font-family: var(--font-body);
  font-size: 0.9375rem;
  color: var(--text-3);
  display: flex; flex-wrap: wrap; gap: 0.5rem; align-items: baseline;
}
```

### Kicker rules (this is where it goes wrong)

- The kicker is **a flat label.** No background, no border, no `border-radius`, no padding box. The moment it has any pill chrome, it IS the banned eyebrow pill (SKILL.md "EYEBROW CHECK", anti-patterns.md #21-ish eyebrow tell) — instant AI signature.
- **The kicker counts against the page eyebrow budget.** SKILL.md allows max 1 eyebrow/label per page, ideally zero. On an article, spend that one on the kicker. You do not also get a marketing eyebrow somewhere else on the page.
- One kicker per article. Not one per section.

---

## C. Long-form micro-typography

Inside the article body (the ~60-72ch measure column), the apparatus that makes prose read like a magazine.

### C1. Drop cap — optional, at most ONE per article

Use `initial-letter` on the first paragraph only. Never on marketing pages. Treat it as an optional flourish, not a requirement — a clean serif headline plus good measure is already premium without it.

```css
.article > p:first-of-type::first-letter {
  -webkit-initial-letter: 3;
  initial-letter: 3;            /* spans 3 lines */
  font-family: var(--font-display);
  font-weight: 600;
  margin-right: 0.5rem;
  color: var(--text);
}
```

Rules: one drop cap per article, on the opening paragraph only. Do not drop-cap every section. `initial-letter` only — do not fake it with a giant floated `<span>` and manual margins (it never aligns to the baseline grid).

### C2. Pull quotes — genuine display weight, breaking the measure

A pull quote earns its place by being *bigger than the body and physically wider than the text column* — it interrupts the reading measure. A quote at body size in a bordered box is not a pull quote, it's a card (and cards are budgeted — see non-card-patterns.md).

```html
<figure class="pullquote">
  <blockquote>We shipped the feature, watched nobody use it, and spent the next quarter taking it back out.</blockquote>
  <figcaption class="pullquote__attr">Priya Okonkwo, Head of Product</figcaption>
</figure>
```

```css
.pullquote {
  margin: 3rem -8vw;            /* break out wider than the 60-72ch measure */
  max-width: none;
  text-align: center;
}
.pullquote blockquote {
  font-family: var(--font-display);
  font-size: clamp(1.75rem, 4vw, 2.75rem);
  line-height: 1.15;
  letter-spacing: -0.015em;
  font-weight: 600;
  margin: 0;
}
.pullquote__attr {
  font-family: var(--font-body);
  font-size: 0.9375rem;
  font-weight: 500;            /* weight + color carry attribution — NOT italics */
  color: var(--text-3);
  margin-top: 1rem;
}
```

Rules: pull quotes only when the product is editorial AND the article is genuinely long-form. Never on a landing page. The quoted text must already appear in the body — a pull quote re-surfaces a line, it doesn't introduce new copy.

### C3. Footnotes / reference markers

Numbered superscript markers in the body linking to a reference list at the article foot. Use real anchors and `aria-describedby` for accessibility.

```html
<p>The editor's render loop was rebuilt twice<a href="#fn1" id="ref1" class="fnref" aria-describedby="fn1">1</a>.</p>
...
<ol class="footnotes">
  <li id="fn1">Internal benchmark, Q3 2025. <a href="#ref1" aria-label="Back to reference">↩</a></li>
</ol>
```

```css
.fnref {
  font-family: var(--font-body);
  font-size: 0.7em;
  vertical-align: super;
  line-height: 0;
  color: var(--accent);
  text-decoration: none;
  padding: 0 0.15em;
}
.footnotes {
  margin-top: 4rem; padding-top: 1.5rem;
  border-top: 1px solid var(--hairline);
  font-size: 0.9375rem; color: var(--text-2);
  counter-reset: none;          /* uses native <ol> numbering, no zero-padding */
}
```

Use 1, 2, 3 — never 01, 02, 03 (SKILL.md zero-pad rule).

### C4. Figure + caption + credit

Images in long-form get a caption and a source/credit line. **Both are set with weight, size, and color — NOT italics.** SKILL.md bans italics outright (`<em>`, `<i>`, `.italic`, `font-style: italic`) and the ITALIC CHECK greps for them. The traditional magazine "italic credit line" is therefore **replaced** here by an uppercase, letter-spaced, tertiary-ink credit. Do not smuggle italics back in.

```html
<figure class="figure figure--bleed">
  <img src="https://images.unsplash.com/photo-..." alt="The studio's workspace at dusk, monitors glowing" width="1600" height="900">
  <figcaption class="figure__caption">
    The render team's shared workspace, photographed during a Friday ship review.
    <span class="figure__credit">Photograph — Maya Okafor</span>
  </figcaption>
</figure>
```

```css
.figure { margin: 3rem 0; }
.figure--bleed {                /* full-bleed breakout from the measure */
  margin-left: calc(50% - 50vw);
  margin-right: calc(50% - 50vw);
  width: 100vw;
}
.figure--bleed img { width: 100%; height: auto; display: block; }
.figure__caption {
  font-family: var(--font-body);
  font-size: 0.9375rem;
  line-height: 1.5;
  color: var(--text-2);
  max-width: 60ch;
  margin: 0.75rem auto 0;
  padding: 0 1.5rem;
}
.figure__credit {
  display: inline-block;
  margin-left: 0.5rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  font-size: 0.75rem;
  color: var(--text-3);
  /* uppercase + color instead of the banned italic credit line */
}
```

Full-bleed figures are the editorial payoff of a narrow measure: the text stays at 60-72ch, the imagery breaks the full viewport width. Use real `<img>` per reference/imagery.md.

---

## D. Reading aids

### D1. Scrollspy TOC (sticky aside)

Genuinely absent from the skill. In the Editorial Two-Column layout (#8), the 30-40% sidebar holds a sticky table of contents that highlights the section currently in view. Reads as a real long-form publication.

```html
<aside class="toc">
  <nav aria-label="Contents">
    <ol class="toc__list">
      <li><a href="#origin" class="toc__link">Origins</a></li>
      <li><a href="#loop" class="toc__link">Rebuilding the loop</a></li>
      <li><a href="#future" class="toc__link">What comes next</a></li>
    </ol>
  </nav>
</aside>
```

```css
.toc { position: sticky; top: 6rem; align-self: start; }
.toc__link {
  display: block;
  font-family: var(--font-body);
  font-size: 0.9375rem;
  color: var(--text-3);
  padding: 0.4rem 0 0.4rem 1rem;
  border-left: 2px solid transparent;
  text-decoration: none;
  transition: color 180ms cubic-bezier(0.4, 0, 0.2, 1),
              border-color 180ms cubic-bezier(0.4, 0, 0.2, 1);
}
.toc__link[aria-current="true"] {
  color: var(--text);
  border-left-color: var(--accent);
}
```

```js
// IntersectionObserver scrollspy — sets aria-current on the active section's link
const links = new Map([...document.querySelectorAll('.toc__link')]
  .map(a => [a.getAttribute('href').slice(1), a]));
const spy = new IntersectionObserver((entries) => {
  for (const e of entries) {
    if (e.isIntersecting) {
      links.forEach(a => a.removeAttribute('aria-current'));
      links.get(e.target.id)?.setAttribute('aria-current', 'true');
    }
  }
}, { rootMargin: '-30% 0px -60% 0px' });
document.querySelectorAll('.article [id]').forEach(s => spy.observe(s));
```

Hide the TOC below the two-column breakpoint (it collapses; the article reads single-column on mobile).

### D2. Article progress bar — already exists

Do NOT re-document. Use **animations.md #9 "Scroll Progress Bar"** (2-3px, accent at 60%, top of viewport). Scope it to the article element rather than whole-page if the page has a long header.

### D3. Read-time

Already in the masthead meta line (section B). Compute from word count at ~225 wpm; render as a static number (`9 min read`). Do not animate it.

---

## Hard guardrails (so this doesn't become a new tell)

- **OFF by default. OFF for any non-editorial brief.** Gated to the Phase 3 "serif earned" check plus the editorial-product test above. This is not a general capability.
- **No italics anywhere.** The standfirst/deck, figure captions, credit lines, and pull-quote attribution all use weight + size + color. The skill bans italics outright and greps for them — adding this file does not amend that ban. If you want the magazine italic-credit look, you can't have it; use the uppercase credit treatment in C4.
- **Kicker is a flat label and counts against the eyebrow budget.** Any pill/background/border/radius on it = the banned eyebrow pattern.
- **Drop cap: at most one per article, `initial-letter` only, never on marketing pages.** Optional.
- **Pull quotes: editorial product + genuinely long article only.** Never on landing pages. Must re-surface existing body copy.
- **Still one display family + one body family.** The roster is a pairing upgrade, not permission to mix three faces or to go serif where Phase 3 said sans.
- **Measure (65-75ch) is already covered in SKILL.md "Layout."** Reference it; do not re-specify.
- **Full-bleed figures and pull-quote breakouts** are the only license to exceed the measure. Body text stays in the column.