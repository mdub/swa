require "stackup/stack"
require "swa/resource"
require "yaml"

module Swa

  module CloudFormation

    class Stack < Resource

      def id
        name
      end

      def summary
        [
          pad(name, 44),
          pad(stack.stack_status, 24),
          last_modified_at.iso8601
        ].join("  ")
      end

      delegate :name

      def last_modified_at
        stack.last_updated_time || stack.creation_time
      end

      def template_body
        stackup_stack.template_body
      end

      def template_data
        stackup_stack.template
      end

      def parameters
        stackup_stack.parameters
      end

      def outputs
        stackup_stack.outputs
      end

      def resources
        stackup_stack.resources
      end

      private

      alias stack aws_resource

      def stackup_stack
        Stackup::Stack.new(name, stack.client)
      end

    end

  end

end
