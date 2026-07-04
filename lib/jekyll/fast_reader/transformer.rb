require "nokogiri"

module Jekyll
  module FastReader
    class Transformer
      def initialize(config)
        @config = config
        @walker = HtmlWalker.new(config.exclude_selectors)
      end

      def call(html, stop_words: nil)
        return html unless html =~ /<body\b/i

        had_head = html.include?("</head>")
        had_body = html.include?("</body>")

        doc  = Nokogiri::HTML(html)
        body = doc.at_css("body")
        return html unless body

        words     = stop_words || @config.stop_words_extra
        processor = TextProcessor.new(StopWords.new(words))

        text_nodes = []
        @walker.walk(body) { |node| text_nodes << node }
        text_nodes.each { |node| node.replace(processor.process(node.content)) }

        inject_stylesheet(doc) if had_head
        inject_script(doc)     if had_head && @config.toggle
        inject_body_class(body, "fr-opt-in") unless @config.default_on
        inject_toggle(body)    if had_body && @config.toggle

        doc.to_html
      end

      private

      def inject_stylesheet(doc)
        head = doc.at_css("head")
        return unless head

        href = "#{@config.baseurl}#{@config.css_output_path}"
        return if head.css('link[rel="stylesheet"]').any? { |l| l["href"] == href }

        link = Nokogiri::XML::Node.new("link", doc)
        link["rel"]  = "stylesheet"
        link["href"] = href
        head.add_child(link)
      end

      def inject_script(doc)
        head = doc.at_css("head")
        return unless head

        src = "#{@config.baseurl}#{@config.js_output_path}"
        return if head.css("script").any? { |s| s["src"] == src }

        script = Nokogiri::XML::Node.new("script", doc)
        script["src"]   = src
        script["defer"] = "defer"
        head.add_child(script)
      end

      def inject_body_class(body, class_name)
        classes = body["class"].to_s.split
        return if classes.include?(class_name)

        body["class"] = (classes + [class_name]).join(" ")
      end

      def inject_toggle(body)
        return if body.at_css("#fr-toggle")

        button = Nokogiri::XML::Node.new("button", body.document)
        button["id"]                = "fr-toggle"
        button["type"]              = "button"
        button["aria-label"]        = "Toggle Fast Reader"
        button["aria-pressed"]      = @config.default_on ? "true" : "false"
        button["aria-keyshortcuts"] = "Alt+Shift+B"
        button["data-fr-mode"]      = @config.default_on ? "default-on" : "opt-in"
        button.content              = "Fast Reader"
        body.add_child(button)
      end
    end
  end
end
