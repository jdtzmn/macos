# Illustration System

## Photography First, Mockups Second, Illustration Rarely

The biggest AI design tell across 70+ test sites was the absence of real photography. For any brief where photography is appropriate (hospitality, food, fashion, real estate, services with a human element, agencies, lifestyle, travel), use real `<img>` tags with Picsum or Unsplash URLs — see reference/imagery.md.

CSS mockups (dashboards, code blocks, data tables) are correct for software products where the product UI is the visual. They are WRONG for products that need photography. A hotel page with a CSS gradient where a hero photo should be reads as broken, not "minimalist."

The order of preference for section visuals:

1. **Real photography** (`<img>` tags) when the product is physical, human, or lifestyle
2. **CSS mockups** (dashboards, code blocks, data tables) when the product IS digital UI
3. **Typography-driven** (oversized type, ledgers, editorial) when neither photography nor UI mockups apply
4. **Custom SVG instruments** (frequency traces, region maps, schematic diagrams) for technical products that benefit from a precision-instrument aesthetic
5. **Abstract geometric accents** (sparingly, never as primary content)

NEVER use a gradient rectangle as a stand-in for any of the above. If you can't decide which approach fits, default to typography-driven and prose.

## The Medium Rule (READ THIS FIRST)

When building with static HTML/CSS/Tailwind (no image assets, no design tool exports), you are constrained to what the browser can render from code. This changes everything about illustration choices.

**What HTML/CSS renders well:**
- Typography-driven layouts (large numbers, pull quotes, editorial text treatments)
- Abstract geometric shapes (circles, lines, grids, dots, dividers)
- Simple data visualization (progress bars, meters, percentage rings, bar charts)
- UI component mockups (cards, forms, inputs, buttons, nav bars, notifications, chat bubbles)
- Color blocks, background shading, subtle gradients
- Icon-based compositions using SVG icon libraries
- Tables, comparison grids, feature matrices
- Simple diagrams (flowcharts with boxes and arrows, step connectors)

**What HTML/CSS renders BADLY (never attempt these):**
- Physical products (bottles, packaging, devices, clothing, food, furniture)
- Landscapes, nature scenes, architecture, or any real-world environment
- Human figures, faces, hands, or body parts
- Realistic objects of any kind (cameras, tools, vehicles, buildings)
- Complex artistic SVG illustrations attempting realism
- Product photography replacements
- 3D-looking objects with shading, highlights, and perspective

**When the product is physical (food, consumer goods, hardware, fashion, furniture, jewelry):**

**Use real photography. Period.** See reference/imagery.md.

The previous guidance to "use a styled placeholder rectangle" was removed — that pattern produced gradient blobs that read as broken sites. The only acceptable substitute for a required photo is a different photo. If you cannot source photography:
1. Use Picsum URLs with descriptive seeds (e.g., `picsum.photos/seed/driftwood-workshop-morning/2400/1200`) as the build placeholder. They return real photos.
2. Write alt text that describes what the brand's real photo should show.
3. The user replaces these with their own photography before shipping.

Typography-only treatments are appropriate ONLY for agencies, services, editorial brands, and software products. For physical goods, photography is mandatory — no exceptions.

## When to Use Visuals vs. When to Use Typography

| Product type | Visual approach | What to skip |
|-------------|----------------|-------------|
| SaaS / software tool | UI mockups, dashboard cards, notification previews | Physical objects |
| Developer tool | Code snippets, terminal output, API response blocks | Landscapes, devices |
| Consumer app | App screen mockups, simple UI flows | Physical packaging |
| Physical product (food, goods) | Abstract color/flavor representations, editorial typography, data points | Product renders, bottles, packaging |
| Service business (agency, studio) | Minimal geometric accents, typography-heavy | Stock imagery, office scenes |
| Marketplace / e-commerce | Category cards, price displays, rating components | Product photography |

## 8 Types (Use Only What the Medium Supports)

