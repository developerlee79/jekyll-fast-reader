module Jekyll
  module FastReader
    class AnchorCalculator
      BUCKET_MAP = {
        1 => 1,
        2 => 1,
        3 => 1,
        4 => 2,
        5 => 2,
        6 => 2,
        7 => 3,
        8 => 3,
        9 => 3
      }.freeze

      LONG_WORD_RATIO = 0.4

      def self.anchor_length(word_length)
        BUCKET_MAP.fetch(word_length) { (word_length * LONG_WORD_RATIO).ceil }
      end
    end
  end
end
