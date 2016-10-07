require "swa/resource"
require "swa/ec2/tagged_resource"

module Swa
  module EC2

    class Image < Resource

      include TaggedResource

      def summary
        [
          field(ami, :image_id),
          ami.creation_date.sub(".000Z", "Z"),
          quoted(name)
        ].join("  ")
      end

      def name
        ami.name
      end

      delegate :creation_date
      delegate :deregister

      def delete
        ebs_snapshot_ids = ami.block_device_mappings.map do |mapping|
          mapping.ebs.snapshot_id if mapping.ebs
        end.compact
        deregister
        ebs_snapshot_ids.each do |snapshot_id|
          ami.client.delete_snapshot(:snapshot_id => snapshot_id)
        end
      end

      private

      alias_method :ami, :aws_resource

    end

  end
end
