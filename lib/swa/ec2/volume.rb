require "swa/resource"
require "swa/ec2/tagged_resource"

module Swa
  module EC2

    class Volume < Resource

      include TaggedResource

      def summary
        [
          pad(v.volume_id, 21),
          pad(v.snapshot_id, 22),
          sprintf("%5d", v.size),
          pad(v.volume_type, 9),
          pad(attachment.instance_id, 19),
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

      delegate :delete

      private

      alias_method :v, :aws_resource

    end

  end
end
