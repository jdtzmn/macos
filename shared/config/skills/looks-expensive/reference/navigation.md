# Navigation System

The header is the first surface a visitor judges. The skill used to only constrain nav negatively (max 5 links, working hamburger) and the old anti-pattern #6 even prescribed a floating pill — which is now a one-click template block. This file is the positive replacement: a TIGHT, gated library. Four patterns, each with a guardrail so it can't become a new AI tell.

The AI default — logo-left, 5 bare links, a hamburger that does nothing on desktop and a half-broken drawer on mobile — is an instant template tell. Every premium reference site ships an engineered header. Build one.

## Hard caps (carry these in from the Design Laws — do not relax)

- **Max 5 primary nav links.** The cognitive cap from Phase 4 step 8 is unchanged. A 6th link means your IA is wrong, not your nav.
- **One primary CTA in the header, persistent.** Reinforces the 1-primary-button rule. Everything else is a text link or a quiet ghost button.
- **No shadowed edge-to-edge navbar.** A solid bar glued to the top with a drop-shadow is the tell. The fix is the scroll-state header below — NOT a detached floating pill.

---

## Pattern 1 — Scroll-state header (THE DEFAULT)

Replaces both the shadowed sticky bar AND the floating-pill recommendation. This is now the premium default for almost every page.

The header sits transparent over the hero. Past a scroll threshold it gains a hairline bottom border, a backdrop-blur, and a modest height-shrink. Vercel, Stripe, and Linear all ship a version of this — it is a community-named, attributed pattern ("Vercel-style scroll-aware navigation"). Done right it reads as engineered; done wrong (heavy shadow, big height jump, blur on the scrolling body) it reads as a Bootstrap template.

```html
<header class="site-header" data-scrolled="false">
  <a class="site-header__logo" href="/">Acme</a>
  <nav class="site-header__nav" aria-label="Primary">
    <a href="/product">Product</a>
    <a href="/pricing">Pricing</a>
    <a href="/docs">Docs</a>
  </nav>
  <a class="site-header__cta" href="/start">Start building</a>
</header>
```

```css
.site-header {
  position: sticky;
  top: 0;
  z-index: 50;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 80px;
  padding-inline: clamp(20px, 4vw, 48px);
  background: transparent;
  border-bottom: 1px solid transparent;
  transition: height 240ms cubic-bezier(0.32, 0.72, 0, 1),
              background-color 240ms ease,
              border-color 240ms ease;
}

.site-header[data-scrolled="true"] {
  height: 64px;                                  /* modest shrink, ~16-20% */
  background: color-mix(in oklab, var(--bg) 72%, transparent);
  -webkit-backdrop-filter: blur(12px);
  backdrop-filter: blur(12px);                   /* fixed/sticky only — see animations.md:150 */
  border-bottom-color: color-mix(in oklab, var(--ink) 10%, transparent);
}
```

State toggle — IntersectionObserver, with a no-JS fallback that is a static solid header (never a broken transparent one over white):

```html
<!-- sentinel: a 1px element at the very top of the page -->
<div class="scroll-sentinel" aria-hidden="true"></div>
```

```js
const header = document.querySelector('.site-header');
const sentinel = document.querySelector('.scroll-sentinel');

new IntersectionObserver(([entry]) => {
  header.dataset.scrolled = String(!entry.isIntersecting);
}, { rootMargin: '0px' }).observe(sentinel);
```

```css
/* No-JS / observer-unsupported fallback: solid header, never transparent-over-white. */
@media (scripting: none) {
  .site-header { background: var(--bg); border-bottom-color: color-mix(in oklab, var(--ink) 10%, transparent); }
}
@media (prefers-reduced-motion: reduce) {
  .site-header { transition: none; }            /* state still flips; just no animated travel */
}
```

**Rules.**
- Shrink is modest (80→64px is plenty). A 96→48px collapse looks like a gimmick.
- Blur lives ONLY on the fixed header (animations.md:150). Never on scrolling content.
- The threshold is the hero edge, not an arbitrary px number — use a sentinel or `IntersectionObserver` on the hero, so it works at any viewport height.
- Transparent-over-hero only works when the hero has enough contrast under the logo and links. If the hero is light, give the over-hero links the ink color and skip the transparent state — go straight to the solid/blur state.

---

## Pattern 2 — Mega-menu (GATED — only when IA depth earns it)

A multi-column dropdown with grouped labels, one line of microcopy per item, and outlined icons (one family, per icon-system.md). NN/g validates mega-menus as a premium pattern for deep IA. Aman is the reference for the restrained version: region-organized destinations plus a persistent reserve/call CTA, fully keyboard-navigable.

