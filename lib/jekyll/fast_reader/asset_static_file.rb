module Jekyll
  module FastReader
    class AssetStaticFile < Jekyll::StaticFile
      GEM_ROOT = File.expand_path("../../..", __dir__).freeze

      def initialize(site, filename = "fast-reader.css")
        super(site, GEM_ROOT, "assets", filename)
      end

      # Jekyll::StaticFile caches source mtimes at the class level (::mtimes).
      # With jekyll-polyglot, multiple language passes share the same process,
      # so the cache entry written by the default-lang pass causes subsequent
      # passes to see modified? == false and skip writing the language-prefixed
      # copy. Always returning true ensures every pass writes its own copy.
      def modified?
        true
      end
    end
  end
end
