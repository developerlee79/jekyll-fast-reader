require "spec_helper"

RSpec.describe Jekyll::FastReader::DocumentFilter do
  let(:config) { Jekyll::FastReader::Configuration.new("enabled" => true, "collections" => ["posts"]) }
  subject(:filter) { described_class.new(config) }

  def make_doc(collection_label, front_matter = {})
    collection = double("collection", label: collection_label)
    double("document", collection: collection, data: front_matter)
  end

  it "allows documents in configured collection" do
    expect(filter.process?(make_doc("posts"))).to be true
  end

  it "denies documents not in configured collection" do
    expect(filter.process?(make_doc("pages"))).to be false
  end

  it "respects front matter false override" do
    expect(filter.process?(make_doc("posts", "fast_reader" => false))).to be false
  end

  it "respects front matter true override even for unconfigured collection" do
    expect(filter.process?(make_doc("pages", "fast_reader" => true))).to be true
  end

  context "when disabled globally" do
    let(:config) { Jekyll::FastReader::Configuration.new("enabled" => false, "collections" => ["posts"]) }

    it "denies all documents" do
      expect(filter.process?(make_doc("posts"))).to be false
    end
  end

  context "with hash-form collections" do
    let(:config) do
      Jekyll::FastReader::Configuration.new(
        "enabled"     => true,
        "collections" => { "posts" => true, "drafts" => false, "notes" => { "stop_words_extra" => ["jekyll"] } }
      )
    end

    it "allows documents in truthy collections" do
      expect(filter.process?(make_doc("posts"))).to be true
      expect(filter.process?(make_doc("notes"))).to be true
    end

    it "denies documents in collections mapped to false" do
      expect(filter.process?(make_doc("drafts"))).to be false
    end
  end
end
