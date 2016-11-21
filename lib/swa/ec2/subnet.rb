require "swa/ec2/tagged_resource"
require "swa/resource"

module Swa
  module EC2

    class Subnet < Resource

      include TaggedResource

      def id
        subnet.subnet_id
      end

      def summary
        [
          field(subnet, :subnet_id),
          field(subnet, :vpc_id),
          field(subnet, :availability_zone),
          field(subnet, :cidr_block),
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
