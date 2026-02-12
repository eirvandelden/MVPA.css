# MVPA.css – Minimal Viable Product CSS Framework

A personal CSS framework for building web applications with modern, classless semantic HTML5 design.

## Philosophy

MVPA.css is built on the principle that **semantic HTML5 elements should look beautiful by default**. Rather than littering code with CSS classes, this framework styles semantic elements directly — `<article>`, `<section>`, `<nav>`, `<aside>`, `<header>`, `<main>`, `<footer>` — creating clean, maintainable markup.

The framework follows **SMACSS (Scalable and Modular Architecture for CSS)** principles, organizing styles into settings, base, layout, components, and themes. It uses **OKLCH color space** for perceptually uniform colors and the **37signals spacing system** (1ch × 1rem base) for consistent rhythm.

## Features

- **Classless by default** – Semantic HTML5 elements are automatically styled
- **Four professional themes** – Selenized Light/Dark, Pure White, Pure Black
- **Automatic dark mode** – Respects system preferences with manual override capability
- **OKLCH color space** – Perceptually uniform, modern color handling
- **Responsive design** – Mobile-first approach with 768px breakpoint
- **37signals spacing** – Consistent rhythm: 1ch inline, 1rem block
- **Minimal classes** – Only button variants use classes (`.button-success`, `.button-danger`, `.button-warning`, `.button-secondary`)
- **Browser support** – Modern browsers with OKLCH support (Chrome 111+, Firefox 113+, Safari 16.4+)

## Installation

### Import the CSS

Add these imports to your HTML in the correct order:

```html
<!-- Settings & Variables -->
<link rel="stylesheet" href="css/0_settings/0_colors.css">
<link rel="stylesheet" href="css/0_settings/1_variables.css">

<!-- Base Styles -->
<link rel="stylesheet" href="css/1_base/0_reset.css">
<link rel="stylesheet" href="css/1_base/1_typography.css">
<link rel="stylesheet" href="css/1_base/2_tables.css">
<link rel="stylesheet" href="css/1_base/3_forms.css">
<link rel="stylesheet" href="css/1_base/4_details.css">

<!-- Layout -->
<link rel="stylesheet" href="css/2_layout/0_header.css">
<link rel="stylesheet" href="css/2_layout/1_main.css">
<link rel="stylesheet" href="css/2_layout/2_footer.css">

<!-- Components -->
<link rel="stylesheet" href="css/3_components/0_flash.css">
<link rel="stylesheet" href="css/3_components/1_errors.css">
<link rel="stylesheet" href="css/3_components/2_buttons.css">
<link rel="stylesheet" href="css/3_components/3_progress.css">
<link rel="stylesheet" href="css/3_components/4_definition_list.css">
<link rel="stylesheet" href="css/3_components/5_article.css">
<link rel="stylesheet" href="css/3_components/6_mark.css">

<!-- Themes -->
<link rel="stylesheet" href="css/4_themes/0_themes.css">
```

### Set theme attributes on the HTML element

```html
<html data-color-scheme="system" data-theme="selenized_light">
  <!-- content -->
</html>
```

- `data-color-scheme`: `"system"` (default), `"light"`, or `"dark"`
- `data-theme`: `"selenized_light"` (default), `"selenized_dark"`, `"white"`, or `"black"`

## File Structure

The framework follows SMACSS organization with numbered prefixes:

```
css/
├── 0_settings/          # Variables and color definitions
│   ├── 0_colors.css
│   └── 1_variables.css
├── 1_base/              # Resets and base element styles
│   ├── 0_reset.css
│   ├── 1_typography.css
│   ├── 2_tables.css
│   ├── 3_forms.css
│   └── 4_details.css
├── 2_layout/            # Page structure (header, main, footer)
│   ├── 0_header.css
│   ├── 1_main.css
│   └── 2_footer.css
├── 3_components/        # Reusable components
│   ├── 0_flash.css
│   ├── 1_errors.css
│   ├── 2_buttons.css
│   ├── 3_progress.css
│   ├── 4_definition_list.css
│   ├── 5_article.css
│   └── 6_mark.css
└── 4_themes/            # Theme switching logic
    └── 0_themes.css
```

## Theme System

MVPA.css supports four theme variants with automatic dark mode switching:

### Theme Variants

- **Selenized Light** (default light theme) – Based on the Selenized color scheme, warm and pleasant
- **Selenized Dark** (default dark theme) – Dark counterpart to Selenized Light
- **Pure White** – Clean, minimal white background
- **Pure Black** – Maximalist pure black background

### Setting Themes Programmatically

```javascript
// Get current theme
const currentTheme = document.documentElement.getAttribute('data-theme');
const colorScheme = document.documentElement.getAttribute('data-color-scheme');

// Switch to a specific theme
document.documentElement.setAttribute('data-theme', 'white');
document.documentElement.setAttribute('data-color-scheme', 'light');

// Respect system preference
document.documentElement.setAttribute('data-color-scheme', 'system');

// Switch to dark mode
document.documentElement.setAttribute('data-color-scheme', 'dark');
document.documentElement.setAttribute('data-theme', 'selenized_dark');

// Persist preference to localStorage
localStorage.setItem('mvpa-theme', 'white');
localStorage.setItem('mvpa-color-scheme', 'dark');
```

### Color Scheme Values

- `system` – Follows the user's OS preference (default)
- `light` – Forces light mode
- `dark` – Forces dark mode

## Components & Elements

### Typography

All headings (`<h1>` through `<h6>`), paragraphs (`<p>`), and text elements are automatically styled:

