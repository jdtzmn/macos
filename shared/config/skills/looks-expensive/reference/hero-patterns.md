# Hero Section Patterns

## Imagery Note

For hospitality, food, fashion, real estate, services, agencies, and lifestyle brands, the hero MUST include real photography. Use Picsum or Unsplash URLs per reference/imagery.md. Patterns 4 (Video Background), 9 (Full-Bleed Immersive), and 2 (Split-Column with photo) all assume real imagery.

For SaaS, dev tools, infrastructure, and B2B products, the hero may use a CSS mockup (dashboard, code block, app preview) per reference/css-mockups.md. Patterns 2 (Split-Column), 3 (Product-Focused Screenshot), and 7 (Dark Mode Tech) work with CSS mockups.

For agencies, coaching practices, and editorial brands, Pattern 10 (Minimal/Typographic) works without imagery — but only if the typography is genuinely strong.

NEVER use a gradient rectangle in the hero where a photo or mockup should go. That's the loudest AI tell on the page.

## 12 Patterns

Select based on product type, emotional temperature, and what's available (screenshot, video, illustration, or text only).

### 1. Centered Typography + CTA
Large centered headline (48-72px), short sub, primary + secondary CTA.
- Layout: centered, full-width container
- Background: solid or subtle gradient
- Best for: B2B SaaS, productivity, clear single message
- Premium feel: extreme whitespace, custom font at large scale, generous line-height

### 2. Split-Column (Text Left, Visual Right)
Two-column: headline/copy/CTA left, product screenshot or illustration right.
- Layout: 50/50 or 55/45 grid
- Background: solid on text side, visual fills other half
- Best for: products with recognizable UI, tools with clear interface
- Premium feel: real product screenshot with realistic data, subtle depth shadow

### 3. Product-Focused Screenshot
Large product UI dominates; text is minimal and secondary.
- Layout: asymmetric, image-driven
- Background: clean to let screenshot breathe
- Best for: design tools, visual products, anything where the UI sells itself
- Premium feel: 2x resolution export, real data, subtle animation or parallax on scroll

### 4. Video Background

**GATE — read before using. Video is opt-in, never the default.** Use video in the hero ONLY when (a) the product IS motion (generative/creative/video tools) or (b) the brand sells atmosphere (hospitality, luxury, real estate) AND you have genuinely cinematic footage. If a still photo (reference/imagery.md) or a CSS mockup (reference/css-mockups.md) carries the message, use that instead — a hero video on a page that does not need one is itself an AI/template tell. Max one autoplay video per page. Pick exactly one variant below; do not stack both.

#### 4a. Ambient cinematic (hospitality / luxury / real estate)
Full-bleed muted loop establishing place and mood; text overlays.
- Layout: full-bleed, headline positioned over the footage (lower-left or centered)
- Best for: hotels, resorts, restaurants, property, atmosphere-led brands
- Premium feel: real cinematic footage, seamless loop, soft motion (slow pan/zoom), legible text via a measured scrim — not a generic dark wash
- Example: Our Habitas (ourhabitas.com) — video-forward hospitality, place sells the room

Spec:
- `<video muted loop playsinline preload="metadata">`; never `controls`, never audio
- `poster` = the first frame, shown instantly and swapped for the video on load (no flash of empty box, no skeleton shimmer where the poster already reads)
- Legibility: add a scrim ONLY as much as AA contrast requires — a linear `rgba(0,0,0,.35→0)` gradient behind the text block, not a flat overlay across the whole frame
- Off-screen: `IntersectionObserver` pauses playback when the hero scrolls out, resumes on return
- Fallback to the poster still (do NOT autoplay the video) on: mobile, `prefers-reduced-motion: reduce`, and slow/data-saver connections (`navigator.connection.saveData` or `effectiveType` of `2g`/`3g`)
- Encode: 10–20s seamless loop, ≤1080p, H.264 MP4 + WebM source, target ≤5MB

```html
<section class="hero">
  <video class="hero-video" autoplay muted loop playsinline
         preload="metadata" poster="/hero-first-frame.jpg">
    <source src="/hero.webm" type="video/webm">
    <source src="/hero.mp4"  type="video/mp4">
  </video>
  <div class="hero-copy"><!-- headline + CTA --></div>
</section>
```
```css
.hero-video { position:absolute; inset:0; width:100%; height:100%; object-fit:cover; }
.hero::after { content:""; position:absolute; inset:0;
  background:linear-gradient(105deg, rgba(0,0,0,.45) 0%, rgba(0,0,0,0) 55%); }
@media (max-width:768px), (prefers-reduced-motion:reduce) {
  .hero-video { display:none; }
  .hero { background:url(/hero-first-frame.jpg) center/cover; }
}
```

