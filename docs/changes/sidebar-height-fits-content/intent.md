# Intent: Desktop sidebar fits its own content

Author: Etienne van Delden de la Haije. Status: accepted (2026-10-26). Type: bugfix. Delivery: autonomous. Codex review: no.

## Problem

On desktop (wider than 768px), the sidebar card always fills almost the full viewport height. A short nav leaves a tall empty card below its last item. A nav taller than the viewport sticks at the top, and its lower items stay off-screen until the reader reaches the end of the page.

## Proposed outcome

On desktop, the sidebar card is exactly as tall as its content, whatever the viewport height. A sidebar that fits in the viewport stays in view while the page scrolls, as today. A sidebar taller than the viewport scrolls with the page, so the reader reaches every item by scrolling the page.

## Affected users and systems

Every app that uses mvpa.css and shows the sidebar on desktop. The per-layer source stylesheets and the packaged `mvpa.css` both change. The demo page shows the result.

## Constraints

- Classless: styles come from semantic HTML; no new classes.
- The sidebar keeps no internal scrollbar (the PR #16 design).
- No permissions needed: no gems or packages, system tools, migrations or deploy files.

## In scope

- Desktop sidebar height follows its content.
- A desktop sidebar taller than the viewport: every item is reachable by page scroll.
- Rebasing the branch on `main`, with commit `565f728` as the starting point.

## Out of scope

- The mobile bottom bar (768px and narrower).
- Sidebar look: shadow, radius, border, gutter, themes.
- The nav link styles.

## Acceptance criteria

- On a desktop viewport, a sidebar with three nav links ends just below the third link, not near the bottom of the viewport.
- On a desktop viewport with a long page, a short sidebar stays in view at the top while the reader scrolls down.
- On a desktop viewport, a sidebar with more nav links than fit in the viewport shows its last link when the reader scrolls the page down, also when the main content is short.
- The sidebar never shows its own scrollbar.
- On a phone-width viewport, the bottom bar looks and behaves as before.

## Decisions

- Bugfix: the sidebar is exactly as tall as its content — a short nav gives a short card.
- The plan reuses commit 565f728 and rebases the branch on main — the work exists already; its regression test must still fail first.
- A nav taller than the viewport is in scope — no reason given.
- A tall nav scrolls with the page, with no internal scrollbar — keeps the PR #16 "no internal scrollbar" design and makes every item reachable.
- Autonomous delivery, no Codex review — no reason given.

## Open questions

None.
