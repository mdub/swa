require "forwardable"
require "swa/resource"
require "swa/ec2/tagged_resource"

module Swa
  module EC2

    class Volume < Resource

      include TaggedResource

      def summary
        [
          pad(v.volume_id, 13),
          pad(v.snapshot_id, 14),
          sprintf("%5d", v.size),
          pad(v.volume_type, 10),
          pad(v.state, 11),
          quoted(name)
        ].join(" ")
      end

      def name
        tags["Name"]
      end

      extend Forwardable

      def_delegators :v, :delete

      private

      alias_method :v, :aws_resource

    end

  end
end
