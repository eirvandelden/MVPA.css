# Intent: Rail, hub column and landing tiles

Author: Etienne van Delden de la Haije. Status: accepted (2026-11-06). Type: feature. Delivery: autonomous. Codex review: no.

## Problem

mvpa.css styles one sidebar: a single `<nav>` in `body > header` that becomes the phone tab bar. The task-hub shell that appkit PR eirvandelden/appkit#24 emits, and journal_administration's navigation-hubs change uses, has no styling:

- A rail of hubs and a hub column with the pages of the current hub stack in one `--nav-width` column. The nav-only sidebar track (#47) matches only `body > header:has(> nav:only-child)`, so Overzicht (rail only) and every other hub (rail plus hub column) get different layouts.
- The rail marks the current hub with `aria-current="true"`. mvpa.css highlights only `aria-current="page"`.
- At phone width the tab bar holds the rail's search entry, the five hubs, the account entry and the hub column, so it scrolls sideways.
- Nothing hides the title-bar copies of search and the account menu on a wide screen, where the rail already shows them.
- A landing page shows its tiles as a plain list of links, with the link underline wiggle.
- The demo's "Landing tile" example is one count-badge link and shows no landing page.

## Proposed outcome

An app that renders the shell markup gets the rail, the hub column and the landing tiles from mvpa.css, with no local CSS:

- On a wide screen the rail and the hub column sit side by side in one sidebar card, divided by a hairline. Overzicht's rail-only card puts the rail in the same place.
- The rail is narrow: each hub is its emoji above a small label. The current hub has the same primary fill as the current page.
- The account name at the end of the rail opens the account menu as a pop-up beside the rail.
- Between phone width and 1024px the hub column hides and the rail stays.
- At phone width the tab bar shows exactly the hubs: the rail's search and account entries and the hub column hide. The title bar shows its search and, on Overzicht, its account menu; on a wide screen those title-bar copies hide.
- A landing page shows its tiles as a grid of surface tiles with a hover lift and no underline wiggle. At phone width the tiles become one list of rows with a trailing ›.
- `demo.html` shows the rail shell and a landing page.

## Affected users and systems

- journal_administration (navigation-hubs, phase C), through appkit's `_nav` and `_account_menu` partials and the app's layout, title bar and landing page.
- appkit PR #24: its markup contract changes (see Constraints).
- Every app that pins mvpa.css and renders today's single-nav sidebar (clocky, sticker-app and others): its layout must not change.
- mvpa.css: a new module partial, the flattened `mvpa.css`, `demo.html`, README, CHANGELOG and GLOSSARY.

## Constraints

- The journal intent (accepted 2026-10-25) decided the shell's behaviour: the hub column hides below a set width above phone width, the phone bar shows exactly five hubs, the avatar sits only in the Overzicht title bar, and no page scrolls sideways at any width.
- Classless first: `nav.rail` is the only new class, beside the existing button classes. Everything else comes from structure and elements.
- Markup contract this slice styles (replaces the journal plan's 2026-10-25 contract):
  - `body > header` holds `nav.rail`, then on a hub with pages a second `<nav>`: the hub column.
  - `nav.rail` holds a `<search>` with the search control, then a `<ul>` of hub links (an `aria-hidden` emoji span plus the label), then a last `<li>` with the account `<details>`.
  - The rail marks the current hub with `aria-current="true"`; the hub column marks the current page with `aria-current="page"`.
  - The title bar's `<nav>` holds a `<search>` with the search control, and on Overzicht the account `<details>`, whose `<summary>` has an `aria-label`.
  - A landing page renders its tiles as a `<ul>` of `li > a` inside a `<nav>` in `main`. The tile count is text in the link, not `<data>`.
  - appkit and the journal drop the `hub-column` and `tiles` classes, add the `<search>` wrappers and wrap the tiles in `<nav>`.
- Breakpoints: phone up to 768px (the existing one); hub column hidden from 769px to 1023px; shown from 1024px.
- The flattened `mvpa.css` mirrors every partial; `demo.html` lists every partial and states the count.
- Approved permission: one dev-only gem or npm package for tests, such as a CSS parser. Any other gem, package, migration, system tool or deploy file change is a stop-and-ask.

## In scope

- The rail on a wide screen: narrow, each hub's emoji above a small label, long labels shrunk and hyphenated, as tall as its content, the search entry first and the account name last.
- The joined sidebar card behind the rail and the hub column, with a hairline between them, in every theme (the dark hairline and e-ink borders as the sidebar card has today). It follows the #47 sticky behaviour.
- The current hub (`aria-current="true"`) with the same fill as the current page, in every theme.
- The account menu in the rail as a pop-up beside the rail on a wide screen, opened and closed with its `<summary>`, without JavaScript.
- The hub column beside the rail from 1024px; hidden from 769px to 1023px and at phone width.
- At phone width: the rail's `<search>` and account `<li>` hidden, so the tab bar holds only the hubs.
- The title-bar `<search>` and the account `<details>` with a labelled `<summary>` hidden above phone width on a page with `nav.rail`.
- Landing tiles: a grid of surface tiles on a wide screen with the nav-link hover lift and no underline wiggle; one list of full-width rows with a trailing › at phone width.
- `demo.html` switched to the rail shell, with a hub column and a landing page of tiles; the "Landing tile" example replaced.
- README sections, a CHANGELOG entry with `### Upgrading` steps for the markup contract, and GLOSSARY terms.

## Out of scope

- Changing today's single-nav sidebar: its look, track and phone bar stay as they are.
- The appkit and journal markup changes themselves; they follow the `### Upgrading` steps.
- JavaScript: no new controller; `nav_controller.js` is unchanged. The pop-up does not close on an outside click.
- A full-height rail with the name pinned to the window bottom.
- Count badges on rail hubs.
- A tab bar with more than five hubs: it keeps today's sideways scroll.
- The title-bar back link and the actions pull-down look (#49).

## Acceptance criteria

- At 1280px on a Verwerken page, the rail and the hub column sit side by side in one sidebar card with a hairline between them, and `main` starts after the hub column.
- At 1280px on Overzicht (rail only), the rail has the same position and width as on Verwerken, and the card is only the rail.
- An app with today's single-nav sidebar (the README markup, no `nav.rail`) looks the same as before this change at 1280px and at 375px.
- The rail shows 🏠 above "Overzicht", and "Administratie" fits the rail without overflow, broken at a syllable when it is too long.
- With five hubs, the rail's card ends right below the account name; on a hub whose column is taller, the card is as tall as the hub column.
- On a transaction's edit page, the rail's Administratie and the hub column's Journaal have the same primary fill.
- Clicking the account name in the rail opens Profiel, Voorkeuren, Beheer and Uitloggen in a pop-up beside the rail, over the hub column; the rail does not widen. Clicking the name again closes it.
- At 900px the hub column is gone, the rail stays, and nothing scrolls sideways. At 1024px the hub column is back.
- At 375px the bottom bar shows exactly the five hubs: no search, no account name, no hub column, and nothing scrolls sideways.
- At 375px the title bar shows the search button, and the Overzicht title bar shows 👤. At 1280px on a page with a rail, neither shows in the title bar. The "Acties ▾" pull-down shows at both widths.
- On a page without a rail, a title-bar `<search>` shows at every width.
- At 1280px a landing page with four tiles shows them as surface tiles in a grid of columns at least about 14rem wide. Hovering a tile lifts it, and its text has no underline wiggle.
- A tile that reads "0 rekeningen nog niet ingedeeld" looks like every other tile.
- At 375px the same tiles are one list of full-width rows, each ending in ›.
- A period navigation, a title-bar `<nav>` and a `<nav>` of bare links in `main` (clocky's form actions) keep their current look.
- In solunized-dark and solunized-black the sidebar card has its hairline border; in eink-light and eink-dark it has its ink border, and the current hub uses that theme's current-page look.
- `demo.html` shows the rail, a hub column and a landing page of tiles, and the "Landing tile" example is gone.

## Flagged concerns

- The contract differs from appkit#24 and the journal plan (2026-10-25): one class instead of three, `<search>` wrappers, tiles in `<nav>`. Chosen side: the closest to classless; appkit and the journal follow the `### Upgrading` steps.
- `demo.html` switches to the rail, so today's single-nav sidebar, still supported for other apps, has no live demo. Chosen side: the rail in the demo; the README keeps documenting the single-nav sidebar.

## Decisions

- Rail, hub column and tile grid go into mvpa.css as one slice — decided in the journal intent (2026-10-25); no reason given.
- Use one class, `nav.rail`; the hub column is the second `<nav>` in `body > header`; tiles are a `<ul>` in a `<nav>` inside `main` — recommended option chosen: the closest to classless that keeps other apps' sidebars unchanged.
- Draw a narrow rail, emoji above label — recommended option chosen: matches the chosen UI review mock and leaves the table room.
- Hide the hub column below 1024px — recommended option chosen: a common width that still leaves `main` about 700px.
- Open the rail's account menu as a pop-up beside the rail — recommended option chosen: a narrow rail has no room for an indented list.
- Hide the title-bar search and account menu above phone width, keyed on `<search>` and a labelled `<summary>` — recommended option chosen: follows the agreed plan without a class.
- Size the rail to its content — Etienne: "sidebar currently is also sized to content. It is shorter when there is less content, it is longer when there is more content."
- Paint one joined card with a divider — reads as one sidebar, like macOS.
- Draw tiles as surface tiles with a hover lift — recommended option chosen: reuses the surface and hover tokens already in mvpa.css.
- Turn tiles into list rows with › at phone width — recommended option chosen: matches the phone mock.
- Fill the current hub like the current page — one highlight style everywhere.
- Shrink and hyphenate long hub labels — recommended option chosen: no text is lost and nothing overflows.
- Wrap the rail's search in `<search>` too — recommended option chosen: no guess about which button is search.
- Switch `demo.html` to the rail shell — the rail is the shell going forward.
- Approve one dev-only gem or npm package for tests — no reason given.
- Autonomous delivery, no Codex review — no reason given.

## Open questions

None.
