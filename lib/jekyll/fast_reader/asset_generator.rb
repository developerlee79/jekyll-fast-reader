module Jekyll
  module FastReader
    class AssetGenerator < Jekyll::Generator
      priority :low

      def generate(site)
        config = site.instance_variable_get(:@fast_reader_config)
        return unless config&.enabled?

        ensure_asset(site, "fast-reader.css")
        ensure_asset(site, "fast-reader.js") if config.toggle
      end

      private

      def ensure_asset(site, filename)
        return if site.static_files.any? { |f| f.is_a?(AssetStaticFile) && f.name == filename }

        site.static_files << AssetStaticFile.new(site, filename)
      end
    end
  end
end
