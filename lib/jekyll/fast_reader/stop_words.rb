require "set"

module Jekyll
  module FastReader
    class StopWords
      DEFAULT = Set.new(%w[
        a an the of in on at to by or is as
        and but for nor so yet
        it its this that
      ]).freeze

      def initialize(extra = [])
        @words = DEFAULT | Set.new(extra.map(&:downcase))
      end

      def stop?(word)
        @words.include?(word.downcase)
      end
    end
  end
end
