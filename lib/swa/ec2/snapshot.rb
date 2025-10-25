# frozen_string_literal: true

require "swa/resource"
require "swa/ec2/tagged_resource"

module Swa

  module EC2

    class Snapshot < Resource

      include TaggedResource

      def id
        s.snapshot_id
      end

      def summary
        [
          field(s, :snapshot_id),
          field(s, :volume_id),
          format("%5d", volume_size),
          start_time.iso8601,
          rpad(progress, 4),
          quoted(description)
        ].join("  ")
      end

      delegate :description
      delegate :progress
      delegate :start_time
      delegate :volume_size

      delegate :delete

      alias s aws_resource

    end

  end

end
