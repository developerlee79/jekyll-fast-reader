module Jekyll
  module FastReader
    class HtmlWalker
      def initialize(exclude_selectors)
        @exclude_selectors = exclude_selectors
      end

      def walk(root, &block)
        return if element_excluded?(root)

        root.children.each do |node|
          if node.text?
            block.call(node) unless trails_anchor?(node)
          elsif node.element?
            walk(node, &block)
          end
        end
      end

      private

      # The text immediately following an fr-anchor span is the unbolded tail of
      # an already-processed word. Re-processing it would re-anchor that tail, so
      # it is left alone. This keeps the transform idempotent and stops the
      # fast_reader Liquid filter from colliding with the automatic pass.
      def trails_anchor?(node)
        previous = node.previous_sibling
        previous&.element? && already_anchored?(previous)
      end

      def element_excluded?(node)
        return false unless node.respond_to?(:element?) && node.element?
        return true if node.respond_to?(:[]) && node["data-fr-skip"]
        return true if already_anchored?(node)

        @exclude_selectors.any? do |selector|
          node.matches?(selector)
        rescue Nokogiri::CSS::SyntaxError
          Jekyll.logger.warn "FastReader:", "Invalid CSS selector ignored: #{selector.inspect}"
          false
        end
      end

      # Already-anchored spans (e.g. emitted by the fast_reader Liquid filter)
      # must not be descended into, otherwise a second pass nests fr-anchor spans.
      def already_anchored?(node)
        return false unless node.respond_to?(:[])

        node["class"].to_s.split.include?("fr-anchor")
      end
    end
  end
end
