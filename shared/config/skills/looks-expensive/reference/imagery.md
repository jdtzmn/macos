# Imagery System

The single biggest AI design tell is the absence of real photography. CSS gradient blobs, geometric placeholders, and "abstract visuals" are how AI says "I couldn't make a photo." A real agency build uses real images.

This skill writes `<img>` tags with working photo URLs by default. The user replaces them with their own photos before shipping. The placeholders ARE real photos, not gray boxes.

## The Photography Decision (Phase 3)

For every brief, decide which category the product falls into:

| Category | Photography requirement | Examples |
|----------|------------------------|----------|
| Photography mandatory | Photos are essential — the product cannot be sold without them | Hospitality, food/bev, fashion, real estate, physical goods, agencies/portfolios, services with a human element (coaching, therapy, dental), travel, lifestyle, events |
| Photography preferred | Photos elevate the brand significantly but the product can stand on text | Construction/contractors, fitness/gyms, education, B2B with field operations |
| Photography optional | The product UI or data is the visual; photos can be added for context | SaaS, dev tools, analytics, infrastructure, fintech |
| Photography unsuitable | The product is purely digital with no physical correlate to photograph | Pure data/API products, code-only tools |

When photography is mandatory, the site MUST include `<img>` tags. The skill does NOT substitute CSS mockups or typography treatments for required photography. A hotel without photos doesn't read as luxurious — it reads as broken.

## How to Write Image URLs

This skill uses Picsum (a real photo CDN backed by Unsplash) for placeholders because:
- The URLs actually load (no 404s)
- The photos are professional-quality
- Sizes are predictable
- The seed parameter gives consistent images across rebuilds
- The user can swap to Unsplash, Pexels, or their own photos with one find-and-replace

### Source Specificity Rule

Picsum and the top-100 Unsplash photos themselves became AI tells in 2026. When using either:
- Seeds must be DESCRIPTIVE and NON-NUMERIC. `picsum.photos/seed/driftwood-workshop-morning/2400/1200` — good. `picsum.photos/seed/1234/2400/1200` — bad, and `picsum.photos/2400/1200` (no seed) is the worst because you get whatever changes that day.
- Use NON-STANDARD aspect ratios where possible. 16:9 (1600×900) and 1:1 (800×800) are the AI defaults. Try 5:3 (1500×900), 4:5 (800×1000 for portrait), 2.4:1 (2400×1000 for cinematic hero), or 3:4 (900×1200) for editorial.
- For Unsplash searches, NEVER use a one-word category keyword (`restaurant`, `dashboard`, `team`). Instead search by specific scene (`nordic-modern-restaurant-interior-evening`, `pull-request-code-review-laptop-desk`) or by photographer name if known.
- The point is commitment to specificity, not pulling a default landscape.

### Picsum format (default for placeholders)

```html
<img
  src="https://picsum.photos/seed/[descriptive-seed]/[width]/[height]"
  alt="[description of what the photo should show]"
  loading="lazy"
  width="[width]"
  height="[height]"
>
```

The seed should be descriptive — e.g., `hotel-lobby-morning`, `olive-grove-harvest`, `coworking-space-loft`. This makes it easy for the user to grep and replace each image with their real one. Use kebab-case.

### Unsplash format (when the user provides a list, or for final builds)

```html
<img
  src="https://images.unsplash.com/photo-[ID]?w=[width]&q=80&auto=format&fit=crop"
  alt="[description]"
  loading="lazy"
>
```

### Critical alt text rule

Alt text describes what the photo SHOULD SHOW for this brand, not what a generic photo at that URL contains. Example:

GOOD: `alt="The Linden's restored 1890s lobby with morning light through the south-facing windows"`
BAD: `alt="Hotel lobby"`

This gives the user instant context when they replace the image — they know what kind of photo to source.

## Photo Sizing

| Use case | Width × Height | Notes |
|----------|---------------|-------|
| Full-bleed hero | 2400 × 1200 | 2:1 ratio. `object-fit: cover` |
| Split hero (one side) | 1200 × 1400 | Slightly portrait for vertical splits |
| Product card (vertical) | 800 × 1000 | 4:5 portrait |
| Product card (square) | 800 × 800 | Catalog grids |
| Feature image | 1200 × 800 | 3:2 landscape |
| Inline editorial | 1600 × 900 | 16:9 |
| Headshot/avatar | 400 × 400 | Square crop |

