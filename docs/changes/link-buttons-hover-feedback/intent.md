# Intent: Link buttons get button hover feedback

Author: Etienne van Delden. Status: accepted. Type: bugfix.

## Problem

A link styled as a button shows an underline on hover and no hover or press animation. Buttons (`button`, `input[type="submit"]`) brighten on hover and shrink on press. Page-action links in `main > header nav` and `a[role="button"]` links get no such feedback.

## Proposed outcome

A link styled as a button feels like a button: it brightens on hover, presses on active, and never underlines.

## Affected users and systems

Apps that use mvpa.css and render page-action links (`main > header nav a`) or `a[role="button"]`.

## Constraints

- Classless first: no new classes.
- `mvpa.css` stays in sync with the partials.
- Eink themes keep their own look.

## In scope

- Hover and active feedback for `main > header nav a` and `a[role="button"]`.
- No underline on hover for both.
- Mirror in `mvpa.css`, tests, a `CHANGELOG.md` entry without `### Upgrading`.

## Out of scope

- Plain links, sidebar navigation links, disabled state for links.

## Acceptance criteria

- Hovering a page-action link brightens it and shows no underline.
- Pressing a page-action link scales it down like a button.
- Hovering an `a[role="button"]` link brightens it and shows no underline.

## Decisions

- Header is a direct child of `main` in the affected app — confirmed by Etienne ("yes").

## Open questions

None.
