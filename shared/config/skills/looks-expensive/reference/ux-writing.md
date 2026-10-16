# UX Writing Guide

## Banned Words

These trigger "AI wrote this" or "corporate template" feeling. Never use:

| Banned | Why | Use Instead |
|--------|-----|-------------|
| revolutionize | Every company says this | Be specific about what changed |
| cutting-edge | Meaningless filler | Skip entirely, or "latest" |
| unlock the potential | Corporate jargon | "Get access to" or "Use" |
| leverage | Nobody talks like this | "Use", "apply" |
| seamless | Overused to death | "Smooth" or describe the experience |
| robust | Sounds AI-generated | "Fast", "reliable", "sturdy" |
| streamline | Vague | "Make work flow faster" |
| comprehensive | Defensive, vague | List what's included instead |
| elevate your | Pretentious | "Improve" or "upgrade" |
| furthermore / moreover / indeed | AI transition words | "Also", "And", or rewrite |
| it is important to note that | AI filler | Delete entirely |
| endeavour | Nobody speaks this way | "Try", "work on" |
| crucial / vital | Overwrought | "Important" or remove if obvious |
| future-ready | Meaningless | Skip or say "works with new tech" |
| game-changing | Hyperbolic | Describe the actual change |
| unprecedented | Almost never true | Be specific |
| empower | Corporate speak | "Help", "let", "give" |
| synergy | Business jargon | "Work better together" |
| holistic | Vague | Be specific about what's included |

## Character Limits

| Element | Max Chars | Max Words | Example |
|---------|-----------|-----------|---------|
| Headline | 60 | 6-10 | "Payments infrastructure for the internet" |
| Subhead | 120 | 15-25 | "Process 1M+ transactions daily. No downtime." |
| Body paragraph | 180 | 25-35 | One benefit per sentence, max 15 words each |
| CTA button | 30 | 2-5 | "Start free trial" |
| Feature card title | 50 | 4-8 | "See changes in real-time" |
| Feature description | 100 | 12-18 | "Instant notifications across Slack, email, and mobile" |
| Eyebrow/label | 25 | 2-4 | "For teams" |

## CTA Rules

Every button must describe the specific action. No generic text.

Bad: "Get Started", "Learn More", "Submit", "Click Here"
These appear on 10,000 landing pages and say nothing.

Good: "Start free trial", "See pricing", "Download template", "Reserve my spot", "Try 14 days free", "Schedule a call", "Get my report"

Rules:
- Action verb first
- Specific benefit when possible
- First-person ("my") converts better than "your"
- Different CTAs on the same page should have different text
- Primary CTA: filled button using `--accent-ink` (NOT base `--accent`) with near-white text; or base `--accent` fill with dark page-ink text. See SKILL.md Color System step 5. Secondary CTA: outlined or text link using `--accent`.

## Headline Formula

`[Who it's for OR what it does] + [core benefit OR outcome]`

Examples:
- "Project management for engineering teams" (5 words)
- "Design tools that ship faster" (5 words)
- "Know exactly what works" (4 words)
- "Fast, reliable, easy to use" (5 words)

## Section Copy Structure

```
EYEBROW (optional, 2-4 words, logical label)
"For product teams"

HEADLINE (6-10 words)
"Collaborate on designs in real-time"

BODY (2-4 sentences, each under 15 words)
"See changes instantly. Comment on anything.
Never lose context."

CTA (2-5 words)
"Start designing free"
```

## Tone

- Confident, not arrogant. "Trusted by 50,000+ companies" not "Our world-class platform is unbeatable."
- Specific, not vague. "Kanban boards, sprints, and time tracking" not "Comprehensive features for all your needs."
- Conversational, not formal. "Work faster, waste less time" not "Endeavour to optimize operational metrics."
- Concrete, not abstract. "Turn raw data into sales reports in 5 minutes" not "Unlock the potential of your data."

## Section Labels

Eyebrows and pills must be LOGICAL LABELS that tell the reader what section they're in.

Good: "For teams", "Pricing", "How it works", "What our customers say", "Features", "Security"
Bad: "Section 01", "--- Features ---", "01.", "02.", "Chapter 1", "Part One"

No decorative numbering. No dashes as decoration. No dates unless the content is actually dated.

## Prose Over Bullets

Bullet points are a presentation crutch. They flatten ideas into a list when prose would carry them better, and they're the #1 verbal AI design tell.

**The 5-bullet rule:** Maximum 5 bullet points per page, total, across ALL sections. Not per section — per page. If you're past 5, restructure.

**What to use instead:**

