require "spec_helper"

RSpec.describe Jekyll::FastReader::TextProcessor do
  let(:stop_words) { Jekyll::FastReader::StopWords.new }
  subject(:processor) { described_class.new(stop_words) }

  it "wraps the anchor portion of a word" do
    result = processor.process("quick")
    expect(result).to include('<span class="fr-anchor">qu</span>ick')
  end

  it "skips stop words" do
    result = processor.process("the quick")
    expect(result).not_to match(/<span[^>]*>the</)
    expect(result).to include('<span class="fr-anchor">')
  end

  it "handles hyphenated words per sub-word" do
    result = processor.process("well-known")
    expect(result).to include("fr-anchor")
  end

  it "escapes HTML special characters" do
    result = processor.process("bread&butter")
    expect(result).to include("&amp;")
  end

  it "leaves non-latin text unchanged" do
    result = processor.process("안녕하세요")
    expect(result).to eq("안녕하세요")
  end

  it "treats a left curly quote like an apostrophe when sizing the anchor" do
    # "cat" has 3 letters -> 1-char anchor; the quote must not inflate the count.
    result = processor.process("c‘at")
    expect(result).to eq("<span class=\"fr-anchor\">c</span>‘at")
  end
end
