require "swa/resource"

module Swa
  module CloudFormation

    class Stack < Resource

      def summary
        [
          name,
          # pad(subnet.subnet_id, 15),
          # pad(subnet.vpc_id, 12),
          # pad(subnet.availability_zone, 15),
          # pad(subnet.cidr_block, 18),
          # quoted(name)
        ].join("  ")
      end

      def name
        stack.name
      end

      private

      alias_method :stack, :aws_resource

    end

  end
end
