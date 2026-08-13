# Product-UI Surfaces

Static mockups and product *cards* aren't enough for some briefs. This file covers the surfaces that separate a real product from a template site: believable live UI, the e-commerce product page, commerce-conversion mechanics, the command palette, enterprise trust surfaces, and hardware product-explanation.

Every surface here is **gated** and **composed from existing primitives**. None of it is a default section. If you bolt these onto every page they become a new AI tell — the exact thing this skill exists to kill. Read the gate before you build.

## The Gate (read first)

| Surface | Build ONLY when | Max per page |
|---------|----------------|--------------|
| App-window shell / AI prompt+gallery | Brief is an app, dashboard, docs, or AI-native product | 1 |
| E-commerce PDP kit | Brief is a DTC / transactional commerce product page | 1 PDP |
| Commerce conversion (sticky buy-bar, bundle) | Brief is a DTC / transactional commerce product page | 1 buy-bar, 1 bundle module |
| Command palette overlay | App/dashboard/docs/data product AND 8+ distinct real destinations | 1 (never per-page) |
| Keycap (`kbd`) + visible trigger badge | Any product that has a real keyboard shortcut | — |
| Trust surfaces (status / changelog / trust center) | SaaS/devtools/fintech product that is operated/sold AND the brief or screen spec calls for it | 1 of each, opt-in |
| Hardware leader-line callouts | Physical-product brief with a real hero product photo | 1 annotated photo |

If the brief doesn't match a row, that surface does not exist for this project. Default is NONE.

**Inherited hard bans (do not re-invent, do not exempt yourself):**
- NO browser-chrome dots on any surface (anti-pattern 11). No exceptions — not on app shells, not on terminals, not on status pages.
- 3-5 elements max per mockup surface (css-mockups.md rule 3).
- Realistic, non-round data. No "John Doe", no "$100".
- Match the project's radius / accent / spacing / hairline tokens. These surfaces inherit the design system; they do not introduce new chrome.
- These surfaces count against the card budget (max 2 default cards), bullet budget (max 5), and eyebrow budget (max 1).
- Prefer a static high-fidelity composition over JS. Animate only when it communicates state (anti-pattern 31).

---

## 1. Live product UI (app/dashboard/AI products)

This is what makes Linear, Clerk, Cursor, and Stripe read as real software instead of a brochure. The skill already ships single-surface mockups (css-mockups.md). This section adds the two primitives those mockups can't express. **Build at most one live-UI composition per page.**

### 1a. The composed app-window shell

A single product surface composed of sidebar + toolbar + content — the thing that says "this is an application," not "this is a screenshot of one card." css-mockups.md gives you the *content* panes; this gives you the *frame around them*.

```html
<figure class="appshell" aria-label="Product interface preview">
  <aside class="appshell__rail">
    <div class="appshell__brand">Halyard</div>
    <nav class="appshell__nav">
      <a class="appshell__item is-active">Pipelines</a>
      <a class="appshell__item">Runs</a>
      <a class="appshell__item">Secrets</a>
      <a class="appshell__item">Settings</a>
    </nav>
  </aside>
  <div class="appshell__main">
    <header class="appshell__bar">
      <span class="appshell__crumb">Pipelines / deploy-prod</span>
      <span class="appshell__status">Healthy · 14:32 UTC</span>
    </header>
    <div class="appshell__content"><!-- ONE css-mockups.md pane: table, chart, or ledger --></div>
  </div>
</figure>
```

```css
.appshell {
  display: grid;
  grid-template-columns: 200px 1fr;
  border: 1px solid var(--hairline-2);   /* project hairline, not 1px solid gray */
  border-radius: var(--radius-lg);
  overflow: hidden;
  background: var(--bg);
  margin: 0;
}
.appshell__rail { background: var(--bg-2); padding: 20px 16px; border-right: 1px solid var(--hairline); }
.appshell__item { display: block; padding: 8px 10px; border-radius: var(--radius-sm); color: var(--text-2); }
.appshell__item.is-active { background: var(--accent-tint); color: var(--text); }  /* accent at 6-8% */
.appshell__bar {
  display: flex; justify-content: space-between; align-items: center;
  padding: 14px 20px; border-bottom: 1px solid var(--hairline);
  font-variant-numeric: tabular-nums; color: var(--text-2); font-size: 14px;
}
.appshell__content { padding: 24px; }
```