### 1. Product UI Mockups
Realistic product interfaces built in HTML.
- Cards, forms, dashboards, notifications, chat interfaces, email previews
- These are NATIVE to HTML and render perfectly
- Use real-looking data (names, numbers, dates), not Lorem ipsum
- Integration: floating within bento grids, in hero sections, beside feature descriptions
- When to use: SaaS, developer tools, any digital product with a visual interface

### 2. Code Snippet Blocks
Beautified code presentations.
- Syntax-highlighted code with brand-matched colors
- Dark background, clean container, subtle border
- **NO red/yellow/green browser chrome dots. EVER. No exceptions.** Use a thin accent-colored line at the top of the block, or just padding. Browser chrome dots are the #1 AI design tell.
- When to use: developer tools, API products, infrastructure

### 3. Data Visualization
Charts, meters, and metrics built with HTML/CSS.
- Progress bars, percentage rings (CSS conic-gradient), simple bar charts
- Stat cards with large numbers
- Flavor/intensity scales (horizontal bars with labels)
- When to use: analytics, monitoring, finance, or to represent any quantifiable concept abstractly

### 4. Abstract Geometric Accents
Simple shapes that create visual interest without representing anything literal.
- Circles, dots, lines, grids derived from the brand's color palette
- Used SPARINGLY as background accents, section dividers, or card decorations
- Never the primary content of a section. Always supporting typography.
- When to use: when the page feels text-heavy and needs visual breathing room

### 5. Component Compositions
Arrange real UI components to tell a story.
- A notification card + a chat bubble + a status badge composed together to show a workflow
- Multiple small UI elements arranged in a bento or staggered layout
- Each component is a real HTML element, not an illustration OF one
- When to use: showing how a product works through its actual interface pieces

### 6. Editorial Typography Treatments
When you can't illustrate, make the text the visual.
- Oversized pull quotes with accent color
- Large data points (numbers, percentages, measurements) as visual anchors
- Tasting notes, specs, or features displayed as a designed typographic composition
- Definition-list layouts with term/value pairs given visual weight
- When to use: physical products, luxury goods, food, wine, anything where the story is the sell

### 7. Simple Diagrams
Flowcharts, step connectors, and process visualizations.
- Boxes connected by lines or arrows
- Numbered steps with connecting vertical/horizontal rules
- Before/after with an arrow or divider between
- Keep to basic shapes: rectangles, circles, lines
- When to use: process explanations, how-it-works sections, workflow visualization

### 8. Placeholder Image Areas
Honest, styled containers for content that requires real photography or design assets.
- Rounded rectangle matching the border-radius system
- Brand background color (muted accent at 8-12% opacity, or paper-2 tier)
- Centered label: product name, dimensions, or content description
- Looks intentional, not broken
- When to use: anywhere you'd need a photo but don't have one. Better than a bad SVG.

## Rules

1. **The Tempo rule: if you can't make it look better than no illustration at all, don't make it.** An empty section with great typography beats a section with a bad SVG illustration.
2. Every visual must be something HTML/CSS renders well. Before creating any SVG or complex visual, ask: "Would this look professional, or would it look like a child drew it in code?" If the latter, use typography instead.
3. NEVER attempt to render physical products (bottles, packaging, food, devices, clothing) in HTML/CSS/SVG. Use a placeholder or editorial typography treatment instead.
4. NEVER attempt landscapes, nature scenes, buildings, or environmental illustrations.
5. NEVER attempt human figures, faces, or hands.
6. **NO fake browser chrome (red/yellow/green dots). EVER. No exceptions.** Not on code blocks, dashboards, mockups, or anything else. Use a thin accent line or border instead. This is the #1 AI design tell.
7. For rich section visuals, use patterns from `reference/css-mockups.md` — dashboards, app screens, data tables, funnels, comparison splits. These render cleanly and communicate the product.
8. NO monospace in illustrations unless displaying actual code.
9. Illustrations use the brand accent color. Part of the design system.
10. On dark sections, adapt (lighter strokes, on-dark accent).
11. Mobile: simplify or remove. Never hide content, but visual accents can be reduced.
12. When in doubt, leave it out. Typography and spacing create more visual richness than a forced illustration.
