require "swa/cli/selector"

module Swa

  module CLI

    module CollectionBehaviour

      def self.included(target)
        target.default_subcommand = "summary"

        target.subcommand ["summary", "s"], "One-line summary" do

          def execute
            collection.each do |i|
              puts i.summary
            end
          end

        end

        target.subcommand ["ids"], "Just print ids" do
          def execute
            collection.each do |i|
              puts i.id
            end
          end
        end

        target.subcommand ["data", "d"], "Full details" do

          parameter "[QUERY]", "JMESPath expression"

          def execute
            display_data(collection.map(&:data).to_a, query)
          end

        end
      end

      def selector
        context[:selector] ||= Selector.new
      end

      def query_options
        context[:query_options] ||= {}
      end

    end

  end

end
