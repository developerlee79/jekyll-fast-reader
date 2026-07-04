require "spec_helper"

RSpec.describe Jekyll::FastReader::Tokenizer do
  describe ".tokenize" do
    it "splits a simple sentence" do
      result = described_class.tokenize("hello world")
      expect(result).to eq([[:word, "hello"], [:whitespace, " "], [:word, "world"]])
    end

    it "handles punctuation" do
      result = described_class.tokenize("hello, world!")
      expect(result).to include([:word, "hello"], [:word, "world"])
      expect(result.map(&:first)).to include(:punctuation)
    end

    it "keeps apostrophes inside words" do
      result = described_class.tokenize("don't")
      expect(result).to eq([[:word, "don't"]])
    end

    it "keeps hyphens inside words" do
      result = described_class.tokenize("state-of-the-art")
      expect(result).to eq([[:word, "state-of-the-art"]])
    end

    it "handles empty string" do
      expect(described_class.tokenize("")).to eq([])
    end

    it "emits whitespace tokens" do
      result = described_class.tokenize("a  b")
      expect(result).to include([:whitespace, "  "])
    end
  end
end
