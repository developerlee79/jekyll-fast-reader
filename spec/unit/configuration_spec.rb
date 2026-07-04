require "spec_helper"

RSpec.describe Jekyll::FastReader::Configuration do
  describe ".from" do
    let(:site) { double("site", config: site_config) }

    context "with no fast_reader config" do
      let(:site_config) { {} }

      it "applies defaults" do
        config = described_class.from(site)
        expect(config.enabled?).to        be true
        expect(config.css_output_path).to eq("/assets/fast-reader.css")
        expect(config.toggle).to          be false
        expect(config.default_on).to      be true
        expect(config.baseurl).to         eq("")
      end
    end

    context "with default_on: false" do
      let(:site_config) { { "fast_reader" => { "default_on" => false } } }

      it "captures opt-in mode" do
        config = described_class.from(site)
        expect(config.default_on).to be false
      end
    end

    context "with partial user config" do
      let(:site_config) { { "fast_reader" => { "collections" => ["posts", "articles"] } } }

      it "merges user config with defaults" do
        config = described_class.from(site)
        expect(config.enabled?).to be true
      end
    end

    context "with enabled: false" do
      let(:site_config) { { "fast_reader" => { "enabled" => false } } }

      it "is disabled" do
        config = described_class.from(site)
        expect(config.enabled?).to be false
      end
    end

    context "with toggle: true" do
      let(:site_config) { { "fast_reader" => { "toggle" => true } } }

      it "enables toggle" do
        config = described_class.from(site)
        expect(config.toggle).to be true
      end
    end

    context "with site baseurl" do
      let(:site_config) { { "baseurl" => "/blog" } }

      it "captures baseurl" do
        config = described_class.from(site)
        expect(config.baseurl).to eq("/blog")
      end
    end

    context "with trailing slash in baseurl" do
      let(:site_config) { { "baseurl" => "/blog/" } }

      it "strips trailing slash" do
        config = described_class.from(site)
        expect(config.baseurl).to eq("/blog")
      end
    end

    context "with hash-form collections" do
      let(:site_config) do
        {
          "fast_reader" => {
            "collections" => {
              "posts"  => true,
              "drafts" => false,
              "notes"  => { "stop_words_extra" => ["jekyll"] }
            }
          }
        }
      end

      it "treats truthy entries as enabled" do
        config = described_class.from(site)
        expect(config.collection_enabled?("posts")).to be true
        expect(config.collection_enabled?("notes")).to be true
      end

      it "treats false entries as disabled" do
        config = described_class.from(site)
        expect(config.collection_enabled?("drafts")).to be false
      end

      it "treats unlisted labels as disabled" do
        config = described_class.from(site)
        expect(config.collection_enabled?("articles")).to be false
      end

      it "merges per-collection stop_words_extra ahead of the global list" do
        config = described_class.from(site)
        expect(config.stop_words_for("notes")).to include("jekyll")
      end

      it "falls back to global stop_words for plain entries" do
        config = described_class.from(site)
        expect(config.stop_words_for("posts")).to eq(config.stop_words_extra)
      end
    end

    context "with global stop_words_extra and per-collection overrides" do
      let(:site_config) do
        {
          "fast_reader" => {
            "stop_words_extra" => ["global"],
            "collections"      => { "posts" => { "stop_words_extra" => ["local"] } }
          }
        }
      end

      it "concatenates per-collection then global stop words" do
        config = described_class.from(site)
        expect(config.stop_words_for("posts")).to eq(["local", "global"])
      end
    end

    context "with default js_output_path" do
      let(:site_config) { {} }

      it "exposes the default JS asset path" do
        config = described_class.from(site)
        expect(config.js_output_path).to eq("/assets/fast-reader.js")
      end
    end
  end
end
