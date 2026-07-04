require "spec_helper"
require "liquid"

RSpec.describe Jekyll::FastReader::LiquidFilters do
  def render(template, assigns = {}, registers = {})
    Liquid::Template.parse(template).render!(assigns, registers: registers)
  end

  describe "reading_time" do
    it "returns at least 1 min for short input" do
      result = render("{{ text | reading_time }}", "text" => "short")
      expect(result).to eq("1 min")
    end

    it "scales with longer input" do
      words  = (["lorem"] * 800).join(" ")
      result = render("{{ text | reading_time }}", "text" => words)
      expect(result).to eq("4 min")
    end

    it "strips HTML before counting" do
      html   = "<p>" + (["lorem"] * 250).join(" ") + "</p>"
      result = render("{{ text | reading_time }}", "text" => html)
      expect(result).to eq("1 min")
    end
  end

  describe "word_count" do
    it "counts whitespace-separated tokens" do
      result = render("{{ text | word_count }}", "text" => "the quick brown fox")
      expect(result).to eq("4")
    end

    it "ignores HTML tags" do
      result = render("{{ text | word_count }}", "text" => "<p>hello <em>world</em></p>")
      expect(result).to eq("2")
    end
  end

  describe "fast_reader" do
    it "wraps anchors around plain text words" do
      result = render("{{ text | fast_reader }}", "text" => "hello world")
      expect(result).to include('<span class="fr-anchor">he</span>llo')
      expect(result).to include('<span class="fr-anchor">wo</span>rld')
    end

    it "honors site-level stop_words_extra when site is in registers" do
      site_double = double("site")
      config      = Jekyll::FastReader::Configuration.new("stop_words_extra" => ["hello"])
      allow(site_double).to receive(:instance_variable_get).with(:@fast_reader_config).and_return(config)

      result = render("{{ text | fast_reader }}", { "text" => "hello world" }, { site: site_double })
      expect(result).to include('hello <span class="fr-anchor">wo</span>rld')
      expect(result).not_to include('<span class="fr-anchor">he</span>llo')
    end
  end
end
