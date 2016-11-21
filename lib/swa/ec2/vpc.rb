require "swa/ec2/tagged_resource"
require "swa/resource"

module Swa
  module EC2

    class Vpc < Resource

      include TaggedResource

      def id
        vpc.vpc_id
      end

      def summary
        [
          field(vpc, :vpc_id),
          pad(default_marker, 1),
          field(vpc, :cidr_block),
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
