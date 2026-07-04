module Jekyll
  module FastReader
    class DocumentFilter
      def initialize(config)
        @config = config
      end

      def process?(document)
        return false unless @config.enabled?

        override = front_matter_override(document)
        return override unless override.nil?

        in_configured_collection?(document)
      end

      private

      def front_matter_override(document)
        return nil unless document.respond_to?(:data)

        value = document.data["fast_reader"]
        return nil unless value == true || value == false

        value
      end

      def in_configured_collection?(document)
        return false unless document.respond_to?(:collection)
        return false if document.collection.nil?

        @config.collection_enabled?(document.collection.label)
      end
    end
  end
end
