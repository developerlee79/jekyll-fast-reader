require "spec_helper"

RSpec.describe Jekyll::FastReader::Transformer do
  def make_config(config = {}, baseurl = "")
    Jekyll::FastReader::Configuration.new(config, baseurl)
  end

  subject(:transformer) { described_class.new(make_config) }

  let(:full_html) do
    "<html><head></head><body><p>hello world</p></body></html>"
  end

  describe "no-body passthrough" do
    it "returns html unchanged when body element is absent" do
      fragment = "<p>no body here</p>"
      expect(transformer.call(fragment)).to eq(fragment)
    end
  end

  describe "fr-anchor injection" do
    it "wraps word anchors inside body" do
      result = transformer.call(full_html)
      expect(result).to include('class="fr-anchor"')
    end
  end

  describe "idempotency with pre-anchored content" do
    it "does not nest fr-anchor spans when content is already anchored" do
      html = '<html><head></head><body>' \
             '<p><span class="fr-anchor">hel</span>lo</p></body></html>'
      result = transformer.call(html)
      expect(result).not_to match(%r{<span class="fr-anchor">\s*<span class="fr-anchor">})
    end

    it "is idempotent: re-running leaves the anchored output unchanged" do
      once  = transformer.call(full_html)
      twice = transformer.call(once)
      expect(twice).to eq(once)
    end
  end

  describe "stylesheet injection" do
    it "injects link before </head>" do
      result = transformer.call(full_html)
      expect(result).to include('<link rel="stylesheet"')
      expect(result).to include("/assets/fast-reader.css")
    end

    it "does not inject duplicate when href already present" do
      pre_injected = full_html.sub(
        "</head>",
        '<link rel="stylesheet" href="/assets/fast-reader.css"></head>'
      )
      result = transformer.call(pre_injected)
      expect(result.scan("fast-reader.css").length).to eq(1)
    end

    it "skips injection when </head> is absent" do
      html = "<body><p>hello</p></body>"
      result = transformer.call(html)
      expect(result).not_to include("<link")
    end

    it "includes baseurl in href" do
      t = described_class.new(make_config({}, "/blog"))
      result = t.call(full_html)
      expect(result).to include("/blog/assets/fast-reader.css")
    end
  end

  describe "toggle button" do
    it "is absent by default" do
      result = transformer.call(full_html)
      expect(result).not_to include('id="fr-toggle"')
    end

    it "is injected when toggle: true" do
      t = described_class.new(make_config("toggle" => true))
      result = t.call(full_html)
      expect(result).to include('id="fr-toggle"')
    end

    it "has type=button" do
      t = described_class.new(make_config("toggle" => true))
      result = t.call(full_html)
      expect(result).to include('type="button"')
    end

    it "has aria-label attribute" do
      t = described_class.new(make_config("toggle" => true))
      result = t.call(full_html)
      expect(result).to include("aria-label=")
    end

    it "starts aria-pressed=true in default_on mode" do
      t = described_class.new(make_config("toggle" => true))
      result = t.call(full_html)
      expect(result).to include('aria-pressed="true"')
      expect(result).to include('data-fr-mode="default-on"')
    end

    it "starts aria-pressed=false in opt-in mode" do
      t = described_class.new(make_config("toggle" => true, "default_on" => false))
      result = t.call(full_html)
      expect(result).to include('aria-pressed="false"')
      expect(result).to include('data-fr-mode="opt-in"')
    end

    it "does not emit inline onclick or style on the button" do
      t = described_class.new(make_config("toggle" => true))
      result = t.call(full_html)
      expect(result).not_to match(/<button[^>]*\bonclick=/)
      expect(result).not_to match(/<button[^>]*\bstyle=/)
    end

    it "injects external fast-reader.js script when toggle is enabled" do
      t = described_class.new(make_config("toggle" => true))
      result = t.call(full_html)
      expect(result).to include('<script src="/assets/fast-reader.js"')
    end

    it "does not inject script when toggle is disabled" do
      result = transformer.call(full_html)
      expect(result).not_to include("fast-reader.js")
    end

    it "advertises the keyboard shortcut via aria-keyshortcuts" do
      t = described_class.new(make_config("toggle" => true))
      result = t.call(full_html)
      expect(result).to include('aria-keyshortcuts="Alt+Shift+B"')
    end
  end

  describe "default_on: false body class" do
    it "adds fr-opt-in class to body" do
      t = described_class.new(make_config("default_on" => false))
      result = t.call(full_html)
      expect(result).to match(/<body[^>]*class="[^"]*fr-opt-in[^"]*"/)
    end

    it "does not add fr-opt-in when default_on is true" do
      result = transformer.call(full_html)
      expect(result).not_to include("fr-opt-in")
    end

    it "preserves existing body class" do
      html = '<html><head></head><body class="theme-dark"><p>hi</p></body></html>'
      t = described_class.new(make_config("default_on" => false))
      result = t.call(html)
      expect(result).to match(/<body class="theme-dark fr-opt-in"/)
    end

    it "does not duplicate fr-opt-in when invoked twice on the same html" do
      t      = described_class.new(make_config("default_on" => false))
      first  = t.call(full_html)
      second = t.call(first)
      expect(second.scan("fr-opt-in").length).to eq(1)
    end
  end
end
