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

        target.subcommand ["data", "d"], "Full details" do

          parameter "[QUERY]", "JMESPath expression"

          def execute
            display_data(collection.map(&:data).to_a, query)
          end

        end

      end

    end

  end
end
