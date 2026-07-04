# Changelog

All notable changes to this project are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Centralised the latin-word and inner-word-joiner regular expressions into a
  single `Jekyll::FastReader::Characters` module so the tokenizer and text
  processor can no longer drift apart.

### Fixed
- The left curly quote (U+2018) is now treated like the right curly quote and a
  straight apostrophe when sizing a word's anchor. Previously a `‘` between two
  letters inflated the letter count and produced a too-long anchor. (Note: this
  only affects words with a `‘` mid-word, which does not occur in normal text;
  the change is primarily a consistency fix.)

### Removed
- Deleted the unused `WordClassifier` class and its spec; it was never wired
  into the transform pipeline.
- Removed the unused `Configuration#collections` method (the runtime path uses
  `collection_enabled?`); verified dead before removal.

## [0.1.0]

- Initial release: bold the leading characters of each word in rendered Jekyll
  output for faster visual reading, with CSS-class toggling and an optional
  floating toggle button.
