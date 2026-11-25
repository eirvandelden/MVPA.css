---
level: minor
---

### Added
- **Semantic versions** — every merge to `main` now releases a version `vX.Y.Z`: major when apps must change markup, classes, configuration or code, minor for an opt-in feature, patch for a fix and anything else. Pin `tag: "vX.Y.Z"` in your Gemfile. A `ref:` SHA keeps working.
- **Versioned history** — each dated changelog entry up to 6.0.0 has a version, and the matching commits get `v0.1.0` to `v6.0.0` tags. Those tags pin the code of that date; `Mvpa::Css::VERSION` inside them still reports the old value.
- **Breaking-change check** — a pull request that removes a `--token`, a stylesheet or JS file, a class or `data-` selector or an importmap pin below `level: major` fails the `Surface` workflow.

### Changed
- **`Mvpa::Css::VERSION`** — the gem version is the released `X.Y.Z`, no longer `0.1.0.pre.git.<sha>`.
