require "swa/resource"
require "yaml"

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

      delegate :name

      def last_modified_at
        stack.last_updated_time || stack.creation_time
      end

      def template_body
        stack.client.get_template(:stack_name => name).template_body
      end

      def template_data
        YAML.load(template_body)
      end

      def parameters
        stack.parameters.map(&:to_h)
      end

      def outputs
        stack.outputs.map(&:to_h)
      end

      private

      alias_method :stack, :aws_resource

    end

  end
end
