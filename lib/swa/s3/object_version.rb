require "swa/resource"

module Swa

  module S3

    class ObjectVersion < Resource

      def summary
        [
          version.last_modified.iso8601,
          rpad(size, 10),
          pad(id, 32),
          uri
        ].join("  ")
      end

      def key
        version.key
      end

      def id
        version.id
      end

      def size
        version.data.to_h.fetch(:size, "-")
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

      def download_into(file_name, &progress_callback)
        downloader = Aws::S3::FileDownloader.new(client: aws_resource.client)
        options = {
          bucket: version.bucket_name,
          key: version.object_key,
          version_id: version.id,
          progress_callback: progress_callback
        }
        downloader.download(file_name, options)
      end

      def delete
        version.delete
      end

      alias version aws_resource

    end

  end

end
