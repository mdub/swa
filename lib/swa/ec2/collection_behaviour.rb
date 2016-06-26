module Swa
  module CLI

    module CollectionBehaviour

      def self.included(target)

        target.default_subcommand = "summary"

        target.subcommand ["summary", "s"], "brief summary (one per line)" do
          def execute
            collection.each do |i|
              puts i.summary
            end
          end
        end

        target.subcommand ["detail", "d"], "full details" do
          def execute
            display_data(collection.map(&:data).to_a)
          end
        end

      end

    end

  end
end
