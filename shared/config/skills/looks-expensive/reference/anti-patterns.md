# Anti-Pattern Detection Rules

73 deterministic checks. Run before every output.

## Visual Anti-Patterns

1. **Purple-to-blue gradient background.** The #1 AI slop tell. If a gradient exists and the user didn't ask for it, remove it.
2. **Nested card-in-card.** Card containing another card with its own border/shadow. Flatten the hierarchy.
3. **Gray text on colored background.** Low-contrast text that fails WCAG. Check every text/bg combo.
4. **Centered hero with glowing numbers.** "10M+ users" with a glow effect. The generic SaaS starter pack.
5. **Three equal cards in a row with colored top borders.** The Bootstrap feature section. Use bento, asymmetric, or zigzag instead.
6. **Shadowed edge-to-edge navbar.** A solid bar glued to the viewport top with a drop-shadow from page load. Use the scroll-state header (transparent-over-hero → hairline + backdrop-blur + modest shrink past a scroll threshold) per reference/navigation.md — NOT a detached floating pill (a floating pill is itself a one-click template block, allowed only on genuinely minimal sites). EXCEPTION: a state-aware sticky buy-bar that appears only after the hero CTA scrolls out of view is a sanctioned buy affordance, not chrome (reference/product-ui.md §2d/§3a).
7. **Rainbow gradient text.** Background-clip text with a multi-color gradient. Remove.
8. **Oversaturated accent colors.** Neon-bright blues, purples, greens that vibrate against backgrounds.
9. **Heavy drop shadows.** `shadow-md`, `shadow-lg`, `rgba(0,0,0,0.3)+`. Use hairline elevation only.
10. **1px solid gray borders everywhere.** The "I didn't design this" tell. Use rgba opacity hairlines.
11. **Mac window chrome (red/yellow/green dots)** on ANY element. Code blocks, dashboards, mockups — no exceptions. Use a thin accent line or subtle border instead.
12. **Stock photo imagery.** Generic business people, handshakes, abstract office scenes.
13. **Symmetrical 3-column Bootstrap grid** with no whitespace variation, no size variation, identical cards.
14. **Decorative gradient mesh backgrounds** with no purpose beyond "looking techy."

## Typography Anti-Patterns

15. **More than 4 type sizes on a single surface.** Generic dashboards use 7-9. Premium uses 3-4.
16. **Italic text used for emphasis** when the user didn't request italics.
17. **Monospace text outside of code/data** contexts.
18. **All-caps body text.** Eyebrows can be uppercase. Body never.
19. **Justified text.** Causes uneven word spacing. Always left-align body.
20. **Display fonts in UI labels or buttons.** Buttons use body weight, not display weight.

## Layout Anti-Patterns

21. **Every section same background color.** Sections must be visually distinct.
22. **Section numbering as decoration.** "01.", "02.", "Section 1". Labels should be logical.
23. **Fake KPI cards** when there's no meaningful data. If you have 3 users, don't show stat cards.
24. **Decorative empty-state illustrations.** Use editorial copy instead.
25. **`h-screen` instead of `min-h-[100dvh]`.** iOS Safari viewport bug.
26. **Horizontal scroll on page-level container.** Never. At any breakpoint.
27. **Body text exceeding 75 characters per line** without max-width constraint.

## Interaction Anti-Patterns

28. **Bare `linear` keyword or default `ease-in-out` transitions.** Use a custom `cubic-bezier()`. NOTE: this bans the bare keyword `linear` and the default `ease`/`ease-in-out` — NOT the CSS `linear()` function, which is a permitted multi-point spring/bounce approximation (see reference/animations.md Global Rules).
29. **Instant state changes.** No transition between states = no polish.
30. **Mixed icon families.** Lucide in nav, Heroicons in features, Material in footer.
31. **Decorative motion without state purpose.** Animation must communicate something. ALLOWED ALTERNATIVE: for relational hover/active state, prefer a single shallow `:has()` selector over a JS toggle (e.g. a card grid that dims the siblings of the hovered card) — JS-free and GPU-cheap. Keep it shallow; never chained or nested. See reference/modern-css.md.
32. **Placeholder-only form labels.** Labels must be visible, always.
33. **"Click here" or "Learn more" link text** without surrounding context.

