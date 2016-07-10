require "swa/ec2/tagged_resource"
require "swa/resource"

module Swa
  module EC2

    class Subnet < Resource

      include TaggedResource

      def summary
        [
          pad(subnet.subnet_id, 15),
          pad(subnet.vpc_id, 12),
          pad(subnet.availability_zone, 15),
          pad(subnet.cidr_block, 18),
          quoted(name)
        ].join("  ")
      end

      def name
        tags["Name"]
      end

      private

      alias_method :subnet, :aws_resource

    end

  end
end