Rules:
- The frame is the addition; the **content pane is one css-mockups.md pattern** (table, chart, ledger). Don't fill all three regions with rich UI — pick one focal pane and keep the rest quiet (3-5 elements total still applies).
- The active nav item uses the accent tint, not a gray fill. This is often the only place the accent appears in the visual — make it count.
- Toolbar metadata (breadcrumb, status, timestamp) is real and tabular. No fake doc IDs or version chips (Phase 6 strips those).
- NO traffic-light dots in the title bar. A breadcrumb or product name is the title bar.

### 1b. AI-native prompt + output gallery

For AI products (think Krea's split prompt-left / output-right canvas), the central product UI is a prompt input feeding a gallery of outputs. This is the hero visual, not a feature card.

```html
<div class="aiunit">
  <div class="aiunit__prompt">
    <label class="aiunit__label">Prompt</label>
    <p class="aiunit__field">Editorial product shot, matte ceramic, raking window light</p>
    <button class="aiunit__run">Generate</button>
  </div>
  <div class="aiunit__gallery">
    <img src="https://picsum.photos/seed/matte-ceramic-raking-light-a/600/750" alt="..." width="600" height="750" loading="lazy">
    <img src="https://picsum.photos/seed/matte-ceramic-raking-light-b/600/750" alt="..." width="600" height="750" loading="lazy">
    <img src="https://picsum.photos/seed/matte-ceramic-raking-light-c/600/750" alt="..." width="600" height="750" loading="lazy">
  </div>
</div>
```

Rules:
- The prompt is a styled `div`/`p`, not a live `<textarea>` you can't back with a model. The CTA names the action ("Generate", "Render") — never "Submit".
- Gallery images use **descriptive non-numeric Picsum seeds** per imagery.md (the `-a/-b/-c` suffix keeps them consistent and swappable), in a non-square ratio (here 4:5). Never gradient chips standing in for generated output.
- The output should *match the prompt*. A prompt about ceramics with photos of laptops is the tell that nobody wired the demo to anything real.

### 1c. Auto-cycling states and theme-switchable demos — ONE rule, not a pattern library

These are the highest fake-interactivity risk. The mechanic is **already covered**: state-transitions and tab-switching live in animations.md (#5 Smooth State Transitions) and section-layouts.md Pattern 12 (Tab Content Switcher).

The only rule: **if a live demo switches state, every state it switches to must be real and meaningful.** A tabbed component demo with three genuinely different states is good. A panel that auto-cycles through three fabricated screens on a timer, communicating nothing, is decorative motion (anti-pattern 31) — cut it. Default to a single static high-fidelity composition. Reach for tab-switching (Pattern 12) only when the states are real content the visitor would actually compare.

---

## 2. E-commerce PDP kit (DTC / commerce briefs ONLY)

The product detail page is the single most-loaded page in a DTC build, and the AI default — one image plus a native `<select>` dropdown — reads as an untouched free Shopify theme. This kit is the premium alternative. **Build at most one PDP per project, only for commerce briefs.** North Star for restraint is Aesop / Glossier / Our Place / Polène, not conversion-maximizer Shopify-app aesthetics.

For everything that isn't on this list (catalog grids, editorial sections, footers), defer to non-card-patterns.md and imagery.md. The PDP is a layout, not its own template.

### 2a. Image-rail gallery + buy-box

```html
<section class="pdp">
  <div class="pdp__media">
    <img class="pdp__main" id="pdpMain"
      src="https://picsum.photos/seed/polene-numero-un-camel-front/1000/1250"
      alt="Numéro Un handbag in camel, front view" width="1000" height="1250">
    <div class="pdp__rail">
      <button class="pdp__thumb is-active"><img src="https://picsum.photos/seed/polene-numero-un-camel-front/160/200" alt="Front" width="160" height="200"></button>
      <button class="pdp__thumb"><img src="https://picsum.photos/seed/polene-numero-un-camel-side/160/200" alt="Side" width="160" height="200"></button>
      <button class="pdp__thumb"><img src="https://picsum.photos/seed/polene-numero-un-camel-interior/160/200" alt="Interior" width="160" height="200"></button>
    </div>
  </div>
  <div class="pdp__buybox">
    <h1 class="pdp__name">Numéro Un Nano</h1>
    <p class="pdp__price">$385</p>
    <!-- variant swatches, size control, ATC go here -->
  </div>
</section>
```

```css
.pdp { display: grid; grid-template-columns: 1.4fr 1fr; gap: 56px; align-items: start; }
.pdp__media { display: grid; grid-template-columns: 64px 1fr; gap: 16px; }
.pdp__rail { display: flex; flex-direction: column; gap: 12px; order: -1; }
.pdp__price { font-variant-numeric: tabular-nums; font-size: 22px; }
@media (max-width: 768px) { .pdp { grid-template-columns: 1fr; } .pdp__media { grid-template-columns: 1fr; } .pdp__rail { flex-direction: row; order: 1; } }
```

- Prices are **realistic and non-round** ($385, $64, $218 — not $100, not $99.00 unless the brand actually prices that way).

### 2b. Real-image variant/size swatches with out-of-stock states

Swatches map to **real product photos** via descriptive Picsum seeds (imagery.md), not gradient color chips. Clicking a swatch switches the main image. Out-of-stock is an explicit, visible state — not a missing option.

```html
<div class="swatches" role="radiogroup" aria-label="Color">
  <button class="swatch is-selected" role="radio" aria-checked="true"
    data-main="https://picsum.photos/seed/polene-numero-un-camel-front/1000/1250" aria-label="Camel">
    <img src="https://picsum.photos/seed/polene-numero-un-camel-chip/72/72" alt="" width="72" height="72">
  </button>
  <button class="swatch" role="radio" aria-checked="false"
    data-main="https://picsum.photos/seed/polene-numero-un-noir-front/1000/1250" aria-label="Noir">
    <img src="https://picsum.photos/seed/polene-numero-un-noir-chip/72/72" alt="" width="72" height="72">
  </button>
  <button class="swatch is-oos" role="radio" aria-checked="false" disabled aria-label="Taupe, out of stock">
    <img src="https://picsum.photos/seed/polene-numero-un-taupe-chip/72/72" alt="" width="72" height="72">
  </button>
</div>
```

```css
.swatch { width: 72px; height: 72px; border-radius: var(--radius-sm); border: 1px solid var(--hairline-2); overflow: hidden; padding: 0; }
.swatch.is-selected { outline: 2px solid var(--accent); outline-offset: 2px; }
.swatch.is-oos { position: relative; cursor: not-allowed; }
.swatch.is-oos::after { content: ""; position: absolute; inset: 0; background: linear-gradient(to top left, transparent 47%, var(--hairline-2) 47%, var(--hairline-2) 53%, transparent 53%); }  /* a hairline strike, not a gradient blob */
.swatch.is-oos img { opacity: 0.45; }
```

Rules:
- **Cap visible swatches at ≤6.** Beyond that, show six and a `+N` affordance ("+4 colors"). No swatch sprawl.
- Selected state uses the accent outline. Out-of-stock is desaturated + a hairline strike + `disabled` + an accessible label — never just greyed with no announcement.
- The chip is a *cropped real photo*, not a CSS color. (One-line JS: clicking sets `#pdpMain.src = button.dataset.main`.)

### 2c. Slide-out cart drawer

One cart drawer pattern (Allbirds-style): adding an item previews items + total without breaking the browse flow. Elevation through lightness — **no glassmorphism, no heavy drop-shadow** (Design Laws: elevation through lightness).

```html
<aside class="cart" id="cart" aria-label="Cart" aria-hidden="true">
  <header class="cart__head"><span>Cart</span><button class="cart__close" aria-label="Close cart">✕</button></header>
  <ul class="cart__items">
    <li class="cart__row">
      <img src="https://picsum.photos/seed/polene-numero-un-camel-front/120/150" alt="" width="120" height="150">
      <div><p>Numéro Un Nano · Camel</p><p class="cart__price">$385</p></div>
    </li>
  </ul>
  <footer class="cart__foot"><span>Subtotal</span><span class="cart__total">$385</span></footer>
  <button class="cart__checkout">Checkout</button>
</aside>
```

```css
.cart { position: fixed; top: 0; right: 0; height: 100dvh; width: min(420px, 90vw);
  background: var(--bg); border-left: 1px solid var(--hairline-2);
  transform: translateX(100%); transition: transform 320ms cubic-bezier(0.32, 0.72, 0, 1);
  display: flex; flex-direction: column; }
.cart.is-open { transform: translateX(0); }
.cart__total { font-variant-numeric: tabular-nums; }
```

One cart drawer per page. Transform/opacity only. Respect `prefers-reduced-motion`.

### 2d. Sticky add-to-cart that reveals on scroll

A slim bar that appears **only after the hero ATC scrolls out of view** — not glued to the top from page load. This is the *legitimate exception* to anti-pattern #6 (banned sticky navbar): it is a buy affordance, not chrome, and it appears conditionally. See section 3a for the state-aware version. The control transforms from "Select size" to "Add to bag" once a size is chosen (2e).

### 2e. The transforming Select-size → Add-to-bag control

One button that is honest about state: before a size is picked it reads "Select size" and opening it reveals sizes; once a size is chosen the same control becomes "Add to bag — Size M". One control, two states, no separate dropdown-then-button stack.

```css
.atc { width: 100%; padding: 16px; border-radius: var(--radius-sm); background: var(--bg-2); color: var(--text-2); }
.atc.is-ready { background: var(--accent-ink); color: var(--paper); }  /* --accent-ink (NOT --accent) for white-text fills — see SKILL.md Color System step 5 (ACCENT-FILL CONTRAST CHECK) */
```

The accent appears only when the control is actually actionable — that teaches the eye what "ready to buy" looks like.

---

## 3. Commerce conversion (DTC / transactional briefs ONLY)

Two patterns, both hard-gated to commerce. **Never on SaaS, agency, service, hospitality, or info briefs.** Framed as the subtraction philosophy applied to commerce — calm economics, not conversion chrome.

### 3a. State-aware sticky buy-bar

Quantity/case stepper + a Subscribe-vs-One-time segmented toggle with **one** inline savings line + a single CTA. Mirrors the variant control's accent-on-ready logic. Reveals only after the hero ATC scrolls out (2d).

```html
<div class="buybar" data-revealed="false">
  <span class="buybar__name">Magic Spoon · Cocoa · 4-pack</span>
  <div class="buybar__qty"><button aria-label="Decrease">−</button><span>1</span><button aria-label="Increase">+</button></div>
  <div class="buybar__plan" role="radiogroup" aria-label="Purchase type">
    <button role="radio" aria-checked="false">One-time · $39</button>
    <button role="radio" aria-checked="true" class="is-on">Subscribe · $33 <span class="buybar__save">save $6</span></button>
  </div>
  <button class="buybar__cta">Add to box</button>
</div>
```

- The CTA **names the action** ("Add to box", "Add to bag") — not a generic "Add to Cart" if a better verb fits the brand.
- Obey ux-writing.md character limits and banned-words on every label.
- One savings figure, stated plainly ("save $6"). Not a flashing badge.
- Carved out as the sanctioned exception to anti-pattern #6 and #31. Exactly one buy-bar per page.

### 3b. Bundle / value-stacking module (optional fill-the-box configurator)

À-la-carte vs bundle price shown as **calm economics** — one savings figure, framed as "save $X" or a strike-through, never a flashing urgency badge. Our Place and Caraway frame set-vs-individual savings this way; Magic Spoon's build-your-own-box uses a live tally. Build it from existing primitives — a ledger (non-card-patterns.md Pattern 1) or table (Pattern 7), not new card chrome.

```html
<div class="bundle">
  <p class="bundle__line">Buy the set: <s class="bundle__was">$523</s> <strong class="bundle__now">$385</strong> · save $138</p>
</div>
```

For a fill-the-box configurator: a counter ("4 of 6 chosen") with a live tally and a checkout gated until the box is full. One tally, one CTA.

### Conversion guardrails (so this never becomes a new tell)

- NO rotating/carousel announcement bar.
- NO countdown timers.
- NO "free shipping" flashing red urgency.
- NO fake scarcity ("only 3 left").
- NO multiple savings badges per screen.
- At most **ONE** static, brand-tinted utility line is permitted (e.g. "Free shipping over $75 · 30-day returns"). It is optional and dismissible. Demoted from a co-equal pattern to a single constrained line — it is not an announcement bar.

---

## 4. Command palette + keycap

Split in two: the keycap is a cheap always-allowed premium tell; the overlay is gated to real apps.

### 4a. Keycap (`kbd`) + visible trigger badge — ALWAYS allowed

The inline keycap and a single visible "⌘K" / "/" badge inside the existing search/nav affordance. Low-risk, works even on small sites. Shipped across shadcn/ui, Radix, Chakra, Nuxt UI, daisyUI.

```html
<button class="navsearch">Search <kbd class="kbd">⌘K</kbd></button>
```

```css
.kbd {
  font-family: inherit; font-size: 12px; line-height: 1;
  padding: 3px 6px; border-radius: var(--radius-xs);
  border: 1px solid var(--hairline-2);          /* single 1px hairline, project alpha token */
  background: var(--bg-2);                        /* paper-2 surface */
  color: var(--text-2);
}
```

Rules:
- 1px hairline using the skill's alpha tokens, paper-2 surface, project xs/sm radius. **NO faux-3D bevels, NO double borders, NO bottom-shadow "physical key" effect** — that is itself an AI tell.
- The badge must reflect a shortcut that **actually works**. A decorative-only ⌘K badge with no handler is banned (anti-pattern 67).
- The badge uses the project's accent/hairline tokens, not a generic gray pill.

### 4b. Command palette overlay — GATED to apps

Hard gate (ALL must be true): product is an app/dashboard/docs/data product **AND** has 8+ genuinely distinct real destinations/actions. **Forbidden on marketing/brochure/landing-only builds** (a Cmd-K palette on a <6-page marketing site is anti-pattern 68 — cargo-cult). One palette per product, never per-page. Exemplars: Linear, Vercel, Raycast, Stripe Docs, Figma, Notion.

```html
<div class="palette" role="dialog" aria-modal="true" aria-label="Command menu" hidden>
  <div class="palette__scrim"></div>
  <div class="palette__box">
    <input class="palette__input" type="text" placeholder="Search or run a command" aria-label="Command input">
    <ul class="palette__results" role="listbox">
      <li class="palette__group">Pages</li>
      <li class="palette__row"><span>Pipelines</span></li>
      <li class="palette__row"><span>Deploy to production <span class="palette__alias">(Ship)</span></span><kbd class="kbd">D</kbd></li>
    </ul>
  </div>
</div>
```

```css
.palette__scrim { position: fixed; inset: 0; background: rgba(0,0,0,0.4); backdrop-filter: blur(2px); }
.palette__box {
  position: fixed; top: 18vh; left: 50%; transform: translateX(-50%);
  width: min(560px, 92vw); background: var(--bg);
  border: 1px solid var(--hairline-2); border-radius: var(--radius-md);
}
```

Requirements (and only these):
- Centered overlay over a dimmed + lightly blurred canvas. **No glassmorphism, no heavy drop-shadow** — elevation through lightness (Design Laws).
- Results grouped **ONLY when there are 2+ real groups**. Never invent "Recent / Pages / Actions" buckets to look sophisticated — an empty or single-item group is a tell (anti-pattern 69). No fake or placeholder commands.
- Per-row icon + label + optional inline shortcut hint.
- Fuzzy match with recency boosting. Aliases shown as "Title (Alias)".
- *Optional one-liner:* the last visible row may be half-cut to signal overflow. Optional, not a rule.

### 4c. A11y (mandatory — reuse, don't re-spec)

Reuse the existing hardening focus-management line (Phase 8: "Focus management: `:focus-visible`, trapped in modals, returned on close"). For the palette that means: `role="dialog"` + `aria-modal`, focus trap, **Esc closes and restores focus to the trigger**, arrow-key navigation, and a live result-count for screen readers. Cross-reference Phase 8; do not duplicate the spec.

---

## 5. Trust surfaces (SaaS/devtools/fintech, operated/sold — opt-in)

Three enterprise-sales surfaces buyers visit before they sign. **Opt-in only:** build when the brief explicitly involves an operated/sold product in the SaaS/devtools/fintech North Star AND the user or screen spec asks for that surface. Never auto-added to the default page flow. All three are **composed from existing primitives** — ledger, table, timeline, editorial sections — not new card chrome.

### 5a. Status page

- Full-width semantic "All systems operational" banner with a **SINGLE semantic state dot**. Reconcile with the browser-chrome-dot ban: one semantic state dot is legitimate; decorative red/yellow/green macOS-style chrome dots stay banned (anti-pattern 11).
- 90-day uptime history bar: ~90 flex segments colored by day state, with hover tooltips (Instatus / Better Stack / Atlassian pattern).
- Component-group ledger rows → reuse non-card-patterns.md **Pattern 1 (Ledger)**.
- Incident timeline → reuse section-layouts.md **Pattern 5 (Numbered Timeline, vertical)**.
- `font-variant-numeric: tabular-nums` on all metrics.

```html
<div class="status__banner"><span class="status__dot"></span> All systems operational</div>
<div class="uptime" aria-label="90-day uptime">
  <!-- ~90 <span class="uptime__seg" data-state="up"> segments -->
</div>
```

```css
.status__dot { width: 9px; height: 9px; border-radius: 9999px; background: var(--ok); display: inline-block; }
.uptime { display: flex; gap: 2px; }
.uptime__seg { flex: 1; height: 36px; border-radius: 2px; background: var(--ok); }
.uptime__seg[data-state="degraded"] { background: var(--warn); }
.uptime__seg[data-state="down"] { background: var(--err); }
```

**Severity colors come from the project's semantic color tokens (`--ok/--warn/--err`), not hardcoded traffic-light hex.** The exact segment count is derived from the real product, not copy-pasted.

### 5b. Changelog

- Media-first entry: visual/screenshot **above** the title (verified on Linear).
- Inline product-area tags (e.g. "Agents", "Diffs", "Desktop").
- Feature entries are prose; categorized Fixes/Improvements/API lists **may be short bullets** (Linear itself is mixed — an absolutist "no bullets" rule would contradict the gold-standard exemplar). These short fix lists still count toward the page bullet budget.
- Layout: reuse the vertical timeline / editorial two-column primitives. A **left date-rail is ONE optional layout, not canonical** — Linear uses inline date headers. Offer either.
- RSS is **optional**, not required (Linear has none).

### 5c. Trust center

- Compliance badge grid with **REAL named certs + real-looking attestation dates**: SOC 2 Type 2, ISO 27001, GDPR, PCI DSS. No invented frameworks.
- Sub-processor table → reuse non-card-patterns.md **Pattern 7 (Table)** with named vendors (AWS, Datadog, etc.).
- Gated document-request flow ("Get access").
- Editorial section / pillar framing for the security narrative → editorial rule sections (non-card-patterns.md Pattern 3).
- **Ban the generic shield-icon security-card grid** (anti-pattern 70). The badge grid uses real attestation names + dates, NOT decorative lock/shield icon cards. This surface exists *to replace* that exact AI tell.

### Trust-surface anti-template note

The uptime-bar segment count, badge set, and section labels must be **derived from the actual product**, not copy-pasted — so two outputs don't look identical. Priority is low; these are opt-in.

---

## 6. Hardware product-explanation: leader-line callouts

For physical-product briefs, the one genuinely-uncovered buildable technique is **annotated leader-line / numbered-hotspot callouts overlaid on a single real product photo** (Apple's "Take a closer look"). Everything else in the hardware kit is already covered — see the redirects below.

```html
<figure class="callouts">
  <img src="https://picsum.photos/seed/everyday-backpack-charcoal-three-quarter/1600/1000"
       alt="Everyday Backpack in charcoal, three-quarter view" width="1600" height="1000">
  <button class="callout" style="left:34%; top:28%"><span class="callout__num">1</span></button>
  <button class="callout" style="left:62%; top:55%"><span class="callout__num">2</span></button>
  <!-- static fallback legend, always present -->
  <ol class="callouts__legend">
    <li><span class="callout__num">1</span> MagLatch closure</li>
    <li><span class="callout__num">2</span> 20L expandable</li>
  </ol>
</figure>
```

```css
.callout__num {
  width: 22px; height: 22px; border-radius: 9999px;
  background: var(--accent-ink); color: var(--paper);  /* --accent-ink (NOT --accent) — see SKILL.md Color System step 5 */
  display: grid; place-items: center; font-size: 12px; font-variant-numeric: tabular-nums;
}
.callout { position: absolute; border: 0; background: none; }
```

Guardrails (so it doesn't become a 6-card hotspot grid):
- ONE hero product photo per page maximum. Never a grid of annotated thumbnails.
- 3-6 markers max. Each label ≤4 words, real units, no marketing adjectives.
- Markers are the accent color; **hairline leader lines only, NO icon-in-a-circle chrome, NO drop shadows.**
- Must degrade to a readable numbered legend without JS (the legend is always in the DOM; absolute markers are the enhancement).
- This is NOT a replacement for the banned 3-card icon grid by becoming a 6-card hotspot grid.

**Redirects — already covered, do not re-document:**
- Oversized single-metric callout ("1600 nits") IS non-card-patterns.md **Pattern 6 (single hero stat)**. Reuse it.
- Spec accordion / "In the Box" specs use **Pattern 1 (ledger)** rows, never icon cards. One-line note only.
- Dark studio product staging is just photography (imagery.md) placed in the existing dark-panel surface tier. One sentence, no new pattern.
- Cutaway/exploded views add no buildable primitive — they are a render/photo use-case governed by imagery.md's medium rule. Mention only; never build in CSS.

---
