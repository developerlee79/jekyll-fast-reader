# jekyll-fast-reader

[![Gem Version](https://badge.fury.io/rb/jekyll-fast-reader.svg)](https://badge.fury.io/rb/jekyll-fast-reader)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.txt)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%202.7-red.svg)](https://www.ruby-lang.org/)

Bionic Reading bolds the opening characters of each word so your eye anchors faster and your brain fills in the rest. This plugin wires that technique directly into your Jekyll build — no JavaScript, no manual markup.

- [Installation](#installation)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Liquid Filters](#liquid-filters)
- [How It Works](#how-it-works)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

<br>

## Installation

### With Bundler

```ruby
# Gemfile
gem "jekyll-fast-reader", "~> 0.1"
```

Then run:

```bash
bundle install
```

### Manual

```bash
gem install jekyll-fast-reader
```

Add the plugin to your site's `_config.yml`:

```yaml
plugins:
  - jekyll-fast-reader
```

Requires Jekyll >= 4.0, < 5.0 and Ruby >= 2.7.

### System dependencies

Nokogiri ships native extensions. On a fresh machine you may also need:

- **macOS:** `xcode-select --install`
- **Debian / Ubuntu:** `sudo apt install build-essential libxml2-dev libxslt1-dev`
- **Fedora / RHEL:** `sudo dnf install gcc make libxml2-devel libxslt-devel`

### Compatibility

Works alongside [`jekyll-polyglot`](https://github.com/untra/polyglot) — the stylesheet and toggle script are re-emitted on every language pass so each localized copy of the site gets its own asset under its language prefix.

<br>

## Getting Started

No template changes needed. Install the plugin and build — the stylesheet is injected into `<head>` automatically.

**Build and serve**

```bash
bundle exec jekyll serve
```

Words in configured collections will have their opening characters bolded. The plugin wraps anchors in `<span class="fr-anchor">` — for example:

```html
<!-- input -->
<p>The quick brown fox jumps</p>

<!-- output -->
<p>The <span class="fr-anchor">qu</span>ick <span class="fr-anchor">br</span>own <span class="fr-anchor">fo</span>x <span class="fr-anchor">ju</span>mps</p>
```

("The" is a stop word and is left unwrapped.)

<br>

## Configuration

If `_config.yml` defines `baseurl`, it is automatically prepended to both `css_output_path` and `js_output_path` so the injected `<link>` and `<script>` tags resolve under your site's prefix. Trailing slashes on `baseurl` are normalized.

All options are optional. Add a `fast_reader` key to `_config.yml` to override any default:

```yaml
fast_reader:
  enabled: true
  collections:
    - posts
  exclude_selectors:
    - code
    - pre
    - script
    - style
    - kbd
    - samp
  css_output_path: /assets/fast-reader.css
  stop_words_extra: []
  toggle: false
  default_on: true
```

| Key | Default | Description |
|-----|---------|-------------|
| `enabled` | `true` | Set to `false` to disable the plugin site-wide. To opt out a single document, use `fast_reader: false` in its front matter instead. |
| `collections` | `["posts"]` | Which Jekyll collections to process. Accepts either an Array of labels or a Hash mapping label → `true`/`false`/options-hash — see [Per-collection options](#per-collection-options). Pages do not belong to a collection — see [Per-document override](#per-document-override) to enable a single page. |
| `exclude_selectors` | see above | CSS selectors whose inner text is left untouched. **Replaces** the default list entirely — include the defaults if you want to keep them. |
| `css_output_path` | `"/assets/fast-reader.css"` | URL path for the generated stylesheet `<link>` |
| `js_output_path` | `"/assets/fast-reader.js"` | URL path for the toggle behavior script (only injected when `toggle: true`) |
| `stop_words_extra` | `[]` | Additional words to skip (merged with the built-in list) |
| `toggle` | `false` | Set to `true` to inject a fixed toggle button that enables/disables the effect at runtime without a rebuild. The button is wired by an external `fast-reader.js` (no inline `onclick`/`style`, CSP-safe) and persists state across navigation under `localStorage["fr-state"]` (`"on"` / `"off"`). Keyboard shortcut: <kbd>Alt</kbd>+<kbd>Shift</kbd>+<kbd>B</kbd>. |
| `default_on` | `true` | When `true`, anchors render bold by default; the toggle removes the effect by adding `fr-disabled` to `<body>`. When `false`, anchors render with inherited weight by default; the plugin marks `<body>` with `fr-opt-in` at build time, and the toggle activates the effect by also adding `fast-reader`. |

### Per-document override

Front matter flips the decision for a single document. Both opt-in and opt-out are supported:

```yaml
---
title: My Post
fast_reader: false   # opt this document out, even if its collection is processed
---
```

```yaml
---
title: A Standalone Page
fast_reader: true    # opt a page in, even though pages aren't in `collections`
---
```

Use `fast_reader: true` to enable Fast Reader on top-level pages (`about.md`, `index.html`, etc.) since they do not belong to any Jekyll collection.

### Stop words

Common words — articles, prepositions, short conjunctions — are skipped by default so they don't get distracting anchors. The built-in list is:

```
a, an, the, of, in, on, at, to, by, or, is, as,
and, but, for, nor, so, yet,
it, its, this, that
```

Matching is case-insensitive. Extend the list per site:

```yaml
fast_reader:
  stop_words_extra:
    - jekyll
    - ruby
```

### Per-element opt-out

Add `data-fr-skip` to any element to prevent its inner text (and all descendants) from being processed. Useful for callouts, brand names, or quoted blocks that should keep their original weight:

```html
<p>Most text gets bionic anchors.</p>
<aside data-fr-skip>
  <p>This block is left alone.</p>
</aside>
```

This is finer-grained than `exclude_selectors`, which is global, and does not require touching site config.

### Per-collection options

`collections` also accepts a Hash so you can tune per-collection behavior:

```yaml
fast_reader:
  stop_words_extra: [jekyll]
  collections:
    posts: true                                  # default behavior
    drafts: false                                # explicitly skipped
    notes:
      stop_words_extra: [observability, cache]   # adds to the global list, for this collection only
```

`true` is equivalent to listing the label in the legacy Array form. `false` skips the collection even if it exists. A Hash value lets you override `stop_words_extra` per collection — values are concatenated ahead of the global list (per-collection words win on duplicates).

### Accessibility

- **Keyboard shortcut.** When `toggle: true`, the button can be flipped with <kbd>Alt</kbd>+<kbd>Shift</kbd>+<kbd>B</kbd>. The shortcut is suppressed while focus is inside an `<input>`, `<textarea>`, `<select>`, or any `contenteditable` element, so it never blocks typing. The button advertises this via `aria-keyshortcuts="Alt+Shift+B"` for assistive tech.
- **Focus indicator.** `#fr-toggle:focus-visible` paints a 2 px outline so keyboard users can see when the button is focused.
- **Reduced motion / visual emphasis.** Users with `prefers-reduced-motion: reduce` set in their OS get a stylesheet rule that resets `.fr-anchor` back to inherited weight — the bionic anchors disappear without requiring them to click the toggle.
- **Print.** Anchors are also reset when printing (`@media print`), so the printed output matches normal weight.

<br>

## Liquid Filters

The plugin registers three Liquid filters you can use anywhere in your templates:

| Filter | Description |
|--------|-------------|
| `reading_time` | Returns a string like `"4 min"` based on a 250 wpm reading rate. HTML tags are stripped before counting. |
| `word_count` | Returns the integer word count of the input, ignoring HTML tags. |
| `fast_reader` | Wraps anchors around the words of a plain string — useful for excerpts, headings, or any text you want anchored without going through the document-level pipeline. Honors site-level `stop_words_extra`. |

```liquid
<p class="meta">{{ content | reading_time }} · {{ content | word_count }} words</p>

<h2>{{ post.title | fast_reader }}</h2>
```

<br>

## How It Works

On each Jekyll build the plugin registers a post-render hook. For every document in the configured collections (and any page or document with `fast_reader: true` in its front matter) it:

1. Parses the rendered HTML with Nokogiri
2. Walks all text nodes, skipping `exclude_selectors`
3. Tokenizes text into words, whitespace, and punctuation
4. Skips stop words, tokens containing digits, and non-Latin tokens
5. Wraps the opening characters of each qualifying word in `<span class="fr-anchor">`
6. Replaces each text node with the enhanced fragment

The shipped stylesheet supports both `default_on` modes:

```css
/* default_on: true (default) — bold by default, toggle disables */
.fr-anchor              { font-weight: bold; }
.fr-disabled .fr-anchor { font-weight: inherit; }

/* default_on: false — inherited weight by default, toggle activates */
.fr-opt-in .fr-anchor              { font-weight: inherit; }
.fr-opt-in.fast-reader .fr-anchor  { font-weight: bold; }
```

In `default_on: false` mode the plugin adds `fr-opt-in` to `<body>` at build time so the second pair of selectors becomes active. The toggle button (when enabled) flips the appropriate body class for the current mode.

The toggle button carries `data-fr-mode="default-on"` or `data-fr-mode="opt-in"`; the external `fast-reader.js` reads that attribute to decide whether to flip `fr-disabled` or `fast-reader` on `<body>`, then mirrors the choice into `localStorage["fr-state"]` so it sticks across pages.

Anchor length scales with word length:

| Word length | Bolded characters |
|-------------|-------------------|
| 1–3 | 1 |
| 4–6 | 2 |
| 7–9 | 3 |
| 10+ | 40% (ceiling) |

<br>

## Development

```bash
bundle install
bundle exec rake spec   # run the test suite (RSpec, with SimpleCov coverage)
```

<br>

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/developerlee79/jekyll-fast-reader). This project is intended to be a safe, welcoming space for collaboration.

<br>

## License

[MIT](LICENSE.txt)
