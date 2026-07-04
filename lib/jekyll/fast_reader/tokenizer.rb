module Jekyll
  module FastReader
    class Tokenizer
      PATTERN = /(#{Characters::WORD})|(\s+)|([^\sa-zA-Z]+)/

      def self.tokenize(text)
        text.scan(PATTERN).map do |word, whitespace, punctuation|
          if word
            [:word, word]
          elsif whitespace
            [:whitespace, whitespace]
          else
            [:punctuation, punctuation]
          end
        end
      end
    end
  end
end
