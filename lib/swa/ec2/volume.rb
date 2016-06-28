require "forwardable"
require "swa/resource"
require "swa/ec2/tagged_resource"

module Swa
  module EC2

    class Volume < Resource

      include TaggedResource

      def summary
        [
          pad(v.volume_id, 12),
          pad(v.snapshot_id, 13),
          sprintf("%4d", v.size),
          pad(v.volume_type, 9),
          pad(attachment.instance_id, 10),
          pad(attachment.device, 9),
          quoted(name)
        ].join("  ")
      end

      def name
        tags["Name"]
      end

      def attachment
        v.attachments.first || OpenStruct.new
      end

      extend Forwardable

      def_delegators :v, :delete

      private

      alias_method :v, :aws_resource

    end

  end
end
