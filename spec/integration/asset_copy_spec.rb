require "spec_helper"

RSpec.describe Jekyll::FastReader::AssetStaticFile do
  let(:site) { double("site", static_files: [], instance_variable_get: nil) }

  it "resolves the gem-bundled CSS path" do
    gem_root = File.expand_path("../../..", described_class::GEM_ROOT)
    css_path = File.join(described_class::GEM_ROOT, "assets", "fast-reader.css")
    expect(File).to exist(css_path)
  end
end
