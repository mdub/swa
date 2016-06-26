module Swa
  module CLI

    module ItemBehaviour

      def self.included(target)

        target.default_subcommand = "summary"

        target.subcommand ["summary", "s"], "brief summary (one per line)" do
          def execute
            puts item.summary
          end
        end

        target.subcommand ["data", "d"], "full details" do

          parameter "[QUERY]", "JMESPath expression"

          def execute
            display_data(item.data, query)
          end

        end

      end

    end

  end
end