## Content Anti-Patterns

34. **Hyperbolic marketing language.** "Revolutionary", "game-changing", "unprecedented."
35. **Generic messaging.** Copy that could apply to any product. "We help businesses grow."
36. **"Get Started" on every CTA.** Buttons must describe the specific action.
37. **Emotionless, generic testimonial text.** Fake-sounding quotes with no specificity.

## Structural Anti-Patterns

38. **Fake bento grid.** A grid labeled `.bento-grid` where all cards are equal size with no `grid-column: span` or `grid-row: span`. If no card spans, rename the class and admit it's a regular grid — or add real spanning per reference/bento-grids.md.
39. **Same animation on every element.** If the only animation is `translateY(24px)` fade-in on scroll, you haven't met Essential tier. Add at least one more type: counter animation, staggered reveal with different timing, horizontal slide, clip-path reveal, or a domain-specific keyframe animation.
40. **Identical page skeleton.** If your page follows: centered hero → 3-card grid → 3-step process → 4-col stats → testimonial → CTA → footer — you used the default template. Rearrange, merge, or replace at least 2 sections with different patterns from reference/section-layouts.md.
41. **Gray or near-black accent color.** If the accent hex is #1-#5 range (e.g., #1B2838, #334155, #475569, #64748B, #171717), it's not an accent — it's ink. Accents must be visually distinguishable from body text at arm's length. Minimum: the accent hue should differ from the ink by at least 30 degrees on the color wheel.
42. **Gradient rectangle placeholder.** A colored gradient rectangle where a product visual should be. Use a CSS mockup from reference/css-mockups.md instead. If the product is physical, use an editorial typography treatment or a styled placeholder with label — not an anonymous gradient blob.
43. **Reused testimonial names.** Never use: Sarah Chen, Marcus T., Priya S., Maria Santos, Elena, Jordan K., Alex Rivera, Jamie, David & Laura. These names appear in AI-generated content constantly. Generate names from the product's actual target audience demographic and geography.
44. **Zero-padded decorative numbers.** "01.", "02.", "03." as section labels or step indicators. Use plain numbers (1, 2, 3) for process steps. Never zero-pad. Zero-padding is an AI design tell.
45. **All-dark site with no light section.** If the entire page is dark-themed, include at least one light-background section (white or light gray) for contrast. The difference between #0a0a0a and #1a1a1a is not visible enough to create section distinction.
46. **Mobile nav without an engineered drawer.** Hiding nav links on mobile with `display: none` and no hamburger toggle — OR a drawer that toggles `display` with no body-scroll-lock, no focus trap, and no Esc-to-close. A mobile menu is a correctness/a11y requirement: full-screen drawer, large-type links, scroll-lock, focus trap, icon-to-X morph. See reference/navigation.md.
47. **Universal 5-star testimonials.** Every testimonial at 5 stars with no variation. Real products have 4.5-4.8 star averages. Mix in a 4-star review or drop the stars entirely.

## Template-AI Tells

These are the patterns real designers identify as "this was made by AI" at a glance. Each one alone is mild; in combination they're a giveaway.

