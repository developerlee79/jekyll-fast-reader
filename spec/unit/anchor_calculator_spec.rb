require "spec_helper"

RSpec.describe Jekyll::FastReader::AnchorCalculator do
  describe ".anchor_length" do
    {
      1 => 1,
      2 => 1,
      3 => 1,
      4 => 2,
      5 => 2,
      6 => 2,
      7 => 3,
      8 => 3,
      9 => 3,
      10 => 4,
      11 => 5,
      25 => 10
    }.each do |length, expected|
      it "returns #{expected} for word of length #{length}" do
        expect(described_class.anchor_length(length)).to eq(expected)
      end
    end
  end
end
