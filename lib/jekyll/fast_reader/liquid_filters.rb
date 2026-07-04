require "liquid"
require "nokogiri"

module Jekyll
  module FastReader
    module LiquidFilters
      WORDS_PER_MINUTE = 250

      def reading_time(input)
        minutes = (fr_word_count(input).to_f / WORDS_PER_MINUTE).ceil
        minutes = 1 if minutes < 1
        "#{minutes} min"
      end

      def word_count(input)
        fr_word_count(input)
      end

      def fast_reader(input)
        config    = fr_site_config
        processor = TextProcessor.new(StopWords.new(config.stop_words_extra))
        processor.process(input.to_s)
      end

      private

      def fr_word_count(input)
        Nokogiri::HTML.fragment(input.to_s).text.scan(/\S+/).length
      end

      def fr_site_config
        site = @context && @context.registers && @context.registers[:site]
        site&.instance_variable_get(:@fast_reader_config) || Configuration.new({})
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::FastReader::LiquidFilters)
