require_relative "lib/jekyll/fast_reader/version"

Gem::Specification.new do |spec|
  spec.name    = "jekyll-fast-reader"
  spec.version = Jekyll::FastReader::VERSION
  spec.authors = ["developerlee79"]
  spec.email   = ["developerlee79@users.noreply.github.com"]

  spec.summary     = "Jekyll plugin for accelerated reading via visual word anchoring"
  spec.description = "Transforms Jekyll post HTML by bolding the initial characters of each word, optimised for fast visual reading. Toggle on/off via a CSS class."
  spec.homepage    = "https://github.com/developerlee79/jekyll-fast-reader"
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files         = Dir["lib/**/*", "assets/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jekyll",   ">= 4.0", "< 5.0"
  spec.add_runtime_dependency "nokogiri", ">= 1.15.6", "< 2.0"

  spec.add_development_dependency "rspec",     "~> 3.12"
  spec.add_development_dependency "rake",      "~> 13.0"
  spec.add_development_dependency "simplecov", "~> 0.22"
end