| Don't | Do |
|-------|-----|
| 4 bulleted features with short descriptions | Definition list (term + description) — see reference/non-card-patterns.md Pattern 2 |
| Bulleted list of capabilities | Ledger row format — Pattern 1 |
| Bulleted "what's included" | One sentence of prose listing them, with commas |
| Bulleted "why us" | Numbered sections with editorial headings — Pattern 3 |
| Bulleted pricing features | Real HTML table with rows — Pattern 7 |
| Bulleted process steps | Numbered prose paragraphs, or a vertical timeline |

**When bullets ARE okay (the page cap still applies regardless):**
- Genuine inline lists where order doesn't matter, items are short and similar, and prose genuinely cannot carry it (e.g., "Tags: anxiety, CBT, virtual")
- Inside a single comparison table cell

**When bullets are NOT okay:**
- The main feature presentation on the page
- Above-the-fold benefits
- As the body of every section
- Anywhere a paragraph, definition list, ledger, or table would carry the idea
- "Sub-bullets inside feature cards" — banned. If you have 4 cards × 3 sub-bullets = 12 bullets, you blew the cap. Restructure to a definition list (Pattern 2) or a ledger (Pattern 1).

**The cap is by visual pattern, not HTML tag.** Faux-bullet divs (`<div>` with a checkmark/dot/arrow prefix, `::before` content markers, icon-plus-text repeated rows) ALL count as bullets. A 3-tier pricing column with 8 checkmark rows = 8 bullets. Restructure into a real HTML table.

## Eyebrow Discipline

The uppercase pill label above a section heading ("FEATURES", "HOW IT WORKS", "PRICING") is the most overused element in AI-generated landing pages. Real designers use them sparingly, often not at all.

**The 1-eyebrow rule:** Maximum 1 eyebrow per page. Ideally zero.

If a section needs context, the heading itself does the work. "How Trellis Works" is a clearer section heading than an eyebrow that says "HOW IT WORKS" above a heading that says "Built for growers." Pick one — usually the heading.

**Banned pill style:** No `border-radius: 9999px; padding: 6px 14px; border: 1px solid var(--accent); color: var(--accent); text-transform: uppercase; letter-spacing: 0.12em;` pills above headings. This exact CSS is in 80% of AI-generated landing pages.

**If you DO use one eyebrow:** Make it earn its keep. Use it on a key section (often the hero or a featured product) where the additional context genuinely helps. Style guidance:
- Differentiate from the banned pill via TYPOGRAPHY alone — small (12-13px), accent-colored or muted ink, positive tracking (0.08-0.14em).
- **NO decorative line, bar, or dash next to the label.** No `::before { content: ""; width: Npx; height: 1px; }`. No leading "—" or "–" character. No vertical or horizontal rule next to the eyebrow. The bar always reads as "----" beside the label — it's the 2026 reincarnation of the pill (replacing one tell with another).
- No underline, no boxed background, no border, no chip, no leading icon.
- The label IS the eyebrow. Whitespace and color carry it.

## Testimonial & Social Proof Rules

**Banned testimonial names** (these appear in AI-generated content constantly):
Sarah Chen, Marcus T., Marcus Chen, Priya S., Priya Sharma, Priya Patel, Maria Santos, Elena (any), Jordan K., Alex Rivera, Jamie (any), David & Laura, David & Rachel, Aisha (any), Jess L.

Instead: generate names that match the product's actual audience demographic and geography. A construction PM tool should have names common in the construction industry. A pet insurance app should have names that feel like real pet owners in the target market.

**Testimonial avatar:** Never use a gradient circle as an avatar placeholder. Either use initials in a colored circle (e.g., "SC" in a brand-colored circle) or omit the avatar entirely. Gradient circles are an AI design tell.

**Star ratings:** Never give every testimonial 5 stars. Real products have 4.5-4.8 averages. Either use a mix (one 4-star, two 5-star) or drop star ratings entirely and let the quote speak.

**Company names in testimonials:** If the company is fictional, make it sound real — not like AI naming (avoid: "Vantage Corp", "NexGen", "TechForward", "InnovateCo"). Use mundane, specific names: "Ridgeline Builders", "Coastal Freight Partners", "Birch Lane Dental."

**Alternative social proof patterns** (often better than individual testimonials):
- Logo cloud with real or realistic company names as text (not gray placeholder boxes)
- Stat-based proof: "Trusted by 340 teams" or "Processing $2.1B annually"
- Review aggregation: "4.8 on G2 from 1,200 reviews" with link
- Case study snippet: one specific result with company name and metric

## Conciseness Audit

Before any copy ships, check:
1. Remove: "very", "really", "quite", "somewhat", "perhaps", "actually", "essentially", "basically", "literally"
2. "In order to" becomes "To"
3. "At the end of the day" gets deleted
4. "That being said" gets deleted
5. Can the adjective be removed? "Beautiful design" becomes "Design" if beautiful is self-evident
6. "Advanced analytics" becomes "Analytics" unless you're comparing to basic analytics
