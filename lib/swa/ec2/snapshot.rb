require "forwardable"
require "swa/resource"
require "swa/ec2/tagged_resource"

module Swa
  module EC2

    class Snapshot < Resource

      include TaggedResource

      def summary
        [
          pad(s.snapshot_id, 13),
          pad(s.volume_id, 12),
          sprintf("%4d", s.volume_size),
          s.start_time.iso8601,
          rpad(s.progress, 4),
          quoted(s.description)
        ].join("  ")
      end

      extend Forwardable

      def_delegators :s, :delete

      private

      alias_method :s, :aws_resource

    end

  end
end
