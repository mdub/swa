require "swa/ec2/tagged_resource"
require "swa/resource"

module Swa
  module EC2

    class Vpc < Resource

      include TaggedResource

      def summary
        [
          pad(vpc.vpc_id, 12),
          pad(default_marker, 1),
          pad(vpc.cidr_block, 18),
          quoted(name)
        ].join("  ")
      end

      def name
        tags["Name"]
      end

      def default_marker
        "*" if vpc.is_default
      end

      private

      alias_method :vpc, :aws_resource

    end

  end
end
