require "swa/resource"

module Swa
  module CloudFormation

    class Stack < Resource

      def summary
        [
          pad(name, 44),
          pad(stack.stack_status, 24),
          last_modified_at.iso8601
        ].join("  ")
      end

      def name
        stack.name
      end

      def last_modified_at
        stack.last_updated_time || stack.creation_time
      end

      private

      alias_method :stack, :aws_resource

    end

  end
end