**Depth gate — do not open a mega-menu unless ALL are true:**
1. At least **2 top-level nav items** each have **4+ sub-destinations**.
2. The sub-destinations group into **named categories** (not one flat list of 12 links).
3. Each item has a real reason for one line of microcopy (it isn't self-evident from the label).

If the gate fails: use a plain link, or a single-column simple dropdown. A mega-menu over a shallow IA is the enterprise-template tell.

```html
<div class="nav-item" data-open="false">
  <button class="nav-item__trigger" aria-expanded="false" aria-controls="m-product">Product</button>
  <div class="mega" id="m-product" role="region" aria-label="Product">
    <div class="mega__group">
      <p class="mega__label">Build</p>
      <a class="mega__link" href="/editor">
        <svg class="mega__icon" aria-hidden="true">…</svg>
        <span><span class="mega__title">Editor</span><span class="mega__desc">Write and preview in one pane.</span></span>
      </a>
      <!-- 3 more -->
    </div>
    <!-- 1-2 more groups -->
  </div>
</div>
```

```css
.mega {
  position: absolute;
  display: grid;
  grid-template-columns: repeat(3, minmax(180px, 1fr));
  gap: 8px 32px;
  padding: 24px;
  background: var(--bg);
  border: 1px solid color-mix(in oklab, var(--ink) 8%, transparent);
  border-radius: 16px;                            /* 4-32 system, border-radius.md */
  box-shadow: 0 12px 32px color-mix(in oklab, var(--ink) 8%, transparent);
  opacity: 0;
  transform: translateY(6px);
  pointer-events: none;
  transition: opacity 180ms ease, transform 180ms cubic-bezier(0.16, 1, 0.3, 1);
}
.nav-item[data-open="true"] .mega { opacity: 1; transform: none; pointer-events: auto; }
```

**Rules.**
- **One morphing container.** If you have two or more top-level mega-menus, animate a SINGLE panel that resizes between them (height/width transition). Two separate panels fading over each other is the cheap version.
- Microcopy is one line, sentence case, specific. Not "Powerful tools for teams."
- Icons are outlined, 0.8-1px stroke, one family (icon-system.md). Mixed icon families here is anti-pattern #30.
- Open on hover AND on click/focus. `aria-expanded` on the trigger, `aria-controls` to the panel, Esc closes, focus moves into the panel on open and returns to the trigger on close.

---

## Pattern 3 — Engineered mobile drawer (this is the upgraded "hamburger must work")

The bare hamburger mandate (anti-pattern #46) is now this. A drawer that toggles `display` with no scroll-lock, no focus trap, and no Esc is a correctness/a11y failure, not a style choice. These are requirements, not decoration.

Full-screen, large-type links with a staggered entrance, body-scroll-lock, focus trap, icon-to-X morph, Esc-to-close.

```html
<button class="burger" aria-label="Menu" aria-expanded="false" aria-controls="drawer">
  <span class="burger__bar"></span><span class="burger__bar"></span>
</button>

<div class="drawer" id="drawer" hidden>
  <nav class="drawer__nav" aria-label="Primary">
    <a style="--i:0" href="/product">Product</a>
    <a style="--i:1" href="/pricing">Pricing</a>
    <a style="--i:2" href="/docs">Docs</a>
  </nav>
  <a class="drawer__cta" href="/start">Start building</a>
</div>
```

```css
.drawer { position: fixed; inset: 0; z-index: 60; display: grid; align-content: center;
          gap: 8px; padding: 32px; background: var(--bg); }
.drawer__nav a {
  font-size: clamp(28px, 8vw, 44px);             /* large type — this is the point */
  font-weight: 500;
  opacity: 0; transform: translateY(12px);
  animation: drawer-in 420ms cubic-bezier(0.16, 1, 0.3, 1) forwards;
  animation-delay: calc(var(--i) * 60ms);        /* staggered links */
}
@keyframes drawer-in { to { opacity: 1; transform: none; } }

/* icon-to-X morph */
.burger__bar { display: block; width: 24px; height: 2px; background: currentColor;
               transition: transform 240ms cubic-bezier(0.32,0.72,0,1), opacity 160ms; }
.burger[aria-expanded="true"] .burger__bar:nth-child(1) { transform: translateY(4px) rotate(45deg); }
.burger[aria-expanded="true"] .burger__bar:nth-child(2) { transform: translateY(-4px) rotate(-45deg); }

@media (prefers-reduced-motion: reduce) {
  .drawer__nav a { animation: none; opacity: 1; transform: none; }
}
```

```js
const burger = document.querySelector('.burger');
const drawer = document.querySelector('#drawer');
let lastFocus;

function openDrawer() {
  lastFocus = document.activeElement;
  drawer.hidden = false;
  burger.setAttribute('aria-expanded', 'true');
  document.body.style.overflow = 'hidden';           // body-scroll-lock
  drawer.querySelector('a').focus();                 // move focus in
  document.addEventListener('keydown', onKey);
  drawer.addEventListener('keydown', trap);          // focus trap
}
function closeDrawer() {
  drawer.hidden = true;
  burger.setAttribute('aria-expanded', 'false');
  document.body.style.overflow = '';
  document.removeEventListener('keydown', onKey);
  lastFocus?.focus();                                // return focus to trigger
}
const onKey = e => { if (e.key === 'Escape') closeDrawer(); };
const trap = e => {
  if (e.key !== 'Tab') return;
  const f = drawer.querySelectorAll('a, button');
  const first = f[0], last = f[f.length - 1];
  if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
  else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
};
burger.addEventListener('click', () => drawer.hidden ? openDrawer() : closeDrawer());
```

**Requirements (all mandatory — this is the a11y floor):** body-scroll-lock while open, focus trap, focus moved in on open and returned to the trigger on close, Esc closes, `aria-expanded` reflects state, icon morphs to an X. A drawer missing any of these fails review.

---

## Pattern 4 — Hide-on-scroll-down / show-on-scroll-up (LONG CONTENT ONLY)

The header hides when scrolling down (reading) and reappears when scrolling up (reaching for nav). **Article and docs pages only. Never a marketing landing page** — hiding the CTA the visitor came to click is self-sabotage.

```js
let lastY = 0;
addEventListener('scroll', () => {
  const y = scrollY;
  header.dataset.hidden = String(y > lastY && y > 200);
  lastY = y;
}, { passive: true });
```

```css
.site-header { transition: transform 280ms cubic-bezier(0.32,0.72,0,1); }
.site-header[data-hidden="true"] { transform: translateY(-100%); }
@media (prefers-reduced-motion: reduce) { .site-header { transition: none; } }
```

Gate: long-form content only. If your page is a hero + 6 marketing sections, you don't get this.

---

## Saturated patterns — allowed only by exception, never as a default

These shipped everywhere in 2024-25 and now read as cargo-cult. Using one as your default header is itself an AI tell.

- **Floating pill / detached nav.** A rounded capsule floating with margin and a shadow. One-click template block (Aceternity, shadcn starters, GeneratePress). Allowed ONLY on a genuinely minimal product (a handful of links, no mega-menu, no deep IA). Default to Pattern 1 instead. This is the correction to the old anti-pattern #6.
- **Cmd-K / command-palette as primary navigation.** Allowed ONLY on truly keyboard-driven products (a real CLI/dev tool where power users live in it). Putting "Press ⌘K" in the header of a marketing site is a tell. It supplements nav; it never replaces it.

## Cut on purpose (do not add these here)

- **Sliding active-indicator and char-level nav flourishes** — decorative, low expensiveness-per-risk. Skip.
- **Scroll-spy "on this page" TOC** — this overlaps the Index/Contents pattern in non-card-patterns.md (Pattern 9). If a page needs an in-page TOC, build Pattern 9 there and add `scroll-margin-top` for the sticky-header offset plus an IntersectionObserver active-state. Do not duplicate it into the header.

```css
/* If you anchor-link to sections under a sticky header, set this on the targets
   (belongs with non-card-patterns.md Pattern 9, noted here for completeness): */
:target, [id] { scroll-margin-top: 88px; }
```

## Pre-output nav check

- [ ] 5 or fewer primary links. One persistent primary CTA. No shadowed edge-to-edge bar.
- [ ] Default header is the scroll-state Pattern 1 (transparent-over-hero → hairline + blur + modest shrink), not a floating pill.
- [ ] No-JS fallback is a solid header; `prefers-reduced-motion` respected.
- [ ] Mega-menu present ONLY if the depth gate passed (2+ items × 4+ grouped sub-destinations); otherwise plain link/simple dropdown.
- [ ] Mobile drawer has scroll-lock, focus trap, Esc, `aria-expanded`, icon-to-X morph.
- [ ] Hide-on-scroll used ONLY on long content, never on a landing page.
- [ ] No Cmd-K-as-nav unless the product is genuinely keyboard-driven.