- **Headings** – Sized from `--text-xx-large` (h1) to `--text-small` (h6)
- **Paragraphs** – `1rem` line height, max-width constrained
- **Links** – Blue primary color, underline on hover, violet when visited
- **Code elements** – `<code>`, `<kbd>`, `<samp>` have dark background
- **Pre blocks** – `<pre>` for code blocks with horizontal scroll
- **Lists** – `<ul>` and `<ol>` with proper indentation
- **Blockquotes** – Left-aligned with border accent

### Forms

All form elements are automatically styled without classes:

- **Text inputs** – All types: `text`, `email`, `password`, `url`, `tel`, `number`, `date`, `time`, `color`
- **Textarea** – Multi-line text input
- **Select** – Dropdown menus
- **Checkboxes & Radios** – Both inline and stacked
- **Fieldsets** – Group form controls with legend
- **Labels** – Associated with inputs
- **Small text** – Helper text and descriptions with `<small>`
- **Invalid state** – Displays red border and error styling

### Buttons

Buttons are styled with semantic color variants using classes:

- **Default** – `<button>` – Primary blue
- **Success** – `<button class="button-success">` – Green
- **Danger** – `<button class="button-danger">` – Red
- **Warning** – `<button class="button-warning">` – Yellow
- **Secondary** – `<button class="button-secondary">` – Gray
- **Disabled** – `<button disabled>` – Reduced opacity

### Tables

Semantic table elements are automatically styled:

- `<table>` – Full width table
- `<thead>`, `<tbody>`, `<tfoot>` – Grouped rows
- `<th>`, `<td>` – Header and data cells
- Header row styling – Darker background

### Messages

#### Flash Messages (Success/Info)
Use `<section role="status">` for positive feedback:
```html
<section role="status">
  <p>Your changes have been saved successfully.</p>
</section>
```

#### Error Messages
Use `<aside role="alert">` for errors:
```html
<aside role="alert">
  <h3>Error</h3>
  <ul>
    <li>Email is required</li>
    <li>Password must be 8+ characters</li>
  </ul>
</aside>
```

### Progress Bars

`<progress>` elements show task completion:

```html
<progress value="65" max="100"></progress>
```

### Definition Lists

Use `<dl>`, `<dt>`, `<dd>` for key-value pairs:

```html
<dl>
  <dt>Framework</dt>
  <dd>MVPA.css</dd>
  <dt>Version</dt>
  <dd>1.0</dd>
</dl>
```

### Articles

`<article>` elements are styled with background and border:

```html
<article>
  <h2>Article Title</h2>
  <p>Article content goes here.</p>
</article>
```

### Details/Summary

Disclosure widgets for expandable content:

```html
<details>
  <summary>Click to expand</summary>
  <p>Hidden content revealed on click.</p>
</details>
```

### Highlights

`<mark>` elements highlight text with yellow background:

```html
This text is <mark>highlighted</mark>.
```

## Design Tokens

All design values are defined as CSS custom properties for easy customization.

### Colors

**Background shades** (light to dark):
- `--color-bg-lightest`
- `--color-bg-lighter`
- `--color-bg`
- `--color-bg-darker`
- `--color-bg-darkest`

**Foreground shades** (dark to light):
- `--color-fg-darkest`
- `--color-fg-darker`
- `--color-fg`
- `--color-fg-lighter`
- `--color-fg-lightest`

**Semantic colors**:
- `--color-primary` – Blue for links and focus
- `--color-success` – Green for positive actions
- `--color-danger` – Red for destructive actions
- `--color-warning` – Yellow for caution
- `--color-info` – Cyan for information

**Chromatic colors**:
- `--color-red`, `--color-green`, `--color-yellow`, `--color-blue`
- `--color-magenta`, `--color-cyan`, `--color-orange`, `--color-violet`

### Spacing System (37signals)

**Inline spacing** (horizontal, in `ch` units):
- `--inline-space: 1ch`
- `--inline-space-half: 0.5ch`
- `--inline-space-double: 2ch`
- `--inline-space-triple: 3ch`
- `--inline-space-quad: 4ch`

**Block spacing** (vertical, in `rem` units):
- `--block-space: 1rem`
- `--block-space-half: 0.5rem`
- `--block-space-double: 2rem`
- `--block-space-triple: 3rem`
- `--block-space-quad: 4rem`

### Typography Scale

- `--text-xx-small: 0.65rem`
- `--text-x-small: 0.75rem`
- `--text-small: 0.85rem`
- `--text-normal: 1rem` (default)
- `--text-medium: 1.1rem`
- `--text-large: 1.5rem`
- `--text-x-large: 2rem`
- `--text-xx-large: 2.5rem`

### Line Heights

- `--line-height-tight: 1.2` – Headings
- `--line-height-normal: 1.5` – Body text (default)
- `--line-height-loose: 1.8` – Accessible text

### Border Radius

- `--radius-small: 0.25rem`
- `--radius: 0.5rem` (default)
- `--radius-large: 1rem`

### Transitions

- `--transition-fast: 150ms ease-in-out`
- `--transition: 250ms ease-in-out` (default)
- `--transition-slow: 400ms ease-in-out`

### Z-Index Stack

- `--z-base: 1`
- `--z-dropdown: 100`
- `--z-sticky: 200`
- `--z-modal: 1000`
- `--z-notification: 1100`

### Max Widths

- `--max-width-text: 65ch` – Single-column text content
- `--max-width-content: 80ch` – Multi-column content
- `--max-width-wide: 1200px` – Wide layouts

## Browser Compatibility

MVPA.css requires modern browsers with support for:

- **OKLCH color space** – Modern, perceptually uniform colors
- **CSS custom properties** – Dynamic theming
- **CSS Grid & Flexbox** – Modern layout
- **Focus-visible** – Better accessibility

### Minimum versions:
- Chrome 111+
- Firefox 113+
- Safari 16.4+
- Edge 111+

## License

Personal project. Use freely in your own projects.