48. **Excessive bullet points.** A page where every feature, every benefit, and every detail is delivered as a bulleted list. Real editorial design uses prose, definition lists, ledgers, and tables — bullets are the lazy answer. Cap: maximum 5 total bullet points per page across all sections. If you have more, restructure into a ledger (reference/non-card-patterns.md Pattern 1) or a definition list (Pattern 2).
49. **Eyebrow-pill on every section.** Small uppercase pill labels ("FEATURES", "HOW IT WORKS", "PRICING") above every section heading is the most common AI design tell of 2025. Cap: maximum 1 eyebrow pill per page, ideally zero. The section heading itself should establish what the section is.
50. **Same card chrome on every section.** Sections where every block of content is wrapped in `border-radius: 16px; border: 1px solid rgba(0,0,0,0.06); padding: 32px`. The single-stroke, single-corner-radius, identical-padding card is the visual signature of AI. Cap: maximum 2 sections per page using the default card pattern. Other sections must use ledgers, rules, tables, prose, or no containment at all (see reference/non-card-patterns.md).
51. **Generic 3-tier pricing table.** "Free / Pro / Enterprise" as three identical cards in a row with checkmark lists. Almost every AI-generated SaaS site has this exact pattern. Use a real HTML table (reference/non-card-patterns.md Pattern 7), inline pricing for services (Pattern 8), or a single-plan layout when the product has one plan. Never default to three identical pricing cards.
52. **Generic 4-column stat strip with counters.** Four large numbers in a row, each counting up on scroll, each with a small label below. The single most overused SaaS section. Replace with an inline-stat narrative (reference/non-card-patterns.md Pattern 5), a single hero stat (Pattern 6), or skip stats entirely. Counter animations are NOT mandatory — they signal "I am a generic SaaS landing page."
53. **CSS gradient blob in place of imagery.** Sections requiring photography that use a gradient rectangle, a CSS pattern, or an abstract shape instead of an `<img>` tag. For any product where photography is mandatory (hospitality, food, fashion, real estate, services, agencies), use Picsum URLs per reference/imagery.md. A gradient blob where a hero photo should be is the loudest possible AI tell.
54. **Identical container chrome across the entire page.** Every section uses the same background color or the same card style with the same border. Real designs vary containment per section — some sections are full-bleed photos, some are typography-only, some are tables, some are cards. Variance is the design. If your page has 7 sections and 6 use the same container pattern, it's wrong.

## Additional Tells (55-70)

Same usage as every rule above — check every output against them.

### Visual / texture
55. **Visible film grain.** A faint SVG `feTurbulence` noise layer over a SOLID dark panel or solid brand-color block is permitted ONLY to kill banding and add tactile depth — felt, never seen. It becomes an AI tell the moment it is above ~0.02-0.03 opacity, applied globally to every section, or used to smuggle a banned gradient/mesh back onto the page. Texture is subliminal, on named solid surfaces only. See reference/dark-mode.md.
56. **Connect-the-dots / floating-particle network background.** Animated dots joined by thin lines reacting to the cursor. The canonical "we are a tech company" stock template, not a premium signal — tired, generic, instantly dates a page. Banned. See reference/webgl-3d.md.

### Social proof / trust
57. **Pixel-locked or boxed logo wall.** Every logo forced to identical pixel height, and/or each logo boxed in a bordered card. Normalize by OPTICAL weight (per-aspect max-height) on a borderless surface instead. See reference/section-layouts.md Pattern 16.
58. **Badge-soup trust wall.** 4+ compliance/cert seals clustered near the hero. Use 1-2 real, designed credential lockups instead. See reference/section-layouts.md Pattern 16 and the regulated-category trust signals in reference/ux-writing.md.

### Motion (the new optional patterns, done wrong)
59. **Pinned-figure narration with no real sequential story.** A scroll-pinned figure + stepped narration used where the content is not genuinely a step sequence. Default to a numbered timeline or zigzag first. See reference/animations.md §13.
60. **Morphing unrelated elements across a route.** `view-transition-name` on elements that are not literally the same object. If they are not the same object, fade — do not morph. See reference/animations.md §14.
61. **Spring overshoot on productivity UI.** Visible bounce/overshoot on SaaS/fintech/dashboard motion, or a JS spring on a non-interruptible reveal. Springs are for interruptible/drag motion only and are critically-damped by default. See reference/animations.md Global Rules.
62. **Autoplay hero video with no poster.** A hero video with no poster first-frame, that does not pause off-screen, that ignores `prefers-reduced-motion`, or that autoplays on mobile. A perf + accessibility tell. See reference/hero-patterns.md Pattern 4.

