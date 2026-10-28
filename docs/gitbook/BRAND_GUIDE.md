# Shenkar-inspired visual identity — GitBook implementation guide

This is a **proposed course theme inspired by Shenkar**, not an official institutional style guide or claim of institutional endorsement. Use a formally approved institutional logo when permission is confirmed.

## Visual direction

- **Visual character:** Editorial academic design. Bold black headings, generous white space, minimal surfaces, disciplined red accents.
- **Primary accent:** `#E53935` (proposed approximation; replace with the institution's approved exact brand red if provided).
- **Heading/text:** `#171717`.
- **Background:** `#FFFFFF`.
- **Soft sections:** `#F7F7F7`.
- **Borders:** `#E4E4E4`.
- **Secondary text:** `#5F6368`.
- **Code surfaces:** `#F4F4F5` in light mode; dark editor-like surfaces are acceptable if contrast remains high.

## GitBook settings (manual site action)

GitBook → your Docs site → **Customization**:

| Setting | Recommendation |
|---|---|
| Theme | Clean or a similarly restrained light theme |
| Primary color | #E53935 (provisional Shenkar-inspired red) |
| Default appearance | Light |
| Dark mode | Optional, but test logo contrast before enabling |
| Background | White |
| Titles/body | Clear sans-serif; choose a GitBook-supported font with good Hebrew/English rendering |
| Code font | Monospace |
| Borders | Thin, light gray |
| Shadows | Minimal |
| Corner radius | Subtle/moderate, avoid oversized pill-like surfaces |
| Icons | Consistent outline style |

In navigation, retain 6 numbered labs, and keep Setup, Troubleshooting, and Glossary as utility pages.

## Branding and logo safety

Shenkar's official logo instructions describe three-language composition and require preserving the entire logo; permitted logo colors are red, black, or white. Do not recreate, stretch, recolor to teal, crop, or split the mark. Obtain the official horizontal lockup from [Shenkar's logo guidance](https://www.shenkar.ac.il/about-shenkar/administrative-departments-and-units/shenkar-logo/) and upload it **unchanged** in GitBook Customization once use is approved.

For an independent lecturer-built tutorial site, the safe page title is **Data Engineering | Hands-on Labs**. You may add an accurately described course affiliation, but do not represent the site as an officially published institutional property without authorization.

## Page-level structure

Each lab should keep this rhythm:

1. **Mission** — one short sentence
2. **Learning outcomes** — 3–5 specific skills
3. **Launch** — one `make lab-...` command
4. **Predict** — small thought exercise before execution
5. **Explore** — code / tiny table / diagram
6. **Check** — expected behavior, not a full answer key
7. **Challenge** — an optional extension
8. **Next** — link to the next lab

Recommended content style: shorter paragraphs, one idea per subheading, limited callout blocks, accessible contrast, no decorative emoji in every header, and clear English code semantics. Hebrew helper prose may be used without mixing RTL and SQL on one visual line.

## Limitations

Site-wide theme controls, primary color, logos and font selection are set in GitBook **Customization**, not via a standard Markdown file under Git Sync. The GitHub edits prepare consistent content and design guidance but do not change the live GitBook theme until those controls are saved in GitBook.

References:
- https://www.shenkar.ac.il/about-shenkar/administrative-departments-and-units/shenkar-logo/
- https://gitbook.com/docs/guides/customizing-your-site/how-to-customize-your-sites-theme
