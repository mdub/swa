require "swa/resource"
require "swa/ec2/tagged_resource"

module Swa

  module EC2

    class Volume < Resource

      include TaggedResource

      def id
        v.volume_id
      end

      def summary
        [
          field(v, :volume_id),
          field(v, :snapshot_id),
          format("%5d", v.size),
          field(v, :volume_type),
          field(attachment, :instance_id),
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

      alias v aws_resource

    end

  end

end
