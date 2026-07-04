require "cgi"

module Jekyll
  module FastReader
    class TextProcessor
      def initialize(stop_words)
        @stop_words = stop_words
      end

      def process(text)
        Tokenizer.tokenize(text).map { |type, value| transform(type, value) }.join
      end

      private

      def transform(type, value)
        return CGI.escape_html(value) if type == :punctuation
        return value unless type == :word
        return value if @stop_words.stop?(value)

        value.include?("-") ? wrap_hyphenated(value) : wrap_simple(value)
      end

      def wrap_hyphenated(word)
        word.split("-").map { |part| wrap_simple(part) }.join("-")
      end

      def wrap_simple(word)
        letters    = word.gsub(Characters::INNER_JOINERS_CLASS, "")
        return CGI.escape_html(word) if letters.empty?

        anchor_len = AnchorCalculator.anchor_length(letters.length)
        split_at   = find_split_position(word, anchor_len)
        anchor     = word[0...split_at]
        rest       = word[split_at..]

        return CGI.escape_html(word) if rest.nil? || rest.empty?

        %(<span class="fr-anchor">#{CGI.escape_html(anchor)}</span>#{CGI.escape_html(rest)})
      end

      def find_split_position(word, anchor_len)
        letter_count = 0
        word.each_char.with_index do |char, i|
          letter_count += 1 if char.match?(/[a-zA-Z]/)
          return i + 1 if letter_count >= anchor_len
        end
        word.length
      end
    end
  end
end
