# Glossary

- **Canvas** — the page background behind every surface, the `--color-bg` token. Avoid: page colour, base.
- **Count badge** — a `<data value>` inside a link, shown as a pill with the number of items that need attention; hidden at zero. Avoid: tag, counter.
- **Form choice** — a segmented control built from a `<menu>` of radios, normally inside a `<fieldset>`, that picks one value for a form.
- **Inset** — a part painted inside a surface: a period navigation inside an article, the selected segment of a segmented control, a mobile tab item. In the dark themes a period navigation inside an article and a mobile tab item read lighter than their surface, because no palette step is darker than `bg-0`; the selected segment reads darker than its track. Avoid: raised part.
- **Link colour** — the text colour of a plain link, the `--color-link` token. Each theme mapping sets it: the primary blue in the light Solunized themes, the brighter blue (`--color-br-blue`) in the dark Solunized themes; the e-ink themes resolve it to ink. Avoid: primary (for links).
- **Nav-only header** — a `body > header` whose only element child is its `<nav>`, the sidebar markup that the README and the demo document.
- **Next link** — the last child of a period navigation, an `<a>` to the following period.
- **Period label** — the `h2`–`h6` in the middle of a period navigation. It names the period, such as "Week 43, 2026" or "October 2026".
- **Period navigation** — a `<nav>` outside any `<header>` whose element children are exactly a link, a heading and a link, shown as one tinted bar. Avoid: week navigation, pager.
- **Previous link** — the first child of a period navigation, an `<a>` to the preceding period.
- **Segmented control** — a `<menu>` whose items render as joined segments with one selected segment, either a view switch or a form choice. Avoid: tabs, toggle.
- **Sidebar card** — the painted sidebar surface: background, radius, shadow and the theme borders; the `<nav>` paints it in a nav-only header, the header paints it otherwise.
- **Sidebar track** — on desktop, a nav-only header as an invisible box at least the window height minus two shell gutters, which sticks by its bottom edge and holds the sidebar card at its top.
- **Surface** — an element painted on the canvas: the sidebar card, an article, a table head, a dialog, an open details, the period navigation outside an article. It uses the `--color-bg-lighter` token. Avoid: panel, card (except the sidebar card).
- **Today link** — an optional `<a>` inside the period label that goes back to the current period.
- **View switch** — a segmented control built from a `<menu>` of links, where the link with `aria-current` is the selected view.
- **Visited link colour** — the text colour of a plain link the reader has already opened, the `--color-link-visited` token. Each theme mapping sets it: violet (`--color-violet`) in the light Solunized themes, the brighter violet (`--color-br-violet`) in the dark Solunized themes; the e-ink themes resolve it to ink. Avoid: violet (for visited links).
