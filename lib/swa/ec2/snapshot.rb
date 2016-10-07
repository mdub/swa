require "swa/resource"
require "swa/ec2/tagged_resource"

module Swa
  module EC2

    class Snapshot < Resource

      include TaggedResource

      def summary
        [
          field(s, :snapshot_id),
          field(s, :volume_id),
          sprintf("%5d", s.volume_size),
          s.start_time.iso8601,
          rpad(s.progress, 4),
          quoted(s.description)
        ].join("  ")
      end

      delegate :delete

      private

      alias_method :s, :aws_resource

    end

  end
end