Always include `width` and `height` attributes to prevent layout shift. Use `loading="lazy"` on every image except the hero.

## Layout Patterns That Need Photography

### Full-bleed hero
```html
<section class="hero hero--photo">
  <img src="https://picsum.photos/seed/[brand-context]/2400/1200" alt="..." class="hero__photo">
  <div class="hero__content"><!-- text overlay --></div>
</section>
```
Photo fills the section with a subtle gradient overlay for text legibility. Use for hospitality, fashion, travel, agencies showing work.

### Split hero
```html
<section class="hero hero--split">
  <div class="hero__text"><!-- headline + CTAs --></div>
  <img src="https://picsum.photos/seed/[brand-context]/1200/1400" alt="..." class="hero__photo">
</section>
```
Half-and-half. Photo on the right at a slight crop. Use for products, services, hospitality variants.

### Editorial gallery
```html
<section class="gallery">
  <figure><img src="..." alt="..."><figcaption>Caption</figcaption></figure>
  <figure><img src="..." alt="..."><figcaption>Caption</figcaption></figure>
  <figure><img src="..." alt="..."><figcaption>Caption</figcaption></figure>
</section>
```
3-up grid with captions. Use for portfolios, location pages, lookbooks, product ranges.

### Inline editorial photo
```html
<figure class="editorial">
  <img src="https://picsum.photos/seed/[context]/1600/900" alt="...">
  <figcaption>Caption with context, sometimes with attribution</figcaption>
</figure>
```
A single rich photo between text sections, often with a real caption. Common in editorial sites (think a New York Times article). Adds rhythm to text-heavy pages.

### Product cards with photos
```html
<article class="product">
  <img src="https://picsum.photos/seed/[product-name]/800/1000" alt="..." class="product__photo">
  <h3 class="product__name">The Foundry Table</h3>
  <p class="product__detail">Reclaimed Douglas fir. $4,200.</p>
</article>
```
Photo first, then editorial-styled details. Use for physical goods catalogs.

## When NOT to Use Photography

- Software dashboards, code blocks, data tables — these belong as CSS mockups
- Generic "team meeting" / "people pointing at laptop" / "handshake" scenes — these are AI stock-photo tells. If you'd use one, skip the photo and let typography carry the section.
- Anywhere a real product photo would be wrong (e.g., a hot-sauce brand using a wine-cellar photo)

## Anti-Patterns

- **Hero with a CSS gradient where a photo should be.** If the product needs photography and you used a gradient blob instead, the site reads as a placeholder. Use a Picsum URL.
- **Generic alt text** (`alt="hero image"`, `alt=""`). Always describe what the photo should show.
- **Mixing CSS mockups with photography on the same site for the wrong content.** A hotel doesn't need a dashboard. A SaaS tool doesn't need lifestyle photos. Choose based on the product.
- **Stock photo cliches.** Diverse team in a meeting, handshakes, laptop close-ups, abstract "innovation" shots, the open road, the city skyline at sunset. Avoid.
- **Photos with text overlay that doesn't work.** If you put text on a photo, the photo needs a gradient overlay or a dim filter, OR the photo needs to be deliberately quiet. Don't put `color: white` text on a busy mid-tone photo and hope.
- **Forgetting `loading="lazy"`** on non-hero images. Causes performance hits and layout shifts.
- **Missing width/height attributes.** Causes CLS and gets dinged in Lighthouse.

## A Working Example

For Driftwood (boutique furniture), the hero might be:

```html
<section class="hero">
  <img
    src="https://picsum.photos/seed/driftwood-workshop-morning/2400/1200"
    alt="A reclaimed Douglas fir dining table being finished by hand in the Driftwood workshop, Portland, Oregon"
    width="2400" height="1200"
    class="hero__photo"
  >
  <div class="hero__content">
    <h1>Made from buildings, finished by hand.</h1>
    <a href="#commission" class="btn">Start your piece</a>
  </div>
</section>
```

The Picsum URL returns a real photo. The alt text tells the user what to source as a replacement. The image attributes prevent layout shift. The structure is honest about what the site needs.