### Typography / color register
63. **Terminal cosplay (mono misuse).** Monospace on a headline, body run, paragraph, eyebrow, kicker, or any uppercase letter-spaced label — or mono used outside devtools/fintech/hardware registers, above 14px, or in more than one family. Mono is for the datum (id, version tag, timestamp, stat unit, tabular figure, code), never the decoration. A mono eyebrow is the 2026 reincarnation of the pill eyebrow.
64. **Gray-on-gray monochrome.** A page with no visible accent AND no mandatory `<img>` photography, on a SaaS/devtools/fintech/services product. Tonal monochrome is earned ONLY by luxury/editorial/hospitality pages carrying contrast through real photography and a strong type scale. Everywhere else, a buried near-ink "accent" is the gray-accent trap.
65. **Illegible variant theme.** A per-flavor/per-variant re-theme that ships any variant whose accent fails ACCENT VISIBILITY or WCAG AA, recolors whole-site chrome instead of a single product module, or animates without honoring `prefers-reduced-motion`.

### Product / commerce surfaces
66. **One-image + native dropdown PDP.** A commerce product page with a single product image and a native `<select>` for variants — the free-Shopify-theme tell. Use the image-rail gallery + real-image swatches + transforming add-to-cart. See reference/product-ui.md §2.
67. **Fake live UI / decorative keycap.** An app-window mockup with browser-chrome dots, a demo that auto-cycles through fabricated screens communicating no state, or a "⌘K" badge wired to nothing. Live UI must be honest: real states, no chrome, every shortcut badge backed by a working shortcut. See reference/product-ui.md §1, §4.
68. **Cmd-K palette on a marketing/brochure site.** A command palette overlay on a <6-page marketing or landing-only build — cargo-cult power-user signal. The palette is gated to apps/docs/data products with 8+ real destinations; the keycap badge is fine anywhere a real shortcut exists. See reference/product-ui.md §4.
69. **Empty or single-item palette groups.** Inventing "Recent / Pages / Actions" buckets, or groups with one row, to look sophisticated. Group only when 2+ real groups exist. No placeholder commands. See reference/product-ui.md §4.
70. **Shield-icon security card grid.** A trust/security section built as a grid of lock/shield icon cards with vague labels. Replace with a real compliance badge grid (named certs + attestation dates) and a sub-processor table. See reference/product-ui.md §5c.

### Decorations and contrast bugs that ship from the skill itself
71. **Decorative bar/dash beside ANY label-class element.** A `::before` or `::after` element drawing a 1×Npx (or N×1px) hairline as a flex sibling of a small label — eyebrow, kicker, section-tag, footer column heading, nav active state, breadcrumb separator, masthead category. Reads as a literal "----" beside the text — a 2026 AI tell that replaced the banned pill. Banned absolutely on label-class elements. Typography alone carries the label (size + tracking + color); no rules, no bars, no leading "—" / "–" characters, no underlines, no leading icons. Legitimate `::before`/`::after` hairline uses (NOT banned): (a) full section dividers between sections; (b) versus-column dividers in side-by-side comparison (non-card-patterns.md Pattern 4); (c) card hover glows (animations.md); (d) hero scrim gradients. See reference/ux-writing.md "If you DO use one eyebrow."
72. **Accent-filled element with near-white text on under-darkened `--accent`.** ANY element using the base `--accent` (L=0.55-0.70) as `background` with near-white text — primary buttons, badges, recommended-plan stripes, active tabs, banners, photo callouts, status pills, Add-to-Bag controls in ready state. Lands at ~3.9-4.4:1 and FAILS WCAG AA. Fix: derive `--accent-ink: oklch(L 0.10-0.18 H)` at L=0.42-0.48 (same hue as `--accent`) and use it as the `background`; keep `--accent` for links/icons/tints. Or keep the bright `--accent` fill and switch the TEXT to the dark page background (dark-on-bright passes 5:1+). See SKILL.md Color System step 5.
73. **Hover state lighter than rest state on an accent-filled element.** `--accent-hover` at HIGHER L than the rest fill — invisible until mouseover, then near-white text REDUCES in contrast. Banned: `--accent-hover` MUST be L equal-or-lower than the rest fill (whether the rest fill is `--accent` or `--accent-ink`). Applies to every accent-filled surface, not just primary buttons.

## How to Use

Before presenting any output, check against ALL 73 rules. For each violation found:
- Classify: Certain (obvious match) / Probable (likely match) / Possible (might match)
- Fix immediately if Certain or Probable
- Flag for user review if Possible
