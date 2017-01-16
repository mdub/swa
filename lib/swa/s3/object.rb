require "swa/resource"
require "swa/s3/object_version"

module Swa
  module S3

    class Object < Resource

      def summary
        [
          object.last_modified.iso8601,
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

      def get_body
        object.get.body
      end

      def put(io, options = {})
        object.put(options.merge(:body => io))
      end

      def upload(file_name)
        object.upload_file(file_name)
      end

      def delete
        object.delete
      end

      def version(version_id)
        Swa::S3::ObjectVersion.new(object.version(version_id))
      end

      private

      alias_method :object, :aws_resource

    end

  end
end
