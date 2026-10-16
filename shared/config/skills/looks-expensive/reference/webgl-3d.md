# WebGL and 3D

This reference is 80% restraint and 20% technique. Read it in that order. The value here is the discipline and the fallback contract — not the shader. If you take the appendix and skip the gate, you will ship an LCP-tanking gimmick and out yourself as AI.

## The Default Is NO

For almost every brief, the correct amount of WebGL and 3D is zero. A tasteful single 3D moment or an FBM-noise shader gradient is the recognizable high-ceiling premium look for a handful of categories — but the thing that separates premium from gimmick is the restraint and the fallback discipline, not the effect. Most premium sites you admire (Aman, Aesop, Pentagram, Mercury, most of Linear) ship NO WebGL at all. The ceiling for most briefs is no WebGL.

Do not reach for this reference because a page feels plain. A plain page is fixed with typography, whitespace, and one strong photo — not a canvas.

## Gate First (hard gate — answer before writing any canvas)

WebGL/3D is permitted ONLY when ALL of these are true:

1. **Category fits.** SaaS, dev tools, infrastructure, or fintech — and specifically the HERO of such a product. NEVER on services, hospitality, food/bev, fashion, real estate, agency, portfolio, or editorial briefs. Those are photography-first; a canvas there is an instant tell.
2. **The brief explicitly wants a high-ceiling moment.** The positioning brief (Phase 1) or the client asked for something technically impressive. You do not add this on your own initiative.
3. **It passes the single-question test:** *Does this help the user FEEL or understand something true about the product, or does it just look impressive?* If the honest answer is "just looks impressive" — cut it. A data product whose gradient evokes flowing computation: maybe. A todo app with a rotating crystal: no.

If any one of these is false, the answer is no WebGL. Move on.

## The Hard Cap

- **Max ONE WebGL element on the entire page.** Not one per section — one per page. Two canvases is automatically wrong.
- It must be **subordinate to content.** It sits behind or beside the headline and CTA; it never IS the hero. The user reads the value proposition first; the effect is atmosphere.
- It is the hero, or it is nowhere. No decorative WebGL behind arbitrary mid-page sections.

## The Fallback Contract (this is the real deliverable)

If you ship a canvas, you ship ALL of this. No partial credit. Every rule below is mandatory.

1. **Capability gate before init.** Feature-detect WebGL2 (or WebGPU). If unsupported, low-power, or `prefers-reduced-motion`, the canvas is never created — the poster stays.
2. **The poster is a real `<img>`.** A static, high-resolution still of the effect at a good frame, in the markup as `<img>`. NEVER a CSS `background-image`. NEVER painted by the canvas. It is the element the user sees first and the element that counts as LCP.
3. **Poster is preloaded, never lazy.** `fetchpriority="high"` on the poster `<img>` (and a matching `<link rel="preload" as="image" fetchpriority="high">`). NEVER `loading="lazy"` on the LCP element — that delays LCP and is a known anti-pattern (Addy Osmani / web.dev Fetch Priority / MDN "Fix image LCP"). The canvas must never block LCP.
4. **Lazy-init the canvas after first paint.** Create and start the WebGL context only after the page has painted (e.g. `requestIdleCallback` or a `load`-deferred init), then crossfade the live canvas over the poster. First paint shows the poster instantly; the canvas upgrades it.
5. **Reduced motion freezes to the poster.** `prefers-reduced-motion: reduce` -> do not animate, do not init; the poster is the final state. Non-negotiable, same as every other animation in this skill.
6. **Mobile ships the poster, not the canvas.** Phones get the static `<img>`. The canvas is a desktop-only upgrade. Touch devices never run the shader.
7. **WebGPU -> WebGL2 auto-fallback.** If you target WebGPU, fall back to WebGL2 automatically when unavailable; if neither, the poster.
8. **Animated gradients use `speed < 0.2`.** Any animated shader gradient must drift, not pulse. A fast, obvious loop reads as a screensaver. Below 0.2 it reads as expensive ambient motion.

Minimal shape:

```html
<!-- in <head> -->
<link rel="preload" as="image" href="/hero-poster.webp" fetchpriority="high">

<!-- in hero -->
<div class="hero-visual">
  <img src="/hero-poster.webp" alt="" fetchpriority="high"
       width="2400" height="1200" class="hero-poster">
  <canvas class="hero-canvas" aria-hidden="true"></canvas>
</div>
```

```js
const mq = matchMedia('(prefers-reduced-motion: reduce)');
const isMobile = matchMedia('(max-width: 768px)').matches;
const gl = !isMobile && !mq.matches && supportsWebGL2(); // your capability test
if (gl) {
  // init only AFTER first paint, then crossfade canvas over poster
  requestIdleCallback(() => initGradient({ speed: 0.15 /* < 0.2 */ }));
}
// if gl is false, the poster <img> is the final, LCP-counting state
```

If you cannot commit to every line above, do not ship the canvas. Ship the poster as a plain hero image — it will look more expensive than a janky canvas every time.

## Reconcile With Existing Rules (do not create a new tell)

This reference does **NOT** override anti-pattern #14 ("decorative gradient mesh backgrounds with no purpose") or the Design Law "no gradients unless user asks." An animated shader gradient is allowed ONLY as the gated, branded, single hero moment defined above. It is NEVER decorative wallpaper behind arbitrary sections. The moment a shader gradient appears behind a mid-page features block "to look techy," it has become exactly the AI tell #14 bans. Same effect, opposite verdict — the difference is the gate.

## Anti-Patterns (specific to this surface)

- **Connect-the-dots / floating-particle network background.** Animated dots joined by thin lines reacting to the cursor. This is the canonical "we are a tech company" stock template, not a premium signal. It is tired, generic, and instantly dates a page. Banned. (Added to reference/anti-patterns.md as rule 55.)
- **The canvas as LCP.** If the largest contentful paint is your `<canvas>` or a CSS-painted gradient, you have failed the contract. The poster `<img>` is LCP.
- **Background-image poster.** A poster set in CSS does not get fetch priority and is not a real image element. Use `<img>`.
- **Two effects.** A shader hero AND a 3D object AND particles. One element, total.
- **Spinning logo / rotating crystal with no meaning.** Decoration failing the single-question test.

## Appendix: Technique (only after the gate passes)

Demoted on purpose. These are references, not defaults.

**The Stripe-style shader gradient.** An FBM/Simplex-noise mesh gradient rendered in a tiny (~10kb) self-hosted WebGL helper (the "minigl"/"gradient" technique; well documented via bram.us, the jordienr gist, and exzenter/gradient-stripe). Brand colors as the gradient stops, `speed < 0.2`, full fallback contract above. Prefer a self-hosted ~10kb minigl or a hand-written GLSL shader you control.

**Library guardrail.** `@paper-design/shaders` (shaders.paper.design) exists and is good, but it ships under **PolyForm Shield, not MIT** — it is NOT a permissive drop-in default and must not be presented to a client as one. If you reach for a library, flag the license. Default to self-hosted minigl or a hand-written shader.

**One restrained 3D object** (the Resend low-poly iridescent rotating object pattern): a single Three.js mesh with a normal-vector GLSL iridescence shader, subordinate to the headline, slow rotation, poster fallback. One object. Not a scene.

Reduced-motion, the capability gate, the preloaded `<img>` poster, lazy-init after paint, and the mobile poster apply to every technique above without exception.
