require "spec_helper"
require "fileutils"

RSpec.describe "Full site build", type: :integration do
  let(:fixture_source) { File.expand_path("../fixtures/site", __dir__) }
  let(:site_dest)      { File.join(fixture_source, "_site") }

  let(:site) do
    config = Jekyll.configuration(
      "source"      => fixture_source,
      "destination" => site_dest,
      "fast_reader" => { "enabled" => true, "collections" => ["posts"] }
    )
    Jekyll::Site.new(config)
  end

  before(:all) do
    @fixture_source = File.expand_path("../fixtures/site", __dir__)
    @site_dest      = File.join(@fixture_source, "_site")
    config = Jekyll.configuration("source" => @fixture_source, "destination" => @site_dest)
    site   = Jekyll::Site.new(config)
    site.process
  end

  after(:all) { FileUtils.rm_rf(@site_dest) }

  it "injects fr-anchor spans into post output" do
    post_files = Dir[File.join(@site_dest, "**", "*.html")]
    post_content = post_files.filter_map { |f| File.read(f) if f.include?("test-post") }.first
    expect(post_content).to include('class="fr-anchor"')
  end

  it "copies the CSS asset to the site output" do
    css_path = File.join(@site_dest, "assets", "fast-reader.css")
    expect(File).to exist(css_path)
  end

  it "auto-injects stylesheet link into <head> without manual tag" do
    post_files = Dir[File.join(@site_dest, "**", "*.html")]
    post_content = post_files.filter_map { |f| File.read(f) if f.include?("test-post") }.first
    expect(post_content).to include('href="/assets/fast-reader.css"')
  end
end
