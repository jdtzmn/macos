# Dark Mode

Load this file in Phase 3 (Color System) when the scene sentence forces a dark theme, and re-check it in Phase 5 (build) and Phase 7 (audit). Dark mode is the default expectation for the North Star category — Linear, Vercel, Stripe, Cursor, Mercury. Getting it wrong is the single largest "looks AI-flat vs looks-Linear" tell for that category.

**Dark mode is a separately-engineered system, not a palette flip.** Inverting `--bg` and `--text` and calling it done is the giveaway. Four rules below are non-negotiable. They build on the existing Color System rules (SKILL.md): you already derive neutrals in OKLCH from the brand hue, you already have ink tiers, surface tiers, hairline alphas at 0.06/0.10/0.16, an on-dark accent variant, and the ACCENT VISIBILITY rule. This file is the dark-specific layer on top of those — do not re-derive what already exists.

## Rule 1 — Elevation INVERTS: higher surfaces get LIGHTER

In light mode, higher surfaces are usually the same paper with a shadow. In dark mode, throw the shadow away. **Elevation reads as a step UP in lightness, not as a drop shadow.** A card floats because it is lighter than the page behind it.

- Base background is near-black but **never literal `#000`** — sits at L 0.10–0.14. Pure black kills all subsequent elevation steps and reads as a void.
- Each surface tier above base steps L up roughly **+0.03 to +0.05** (about +4–8% perceived). Three tiers is plenty: base → surface → raised.
- Keep chroma low and tinted toward the brand hue, same as light mode.

```css
[data-theme="dark"] {
  --bg:      oklch(0.13 0.008 H);  /* page — near-black, not #000 */
  --surface: oklch(0.17 0.010 H);  /* cards, panels: +0.04 L */
  --raised:  oklch(0.21 0.012 H);  /* popovers, menus, hover: +0.04 L again */
}
```

Shadows in dark mode, if used at all, are for *separation cues only* (a faint `rgba(0,0,0,0.4)` under a sticky header), never for elevation. The lightness step is the elevation.

## Rule 2 — Hairlines become low-alpha WHITE

The light-mode hairline ladder is dark ink at low alpha. In dark mode it flips to **white at low alpha** — same three-rung ladder, inverted source color. This mirrors the existing 0.06/0.10/0.16 hairline rule; do not invent new values.

```css
[data-theme="dark"] {
  --hairline:        rgba(255,255,255,0.06);  /* default dividers, card edges */
  --hairline-strong: rgba(255,255,255,0.10);  /* inputs, interactive borders */
  --hairline-bold:   rgba(255,255,255,0.16);  /* focus, selected, emphasis */
}
```

Verified on Vercel's Geist system: `--border-default: rgba(255,255,255,0.08)`, `--border-strong: rgba(255,255,255,0.15)`. White-alpha hairlines sit ON the surface and pick up its lightness, so they stay coherent across every tier automatically — a fixed dark-gray hex border does not. Never use a solid gray hex (`#333`, `#2a2a2a`) as a dark-mode border; it disconnects from the surface underneath it.

## Rule 3 — Accent chroma DROPS, lightness RISES

A brand accent tuned for white paper will either vibrate or disappear on near-black. Retune it. This is the **on-dark accent variant** you already declare in DESIGN.md (Color System) — this rule defines how to derive it.

- **Lower chroma by ~15–30%.** Saturated color on near-black is the neon-glow AI tell. Pull it back.
- **Raise lightness** so it clears the dark surface and passes AA on it.

```css
:root            { --accent: oklch(0.62 0.16 H); }  /* on light paper */
[data-theme="dark"] { --accent: oklch(0.70 0.12 H); }  /* L up, C down */
```

Guardrails (these are hard bans, not suggestions):
- Chroma must DROP, never rise. If your dark accent is *more* saturated than the light one, it's wrong.
- **No glow.** No `box-shadow` halo, no `filter: drop-shadow` bloom, no glowing text on the accent. A glowing accent is a 2025 AI tell, not premium.
- **One accent only.** Dark mode does not earn you a second color. The ACCENT VISIBILITY rule still applies: the accent must be distinguishable from the text at arm's length — and on near-black, a desaturated mid-gray-blue fails that test even harder than it does on white.

