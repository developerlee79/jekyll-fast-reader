module Jekyll
  module FastReader
    # Single source of truth for the character classes shared by the tokenizer
    # and the text processor. Keeping these in one place prevents the regexes
    # from drifting apart (which previously caused inconsistent handling of the
    # left curly quote U+2018).
    module Characters
      # Non-letter characters allowed inside a word: straight apostrophe (\x27),
      # left/right curly quotes (U+2018/U+2019), and hyphen. Written as escapes
      # so the source stays unambiguous in any editor.
      INNER_JOINERS = "\\x27\\u2018\\u2019\\-".freeze

      # Matches one such joiner, e.g. for stripping them before counting letters.
      INNER_JOINERS_CLASS = /[#{INNER_JOINERS}]/.freeze

      # Matches a single latin word, which must start and end with a letter and
      # may contain joiners in between.
      WORD = /[a-zA-Z](?:[a-zA-Z#{INNER_JOINERS}]*[a-zA-Z])?/.freeze
    end
  end
end
