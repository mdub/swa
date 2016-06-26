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

        target.subcommand ["detail", "d"], "full details" do
          def execute
            display_data(item.data)
          end
        end

      end

    end

  end
end
