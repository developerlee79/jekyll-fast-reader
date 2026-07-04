require "spec_helper"

RSpec.describe Jekyll::FastReader::StopWords do
  subject(:stop_words) { described_class.new }

  it "identifies default stop words" do
    expect(stop_words.stop?("the")).to be true
    expect(stop_words.stop?("a")).to   be true
    expect(stop_words.stop?("of")).to  be true
  end

  it "is case-insensitive" do
    expect(stop_words.stop?("The")).to be true
    expect(stop_words.stop?("THE")).to be true
  end

  it "returns false for non-stop words" do
    expect(stop_words.stop?("quick")).to be false
    expect(stop_words.stop?("fox")).to   be false
  end

  context "with extra stop words" do
    subject(:stop_words) { described_class.new(["custom", "EXTRA"]) }

    it "includes extra stop words" do
      expect(stop_words.stop?("custom")).to be true
      expect(stop_words.stop?("extra")).to  be true
    end
  end
end
