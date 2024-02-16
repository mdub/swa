require "swa/record"

module Swa
  module S3

    class ObjectListEntry < Record

      def initialize(bucket_name, aws_record)
        @bucket_name = bucket_name
        super(aws_record)
      end

      attr_reader :bucket_name

      def to_s
        uri
      end

      def summary
        [
          pad(column1, 20),
          rpad(column2, 10),
          uri
        ].join("  ")
      end

    end

    class ObjectPrefix < ObjectListEntry

      delegate :prefix

      def column1
        "-"
      end

      def column2
        "-"
      end

      def uri
        "s3://#{bucket_name}/#{prefix}"
      end

    end

    class ObjectSummary < ObjectListEntry

      delegate :key, :size, :last_modified

      def column1
        last_modified.iso8601
      end

      def column2
        size
      end

      def uri
        "s3://#{bucket_name}/#{key}"
      end

    end

  end
end
