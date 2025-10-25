# frozen_string_literal: true

module Swa

  module CLI

    module ItemBehaviour

      def self.included(target)
        target.subcommand ["summary", "s"], "One-line summary" do
          def execute
            puts item.summary
          end
        end

        target.subcommand ["data", "d"], "Full details" do

          parameter "[QUERY]", "JMESPath expression"

          def execute
            display_data(item.data, query)
          end

        end
      end

    end

  end

end
