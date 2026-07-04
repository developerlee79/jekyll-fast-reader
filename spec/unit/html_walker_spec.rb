require "spec_helper"
require "nokogiri"

RSpec.describe Jekyll::FastReader::HtmlWalker do
  let(:exclude_selectors) { %w[code pre] }
  subject(:walker) { described_class.new(exclude_selectors) }

  def text_nodes_from(html)
    doc   = Nokogiri::HTML.fragment(html)
    nodes = []
    walker.walk(doc) { |n| nodes << n.content }
    nodes
  end

  it "yields text nodes from paragraphs" do
    nodes = text_nodes_from("<p>hello world</p>")
    expect(nodes).to include("hello world")
  end

  it "skips text nodes inside code elements" do
    nodes = text_nodes_from("<p>outside</p><code>inside</code>")
    expect(nodes).to include("outside")
    expect(nodes).not_to include("inside")
  end

  it "skips text nodes inside pre elements" do
    nodes = text_nodes_from("<pre>preformatted</pre>")
    expect(nodes).to be_empty
  end

  it "descends into nested elements" do
    nodes = text_nodes_from("<p><em>emphasis</em></p>")
    expect(nodes).to include("emphasis")
  end

  it "skips elements carrying data-fr-skip" do
    nodes = text_nodes_from('<p>kept</p><p data-fr-skip>hidden</p>')
    expect(nodes).to     include("kept")
    expect(nodes).not_to include("hidden")
  end

  it "skips descendants of an element carrying data-fr-skip" do
    nodes = text_nodes_from('<div data-fr-skip><p>nested</p></div><p>kept</p>')
    expect(nodes).to     include("kept")
    expect(nodes).not_to include("nested")
  end
end
