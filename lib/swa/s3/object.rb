require "swa/resource"

module Swa
  module S3

    class Object < Resource

      def summary
        [
          object.last_modified.strftime("%Y-%m-%d %H:%M:%S"),
          rpad(object.size, 10),
          uri
        ].join("  ")
      end

      def key
        object.key
      end

      def uri
        "s3://#{object.bucket.name}/#{object.key}"
      end

      def to_s
        uri
      end

      private

      alias_method :object, :aws_resource

    end

  end
end
