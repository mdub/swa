module Swa
  module CLI

    class Selector

      def initialize
        @predicates = []
      end

      def add(&block)
        @predicates << block
      end

      def call(subject)
        @predicates.all? do |predicate|
          predicate.call(subject)
        end
      end

      def apply(collection)
        collection.lazy.select(&method(:call))
      end

      def specified?
        @predicates.any?
      end

    end

  end
end
