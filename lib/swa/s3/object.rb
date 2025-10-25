# frozen_string_literal: true

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

      def download_into(file_name, &progress_callback)
        object.download_file(file_name, progress_callback: progress_callback)
      end

      def put(io, options = {})
        object.put(options.merge(body: io))
      end

      def upload_from(file_name)
        object.upload_file(file_name)
      end

      def delete
        object.delete
      end

      def version(version_id)
        Swa::S3::ObjectVersion.new(object.version(version_id))
      end

      alias object aws_resource

    end

  end

end
