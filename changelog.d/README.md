# Changelog fragments

A pull request adds one file here, `changelog.d/<branch-slug>.md`, and never edits `CHANGELOG.md`. The release workflow reads every fragment on `main`, stamps the next version and deletes the fragments it used.

```markdown
---
level: minor
---

### Added
- **Name** — what an app gets.
```

`level` is `patch`, `minor` or `major`. A `major` fragment needs a numbered `### Upgrading` section; a lower level must not have one. Sections are `### Added`, `### Changed`, `### Fixed` and `### Upgrading`.

An optional `overrides` key accepts a removal of public surface below `major`: `overrides: {token: "reason"}`. The key is a rule id (`token`, `file`, `class`, `data_attribute`, `importmap_pin`) and the reason is required.
