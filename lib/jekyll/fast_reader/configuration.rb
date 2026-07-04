module Jekyll
  module FastReader
    class Configuration
      DEFAULTS = {
        "enabled"            => true,
        "collections"        => ["posts"],
        "exclude_selectors"  => %w[code pre script style kbd samp],
        "css_output_path"    => "/assets/fast-reader.css",
        "js_output_path"     => "/assets/fast-reader.js",
        "stop_words_extra"   => [],
        "toggle"             => false,
        "default_on"         => true
      }.freeze

      attr_reader :exclude_selectors, :css_output_path, :js_output_path,
                  :stop_words_extra, :baseurl, :toggle, :default_on

      def self.from(site)
        new(site.config["fast_reader"] || {}, site.config["baseurl"].to_s.chomp("/"))
      end

      def initialize(config, baseurl = "")
        merged             = DEFAULTS.merge(config)
        @enabled           = merged["enabled"]
        @collections_map   = normalize_collections(merged["collections"])
        @exclude_selectors = Array(merged["exclude_selectors"])
        @css_output_path   = merged["css_output_path"]
        @js_output_path    = merged["js_output_path"]
        @stop_words_extra  = Array(merged["stop_words_extra"]).map(&:to_s)
        @toggle            = merged["toggle"]
        @default_on        = merged["default_on"]
        @baseurl           = baseurl
        freeze
      end

      def enabled?
        @enabled
      end

      def collection_enabled?(label)
        return false unless @collections_map.key?(label)

        @collections_map[label] != false
      end

      def stop_words_for(label)
        options = @collections_map[label]
        return @stop_words_extra unless options.is_a?(Hash)

        per_collection = Array(options["stop_words_extra"]).map(&:to_s)
        per_collection + @stop_words_extra
      end

      private

      def normalize_collections(value)
        case value
        when Array
          value.each_with_object({}) { |label, h| h[label.to_s] = true }
        when Hash
          value.each_with_object({}) do |(k, v), h|
            h[k.to_s] = normalize_collection_value(v)
          end
        else
          {}
        end
      end

      def normalize_collection_value(value)
        return false if value == false
        return value.transform_keys(&:to_s) if value.is_a?(Hash)

        true
      end
    end
  end
end
