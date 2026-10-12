# Modern CSS — Two Defect Fixes

This is NOT a modern-CSS showcase file. It holds exactly two snippets that fix two specific, visible defects. Paste each block into the file named in its header. Do not add new CSS features beyond these two. **Use these only to fix an alignment or state defect you can actually see — if it is not fixing a visible problem, omit it.**

Dropped on purpose (do not add): `color-mix()` / `oklch(from ...)` accent+hairline+tint derivation (the Color System already mandates the accent variants, the 0.06/0.10/0.16 hairlines, and the 4-8% section tints — deriving them is redundant), `accent-color` (NOT Baseline), container queries (3 responsive breakpoints are already mandated for bento), and scroll-snap (gimmick-adjacent; the horizontal-scroll-strip layout already exists).

---

## Block A — Cross-card row alignment with subgrid

**Paste into:** `reference/bento-grids.md` (new section after "What Goes INSIDE the Large Card"). Cross-reference from `reference/section-layouts.md` Pattern 9.

**The defect this fixes:** a row of sibling cards where each card has a title, body, and footer (price / CTA / meta) — but the titles, bodies, and footers do NOT line up across cards because one title wraps to two lines. This ragged internal baseline is a top machine-generated-layout tell. `grid-auto-rows: 1fr` only equalizes the WHOLE-CARD height; it does nothing for the rows INSIDE each card. Subgrid is the fix.

**Use ONLY when:** cards repeat the same multi-line structure (title + body + footer) AND sit in one grid row. Do NOT use on single-line cards, on bento (mixed-size) cards, or anywhere the rows already align.

```css
.card-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  grid-template-rows: auto 1fr auto; /* title / body / footer */
}
.card {
  display: grid;
  grid-template-rows: subgrid; /* inherit the row track lines from .card-row */
  grid-row: span 3;            /* card occupies all three shared rows */
}
```

```html
<div class="card-row">
  <article class="card"><h3>…</h3><p>…</p><div class="card-foot">…</div></article>
  <article class="card"><h3>…</h3><p>…</p><div class="card-foot">…</div></article>
  <article class="card"><h3>…</h3><p>…</p><div class="card-foot">…</div></article>
</div>
```

Now every card's title sits on the same line, every footer aligns, even when one title wraps. Verified in Josh Comeau, "Brand New Layouts with CSS Subgrid" (joshwcomeau.com/css/subgrid) and web.dev/articles/css-subgrid.

**Plain-grid fallback (one line, no @supports needed — it degrades gracefully):** without subgrid, cards fall back to their own auto rows and stay equal-height via the parent's `1fr`; titles may go ragged but nothing breaks. If you must hard-guard: `@supports not (grid-template-rows: subgrid) { .card { grid-template-rows: auto auto auto; } }`.

---

## Block B — Shallow `:has()` for JS-free relational state

**Paste into:** `reference/anti-patterns.md` (note under the "Interaction Anti-Patterns" group, qualifying rule 31). Cross-reference from `reference/animations.md` "Global Rules".

**The point:** `:has()` lets a parent restyle itself based on a child's state with zero JS. Use it to remove JS toggles for genuine relational state — not as a flex.

**Allowed — a SINGLE, SHALLOW `:has()` for exactly these:**

```css
/* card with an image gets tighter padding + image-led layout */
.card:has(> img) { padding: 0; }
.card:has(> img) .card-body { padding: 24px; }

/* field wrapper turns its hairline to error when the input is invalid */
.field:has(input:invalid) { border-color: var(--error); }

/* nav reserves space / dims page when a menu is open (checkbox or details) */
.nav:has(details[open]) { box-shadow: 0 1px 0 var(--hairline); }
```

**Hard rules — do not violate:**
- One `:has()` per selector. Never chain (`:has(...):has(...)`) and never nest `:has()` inside `:has()`.
- Only the three relational cases above (has-image, field-has-invalid, nav-has-open-menu) unless it removes a real JS toggle. Inventing decorative `:has()` is itself an AI tell.
- It must replace JS or fix a real state, never decorate. If there is no state to react to, delete it.

`:has()` is Baseline; the plain fallback is "the state simply isn't reflected," which is acceptable for all three cases above.
