# Glossary

- **Count badge** — a `<data value>` inside a link, shown as a pill with the number of items that need attention; hidden at zero. Avoid: tag, counter.
- **Form choice** — a segmented control built from a `<menu>` of radios, normally inside a `<fieldset>`, that picks one value for a form.
- **Nav-only header** — a `body > header` whose only element child is its `<nav>`, the sidebar markup that the README and the demo document.
- **Segmented control** — a `<menu>` whose items render as joined segments with one selected segment, either a view switch or a form choice. Avoid: tabs, toggle.
- **Sidebar card** — the painted sidebar surface: background, radius, shadow and the theme borders; the `<nav>` paints it in a nav-only header, the header paints it otherwise.
- **Sidebar track** — on desktop, a nav-only header as an invisible box at least the window height minus two shell gutters, which sticks by its bottom edge and holds the sidebar card at its top.
- **View switch** — a segmented control built from a `<menu>` of links, where the link with `aria-current` is the selected view.
