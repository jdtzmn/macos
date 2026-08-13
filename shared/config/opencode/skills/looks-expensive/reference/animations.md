# Animation System

## Less Is More

Required counter animations on every stat section, plus mandatory 3+ Essential animation types per page, both produce the same animated SaaS template. The rebalanced rule:

- Counter animations are NOT mandatory. They're appropriate on data/analytics products. They're a tell on agency sites, hospitality, services, and editorial brands. Pick consciously.
- Variety still matters — fade-up on every element is the lazy answer.
- The right number of animations is "as few as the design needs." A quiet typographic page with one custom keyframe accent can be more expensive-feeling than a page with five animation types.

The rule: ANY 2+ animation types, where one of them MUST be either a domain-specific keyframe (something that wouldn't appear on a different brand) OR a measurable typographic accent (text-reveal, accent underline draw, marquee). Just fade-up plus hover lift doesn't pass.

## Three Tiers

### Essential (Minimum 2 of these 5 required — fade-up alone does NOT pass)

**1. Button Hover: Lift + Shadow Expansion**
```css
button {
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
  transition: all 200ms cubic-bezier(0.34, 1.56, 0.64, 1);
}
button:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(0,0,0,0.1);
}
button:active {
  transform: translateY(0) scale(0.98);
}
```
Duration: 200-300ms. Easing: bouncy cubic-bezier. Movement: 2-4px translateY, never more.

**2. Scroll Entrance: Fade Up**
Elements fade in and slide up 20-30px as they enter viewport.
- Duration: 600ms ease-out
- Trigger: when element is 70% in viewport
- Implementation: IntersectionObserver + CSS classes or Framer Motion whileInView
- Apply to: headings, paragraphs, cards, images

**3. Staggered Reveal: Sequential Entry**
List items, cards, features enter one after another.
- Per-item duration: 300-400ms
- Stagger delay: 50-100ms between items
- Direction: fade up from below
- Implementation: CSS animation-delay or Framer Motion staggerChildren

**4. Counter Animation: Number Increment**
Stats count up from 0 to final value.
- Duration: 2000ms with ease-out (slows at end)
- Trigger: once, when 50% in viewport
- Integer-only display
- Implementation: JS with IntersectionObserver or GSAP

**5. Smooth State Transitions**
All interactive elements transition smoothly between states.
- Duration: 150-200ms
- Properties: color, background-color, border-color, box-shadow, transform
- Easing: ease-out
- Apply to: links, buttons, inputs, cards

### Elevated (Good to Great)

**6. Parallax Depth**
Background and foreground move at different scroll speeds.
- Background: 30% scroll speed. Foreground: 100%.
- Max 3 layers. Max 20% viewport height movement.
- DISABLE on mobile (touch parallax is janky).
- Implementation: GSAP ScrollTrigger or CSS scroll-driven animations

**7. Clip-Path Reveal**
Images or sections revealed by animating CSS clip-path.
- Duration: 600-1000ms ease-out
- Shape: circle expanding from center, or polygon wiping diagonally
- Combine with fade for layered effect
- Implementation: CSS animations on clip-path property

**8. Direction-Aware Hover**
Hover animation direction follows cursor entry direction.
- Duration: 300-400ms elastic easing
- Implementation: JS calculating mouse entry point + CSS animation
- Creates feeling of responsive, alive interface

**9. Scroll Progress Bar**
Bar fills as user scrolls down page.
- Position: top of viewport, 2-3px height
- Color: accent color at 60% opacity
- Implementation: CSS scroll-driven animation or JS scroll event

### Advanced (Wow Moments)

**10. Character-by-Character Text Reveal**
Headline text appears letter by letter.
- 20-30ms per character (500-1000ms total for 20-30 chars)
- Only on 1-3 lines max
- Implementation: JS splitting text into spans + staggered animation

**11. Viewport Pinning** → assembled pattern moved to **section 13, Pinned-Figure Narration** below. The bare `pin: true` primitive is not enough on its own; use the documented pattern with step-sync, caps, and fallbacks.

**12. Magnetic Cursor**
Buttons appear to pull toward cursor when nearby.
- Range: 100-150px from element center
- Spring-like physics, 200-400ms follow
- DISABLE on touch devices
- Implementation: JS mouse tracking + requestAnimationFrame

## Variety Requirement

Every page MUST implement at least 2 different animation types, AND at least one of them must be domain-specific or typographic — not a generic IntersectionObserver fade-up.

Domain-specific keyframe ideas:
- Pulsing dots for real-time data
- Waveform bars for audio products
- Route lines drawing in for logistics
- Ripple expanding for water/clean products
- Circuit nodes pulsing for infrastructure
- Hand-stitch line drawing for craft brands
- Compass-needle pulse for navigation/discovery brands
- Frequency-response trace for audio gear
- A marquee of specs for a hardware product

Typographic accent ideas:
- Headline character-by-character reveal (use sparingly, only on hero)
- Accent underline drawing in beneath a key word
- Number that animates from a meaningful start (not 0 — e.g., a stat showing "from 18 to 1.4 sessions" counting down)

The same IntersectionObserver + translateY(24px) + cubic-bezier(0.16, 1, 0.3, 1) appearing on every element is a template fingerprint. Vary distances (16px for small, 32px for large), vary timing (400ms for cards, 800ms for hero), and vary easing per element type.

## Counter Animation: Use Consciously

Counter animations on stats are a SaaS marketing reflex. They're NOT required and they're often wrong.

**Use a counter when:**
- The product is about measurable outcomes and the number IS the story
- A single hero stat anchors the page (counting up makes the moment land)
- The product itself shows live counting (analytics, monitoring, billing dashboards)

**Skip the counter when:**
- The site is editorial, agency, hospitality, food, fashion, real estate, or any non-SaaS brand
- The stat is a credibility signal (e.g., "12 years in business") — counters cheapen these
- You have a 4-column stat strip (fix the strip first — see reference/non-card-patterns.md Pattern 5/6)

## Global Rules

- Custom easing on everything. Never the bare keyword `linear`, the default `ease`, or `ease-in-out`. The CSS `linear()` **function** (a multi-point spring/bounce approximation) IS permitted — it is not the banned keyword.
- **Spring carve-out (tool → use-case, get this right):** one-shot, non-interruptible motion (entrances, scroll fades, dropdown open) uses `cubic-bezier()` OR `linear()`. Motion the user can physically interrupt or grab — drag-release, a toggle thumb re-grabbed mid-travel, a menu re-triggered before it settles — uses a **JS spring** (mass / stiffness / damping) ONLY, because `linear()` cannot carry velocity through an interruption. Do not use `linear()` for drag.
- **No overshoot by default.** Springs are critically- or over-damped (zero visible bounce) everywhere by default. Overshoot/bounce is allowed ONLY on explicitly playful or marketing surfaces — never on productivity, SaaS, fintech, or dashboard UI. Hard line.
- A well-tuned `cubic-bezier()` is not a defect. Do not convert existing motion to springs without an interruptibility or drag reason. Springs are reserved for motion the user can grab. (Exemplars: Emil Kowalski's Sonner/Vaul; Linear's menus. Josh W. Comeau, "Springs and Bounces in Native CSS," for the `linear()` technique.)
- Prefer a single shallow `:has()` for relational state over JS toggles where possible — see reference/anti-patterns.md (Interaction Anti-Patterns note); never chained/nested.
- GPU-safe: ONLY animate `transform` and `opacity`. Never top/left/width/height.
- `backdrop-blur` only on fixed/sticky elements. Never scrolling content.
- `prefers-reduced-motion`: suppress ALL animations. Non-negotiable.
- `will-change`: apply sparingly, only on elements actively animating. Remove after.
- Mobile: disable parallax, magnetic cursor, and heavy scroll effects. Keep fade-in and stagger.
- Performance budget: if animation causes frame drops below 50fps, simplify or remove it.

## Timing Reference

| Context | Duration | Easing |
|---------|----------|--------|
| Hover state | 150-200ms | cubic-bezier(0.34, 1.56, 0.64, 1) |
| Click/active | 100ms | ease-out |
| Scroll entrance | 600-800ms | cubic-bezier(0.16, 1, 0.3, 1) |
| Stagger delay | 50-100ms | (per item) |
| Counter | 2000ms | ease-out |
| Parallax | tied to scroll | linear (scroll-driven) |
| Page transition | 400-600ms | cubic-bezier(0.32, 0.72, 0, 1) |

## 13. Pinned-Figure Narration (Advanced)

A single visual stage stays put while step copy scrolls past it; each step mutates that one visual — state swap, highlight, or zoom. This is the premium SaaS / editorial storytelling device (NYT, Pudding.cool, Bloomberg graphics; Scrollama and Scrolleo are the IntersectionObserver libraries built for it). Use it when one evolving visual genuinely beats N static ones — a workflow, a before/after, a build-up. Not before.

**Division of labor — non-negotiable:**
- **CSS owns the pin.** `position: sticky; top: <header-offset>` on the visual stage. Nothing else pins it.
- **JS / IntersectionObserver owns ONLY the step triggers** — it swaps the visual's state as each step crosses a threshold. It never touches scroll speed or direction. No scroll-jacking. (See anti-pattern #26: no page-level horizontal scroll; respect the 50fps budget.)

```html
<section class="pinned-narration">
  <div class="stage"><!-- sticky visual: img/canvas/svg --></div>
  <ol class="steps">
    <li data-step="0">Capture the lead.</li>
    <li data-step="1">Score it automatically.</li>
    <li data-step="2">Route to the right rep.</li>
  </ol>
</section>
```
```css
.pinned-narration { display: grid; grid-template-columns: 1fr 1fr; gap: 4rem; }
.stage { position: sticky; top: 6rem; align-self: start; height: 70vh; }
@media (max-width: 768px) { /* collapse: no pin, plain stacked list */
  .pinned-narration { grid-template-columns: 1fr; }
  .stage { position: static; height: auto; }
}
@media (prefers-reduced-motion: reduce) { /* render every step-state statically, scrollable */
  .stage { position: static; height: auto; }
  .stage [data-state] { display: block; }
}
```
```js
const io = new IntersectionObserver((entries) => {
  entries.forEach(e => {
    if (e.isIntersecting) setStageState(e.target.dataset.step); // swap/highlight/zoom only
  });
}, { threshold: 0.6 });
document.querySelectorAll('.steps li').forEach(li => io.observe(li));
```

**Hard caps:**
- 3–5 steps. One narrative beat per step.
- Pin span ≤ ~1.5 viewports of scroll.
- At most ONE pinned-narration section per page.
- Mobile collapses to a plain stacked list (no pin). `prefers-reduced-motion` renders all step states statically, scrollable.

**Anti-pattern:** Pinned-figure narration on a page with no real sequential story to tell is a tell. Only use it when the content is genuinely a step sequence. Default to the numbered timeline or zigzag (existing section-layout patterns) FIRST; reach for pinning only when a single evolving visual beats several static ones.

**Escape hatch — scroll-scrubbed canvas image sequence (gated, not recommended):** the Apple AirPods-style technique (~65 preloaded PNG frames drawn to a sticky `<canvas>`, `scrollTop` → frame index via `requestAnimationFrame`, readable forward and backward) is a default-OFF escape hatch. Use it only if the user explicitly asks for an Apple-style product reveal AND can supply or generate a real frame sequence. Caveat loudly: the AirPods reference is ~15MB of PNGs, the technique is now itself a recognizable cliché, and it fights this skill's photography-first + performance-budget philosophy. Never a default.

## 14. Page Transitions: View Transitions API (Advanced)

Hard white-flash jumps between a landing page and its sub-pages are a quiet "cheap template" tell. The View Transitions API cures it for nearly free, with graceful degradation. This backs the existing "Page transition" row in the Timing Reference — reuse those numbers (400–600ms, the existing `cubic-bezier(0.32, 0.72, 0, 1)`); do not invent new timings.

**Default (the 90% case) — a simple cross-fade, no JS:**
```css
@view-transition { navigation: auto; }
::view-transition-old(root),
::view-transition-new(root) { animation-duration: 500ms; }
@media (prefers-reduced-motion: reduce) {
  ::view-transition-group(*) { animation: none; } /* instant cut */
}
```

**Named morph (the exception — heavily gated):** a shared element morphs across the route, e.g. a gallery thumbnail becoming the detail hero, or a persistent nav/logo.
```css
.thumb-active { view-transition-name: hero-media; } /* same name on both pages, unique */
```
Rules, baked in so this cannot become a new tell:
1. At most ONE morphing object per transition.
2. Never morph unrelated or merely-similar elements — if they are not literally the same object, fade, don't morph.
3. Names must be unique per page or the transition aborts.
4. `prefers-reduced-motion` → instant cut, no animation.
5. Feature-detect — `@supports (view-transition-name: x)` / `if (document.startViewTransition)` — with a plain normal-navigation fallback. Never block navigation on it.

**SPA:** wrap client-route state changes in `document.startViewTransition(() => updateDOM())`; FLIP is the fallback. Do not expand into a framework tutorial.

Exemplars: Cyd Stumpel Portfolio 2025 (Awwwards SOTD, built on View Transitions + scroll-driven animation, with shared transitions into work-detail pages); `vercel-labs/react-view-transitions-demo` for the thumbnail→detail morph; Chrome for Developers for the authoritative API reference. (If BIG is cited, it is a bespoke tile-expansion interaction, not a View Transitions implementation.)

This is OPTIONAL — like parallax or magnetic cursor. It is never part of the required animation count.

## 15. Spring Physics for Interruptible Motion (Advanced)

Covered as a rule in **Global Rules** above — read it there. The short version: JS springs (mass/stiffness/damping) for motion the user can grab or interrupt; `cubic-bezier()`/`linear()` for one-shot reveals; no overshoot on productivity UI, ever. Springs are a permission, not a requirement.

## 16. Cursor-Following Spotlight on Card Grids (Elevated)

Distinct from the magnetic cursor (#12, which pulls a button toward the pointer). This lights the *border* of the hovered card with a soft radial glow that tracks the pointer via `--mx`/`--my` custom properties — the subtle Linear / Vercel / Raycast borrow. Appropriate for dark-mode SaaS, devtools, and fintech feature grids.

```css
.card { position: relative; background: #0d0d10; border: 1px solid rgba(255,255,255,0.08); }
.card::before {
  content: ""; position: absolute; inset: 0; border-radius: inherit; pointer-events: none;
  opacity: 0; transition: opacity 200ms ease-out;
  background: radial-gradient(180px circle at var(--mx) var(--my),
              rgba(var(--accent-rgb), 0.12), transparent 60%);
}
.card:hover::before { opacity: 1; }
@media (any-hover: hover) and (pointer: fine) {
  /* one rAF-throttled handler sets --mx/--my via translate3d-style writes */
}
@media (prefers-reduced-motion: reduce) { .card::before { transition: none; } }
```
```js
grid.addEventListener('pointermove', e => {
  const r = card.getBoundingClientRect();
  card.style.setProperty('--mx', `${e.clientX - r.left}px`);
  card.style.setProperty('--my', `${e.clientY - r.top}px`);
}); // throttle to a single requestAnimationFrame
```

**Guardrails — this is the single most-cloned SaaS effect of the era; treat it like counter animation (a deliberate choice, not a reflex):**
- Opt-in, not default. A generic rainbow/purple glow on every card is itself a template fingerprint. The glow color MUST be the project accent or a single hue derived from ink — never multi-stop neon.
- Subtlety bound: alpha ~0.06–0.16 (match existing hairline alphas), tight radius, accent-tinted only, **dark surfaces only** — it reads cheap on paper/cream. Do not stack it with other heavy effects on the same section.
- Hard gates: `@media (any-hover: hover) and (pointer: fine)`; single rAF-throttled `translate3d`-style writes; `prefers-reduced-motion` drops the transition; never hide the OS cursor; the `:focus-visible` ring is unaffected.

Replacement / `mix-blend-mode: difference` custom cursors (Cuberto, Active Theory style) are a high-risk, agency-only option that is OFF by default — they contradict the subtraction ethos and the quiet/editorial North Stars (Pentagram, Studio Sutherland), and are an accessibility hazard. Mention only if explicitly requested.