## Rule 4 — Tokens resolve per theme

Author every color as a semantic token that resolves per theme — never hard-code a hex inside a component for one mode. This reinforces the neutral CSS-variable naming rule (`--bg`/`--surface`/`--border`/`--text`/`--accent`, never `--paper`/`--night`).

Two ways, both acceptable:

```css
/* A. CSS-native — preferred when you can require modern browsers */
:root {
  color-scheme: light dark;
  --bg:     light-dark(oklch(0.98 0.004 H), oklch(0.13 0.008 H));
  --surface:light-dark(oklch(1.00 0    H), oklch(0.17 0.010 H));
  --border: light-dark(rgba(0,0,0,0.08),   rgba(255,255,255,0.08));
  --text:   light-dark(oklch(0.18 0.01 H), oklch(0.96 0.01 H));
  --accent: light-dark(oklch(0.62 0.16 H), oklch(0.70 0.12 H));
}

/* B. Attribute-scoped — when you need an explicit toggle or older support */
:root            { --bg: oklch(0.98 0.004 H); /* …light values… */ }
[data-theme="dark"]{ --bg: oklch(0.13 0.008 H); /* …dark values… */ }
```

Text in dark mode uses the existing ink tiers (primary / secondary / tertiary) — already defined via lightness in the Color System. Tier them with high-L near-whites at low chroma; transparent-white or near-white reads softer and more premium than literal `#fff` for body. Do not introduce a new gray-hex ladder for dark text.

## Guardrails — so dark mode doesn't become its own AI tell

- **AA contrast is mandatory.** Run the same audit rubric as light mode on every text/surface pair, including accent-on-surface. Re-derive any pair that fails — do not nudge it 1% and move on.
- **The "dark sites need a light section" rule still applies** (SKILL.md). A fully dark page with zero light relief is flat. Include at least one light-background section, or one genuinely lighter raised surface that carries weight.
- **Near-black, never `#000`.** Pure black is the void-look tell.
- **No neon, no glow, one accent.** Repeated because it's the most common way premium dark mode collapses into generic-dark.

## Theme toggle — optional, demoted on purpose

A system/light/dark switcher is itself a SaaS-templated cliché. **Do not add one by default.** Pick the one theme the scene sentence demands and ship it well. If — and only if — a toggle is explicitly requested: max 3 states (system / light / dark), persist the choice, and apply it pre-paint (an inline head script that sets `data-theme` before first paint) to avoid the flash. That is implementation detail, not design taste; it earns no further space here.

---

## Film grain (banding-killer) — use with care

Film grain carves out a single, tightly bounded exception to the gradient/mesh ban — and immediately fences it so the exception can't be abused. The existing gradient and decorative-mesh bans (anti-patterns #1, #14) are NOT relaxed; this is enforced as anti-pattern #55.

> **Visible film grain (anti-pattern #55).** A faint SVG `feTurbulence` noise layer over a SOLID dark panel or solid brand-color block is permitted ONLY to kill banding and add tactile depth — felt, never seen. It becomes an AI tell the moment it is: above ~0.02-0.03 opacity, applied globally to every section, or used to smuggle a banned gradient/mesh back onto the page. Texture is subliminal, on named solid surfaces only.

**If you use grain, the rules are:**
- A single fixed `<svg>` `feTurbulence` layer, `position: fixed; inset: 0; pointer-events: none;`.
- **Opacity ceiling 0.02** (felt, not seen). If you can consciously *see* grain, it's a filter gimmick — turn it down.
- Pinned to specific named surfaces (the dark hero, one brand-color block), **never a global all-section overlay**.
- Mandatory fallback: drop it under `prefers-reduced-transparency` AND `prefers-reduced-motion`.
- It is a TEXTURE on an existing solid surface. It is NOT a license for the banned decorative purple-blue mesh or any gradient. The ban stands.

```css
.grain {
  position: fixed; inset: 0; z-index: 1;
  pointer-events: none; opacity: 0.02;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='2'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
}
@media (prefers-reduced-transparency: reduce), (prefers-reduced-motion: reduce) {
  .grain { display: none; }
}
```
