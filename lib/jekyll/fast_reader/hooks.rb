module Jekyll
  module FastReader
    module Hooks
      def self.register!
        Jekyll::Hooks.register :site, :after_init do |site|
          config = Configuration.from(site)
          site.instance_variable_set(:@fast_reader_config, config)
          site.instance_variable_set(:@fast_reader_filter, DocumentFilter.new(config))
          site.instance_variable_set(:@fast_reader_transformer, Transformer.new(config))
        end

        %i[documents pages].each do |scope|
          Jekyll::Hooks.register scope, :post_render do |renderable|
            apply_transform(renderable)
          end
        end
      end

      def self.apply_transform(renderable)
        site        = renderable.site
        config      = site.instance_variable_get(:@fast_reader_config)
        filter      = site.instance_variable_get(:@fast_reader_filter)
        transformer = site.instance_variable_get(:@fast_reader_transformer)
        return unless config && filter && transformer && filter.process?(renderable)

        label      = renderable.collection&.label if renderable.respond_to?(:collection)
        stop_words = label ? config.stop_words_for(label) : config.stop_words_extra
        renderable.output = transformer.call(renderable.output, stop_words: stop_words)
      end
      private_class_method :apply_transform
    end
  end
end
