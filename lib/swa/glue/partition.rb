require "swa/record"

module Swa
  module Glue

    class Partition < Record

      def summary
        [
          creation_time,
          location
        ].join("  ")
      end

      def location
        aws_record.storage_descriptor.location
      end

      def creation_time
        aws_record.creation_time.iso8601
      end
      
    end

  end
end