#### 4b. Real product-UI loop (SaaS / dev tools / creative)
A tight screen recording of the ACTUAL interface proving something only motion can show — generation completing, a drag, a live update.
- Layout: full-bleed, split (text left, loop right), or framed in the hero panel
- Best for: products where the value IS in the motion — the still cannot make the point
- Premium feel: real UI, realistic data, one clean action — reads as a recording of the product, not a sizzle reel
- Example: Runway (runwayml.com) for generative motion; Notion / Linear / Loom for a short live-UI demo

Spec:
- Record the real UI with real-looking data (names, numbers, copy a real user would have) — NOT an abstract montage, NOT decorative b-roll, NOT a stylised/fake UI, NOT a slideshow of static screens
- 8–15s, one legible action, seamless loop; if the action cannot loop cleanly, hold the end frame 1s before the cut
- `<video muted loop playsinline preload="metadata">` + `poster` first frame; H.264 MP4 + WebM source
- `prefers-reduced-motion` and mobile fall back to the poster still, OR to the matching static CSS mockup from reference/css-mockups.md (use the mockup when the loop's payoff survives as a single frame)
- Same off-screen pause + connection downgrade as 4a; ≤1080p, target ≤5MB
- No browser chrome on the frame: no red/yellow/green window dots (anti-pattern 11). A thin accent border or subtle shadow only.

Distinct from CSS mockups: those are intentionally static. Reach for 4b ONLY when the value is literally in the motion. If a single frame tells the whole story, ship the static mockup (reference/css-mockups.md) — it is faster, lighter, and never janks.

### 5. Animated / Interactive
Headline animates on load or scroll. Kinetic typography, morphing text, particle effects.
- Layout: centered or full-width, text-dominant
- Background: solid, animated gradient, or particle field
- Best for: design-forward brands, creative agencies, premium consumer
- Premium feel: smooth easing, performance-optimized, animation serves the narrative

### 6. Asymmetric Grid
Multiple elements at different sizes and positions. Overlapping, staggered, broken grid.
- Layout: CSS grid with varied spans, intentional overlap
- Background: minimal to let layout create interest
- Best for: creative agencies, fashion, art, portfolios
- Premium feel: intentional whitespace, oversized type, unconventional image cropping

### 7. Dark Mode Tech
High-contrast dark background with bright text and glowing accent.
- Layout: centered or left-aligned
- Background: near-black (#0a0a0a to #111) with subtle glow
- Best for: developer tools, fintech, security, enterprise tech
- Premium feel: careful contrast (WCAG AA), subtle glow on buttons, no neon garish

### 8. Input Capture
Email input or form integrated directly as primary CTA.
- Layout: centered, form is the focal point
- Background: solid or gradient drawing eye to form
- Best for: waitlist, beta launch, newsletter, lead gen
- Premium feel: micro-interactions on input focus, smooth validation, brand-matched input styles

### 9. Full-Bleed Immersive
Edge-to-edge image or visual creating scale and presence.
- Layout: full-bleed, text as overlay
- Background: full-width image, video, or illustrated scene
- Best for: luxury, hospitality, architecture, enterprise
- Premium feel: cinematic photography, parallax depth, semi-transparent overlays

### 10. Minimal / Typographic
Type does everything. Oversized headline on empty background.
- Layout: centered or left-aligned, text-only
- Background: solid color or white
- Best for: confident brands, design-forward, typography as identity
- Premium feel: custom typeface at 60-120px, extreme negative space, perfect tracking

### 11. Metaphoric / Illustrated
Custom illustration represents the value prop (not literal screenshot).
- Layout: split or centered with illustration
- Background: light or gradient to let illustration pop
- Best for: consumer products, wellness, education, abstract value props
- Premium feel: custom illustration (not stock), subtle animation, brand palette

### 12. Trust Signals Integrated
Standard hero with prominent "trusted by" logos or proof below CTA.
- Layout: centered hero + horizontal logo strip below
- Background: standard
- Best for: B2B, enterprise, products needing credibility
- Premium feel: real logos properly spaced, real review snippets, subtly integrated

## Selection Logic

| Product Type | Primary Pattern | Secondary Pattern |
|-------------|----------------|-------------------|
| Developer tool | 7 (Dark Mode) | 2 (Split-Column) |
| Consumer SaaS | 1 (Centered) | 8 (Input Capture) |
| Creative tool | 5 (Animated) | 3 (Product-Focused) |
| Enterprise | 2 (Split-Column) | 12 (Trust Signals) |
| Consumer app | 2 (Split-Column) | 1 (Centered) |
| Agency/studio | 10 (Minimal) | 6 (Asymmetric) |
| E-commerce | 9 (Full-Bleed) | 2 (Split-Column) |
| Luxury/hospitality | 9 (Full-Bleed) | 4 (Video) |
| Fintech | 7 (Dark Mode) | 1 (Centered) |
| Content/media | 10 (Minimal) | 5 (Animated) |
