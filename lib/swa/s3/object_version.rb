require "swa/resource"

module Swa
  module S3

    class ObjectVersion < Resource

      def summary
        [
          version.last_modified.iso8601,
          rpad(version.size, 10),
          pad(version.id, 32),
          uri
        ].join("  ")
      end

      def key
        version.key
      end

      def id
        version.id
      end

      def uri
        "s3://#{version.bucket_name}/#{version.key}"
      end

      def to_s
        uri
      end

      def get_body
        version.get.body
      end

      def delete
        version.delete
      end

      private

      alias_method :version, :aws_resource

    end

  end
end
