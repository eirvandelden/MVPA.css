# Intent: Period navigation (previous / current / next)

Author: Etienne van Delden de la Haije. Status: accepted (2026-10-26). Type: feature. Delivery: autonomous. Codex review: no.

## Problem

An app that shows one period at a time (a day, a week, a month, a year) has no mvpa.css look for its "previous · current period · next" control. Clocky builds one with its own `.week-navigation` class and CSS (a tinted bar, the period label centred, a link at each end, a column below 768px) on its dashboard and statistics pages. The look does not fit mvpa.css: it uses hard-coded values instead of mvpa.css tokens. Another app that wants the same control has to copy Clocky's CSS.

## Proposed outcome

mvpa.css styles a period navigation from semantic markup, with no class. It keeps Clocky's look: a tinted bar, the previous link at the start, the period label centred, the next link at the end. Spacing, radius and colours come from mvpa.css tokens. Clocky's dashboard and statistics pages can then drop `.week-navigation` and its CSS, through the separate Clocky change `update-appkit-and-mvpa-css`.

## Affected users and systems

- People who use Clocky's dashboard and statistics pages, on desktop and on phones.
- Any other app that pins mvpa.css and shows periods.
- mvpa.css: a stylesheet partial, the flattened `mvpa.css` manifest, `demo.html`, `README.md`, `CHANGELOG.md`, and their tests.

## Constraints

- Classless: the control is recognised from semantic HTML only (element, attributes, structure, context). No new class.
- It must not change how the sidebar nav (`body > header nav`), the title bar (`main > header nav`) or the pull-down menu look.
- All six themes (four Solunized, two e-ink) must render it.
- The partial and the flattened `mvpa.css` stay in sync (`test/mvpa_manifest_sync_test.rb`); `demo.html` lists every partial and its file count.
- Clocky pins a merged mvpa.css SHA only, so this change merges first.
- Permissions: none. No gem, package, system tool, migration or deploy file changes. A need that comes up later is a stop-and-ask.

## In scope

- Styles for a previous / current period / next control, built from semantic markup, for any period length.
- A secondary link in the label, such as Clocky's "Today" link back to the current period.
- Phone behaviour as Clocky has it today: below the phone breakpoint the parts stack in a column.
- `demo.html` example, `README.md` section with the markup, and a dated `CHANGELOG.md` entry with an `### Upgrading` section that tells an app how to replace its own week-navigation class.
- Tests for the new behaviour.

## Out of scope

- Any change in Clocky; that is the `update-appkit-and-mvpa-css` change.
- A day strip, a calendar or a date picker.
- Styling `input[type="week"]` or other date inputs.
- Generating labels, arrows or dates; the text comes from the app.
- JavaScript.
- Changes to the sidebar nav, the title bar, the pull-down menu or the segmented control.

## Acceptance criteria

- A page with "← Previous Week", "Week 43, 2026" and "Next Week →" as a period navigation shows one tinted bar: "← Previous Week" at the start, "Week 43, 2026" centred, "Next Week →" at the end, with no class in the markup.
- The same markup with "October 2026", "26 Oct 2026" or "2026" as the label looks the same: the control does not depend on the period length.
- When the label also holds a "Today" link, the link shows next to the label inside the bar, and the bar keeps its three parts.
- On a phone-width screen, the previous link, the label and the next link stack in a column, label centred, and nothing scrolls sideways.
- The bar reads correctly in Solunized light, dark, white and black and in both e-ink themes.
- The sidebar nav, the title bar and the pull-down menu in `demo.html` look the same as before.
- `demo.html` shows a period navigation, and `README.md` shows its markup.
- The `CHANGELOG.md` entry tells an app, step by step, how to replace its own week-navigation class with the new markup.

## Decisions

- The pager is "previous · current period · next", not a day strip or a week picker — Etienne chose it from the options.
- Clocky is the first app to use it — Etienne's answer.
- It covers any period, not only weeks — Etienne's answer; "week" is the first use.
- Keep Clocky's look: plain links on a tinted bar — Etienne chose it from the options.
- Details beyond that follow the Clocky plan: move Clocky's week navigation into mvpa.css as it is — Etienne: "don't care, just do what was in the plan".
- No permissions needed — Etienne confirmed.
- Autonomous delivery without Codex review — chosen by Etienne, no reason given.

## Open questions

None.
