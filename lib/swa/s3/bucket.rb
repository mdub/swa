require "multi_json"
require "swa/resource"
require "swa/s3/object"
require "swa/s3/object_version"

module Swa
  module S3

    class Bucket < Resource

      def id
        name
      end

      def summary
        name
      end

      delegate :name

      def uri
        "s3://#{bucket.name}"
      end

      def policy_json
        bucket.policy.policy.read
      end

      def policy_data
        MultiJson.load(policy_json)
      end

      def objects(options = {})
        Swa::S3::Object.list(aws_resource.objects(options))
      end

      def object_versions(options = {})
        Swa::S3::ObjectVersion.list(aws_resource.object_versions(options))
      end

      def delete
        bucket.delete
      end

      private

      alias_method :bucket, :aws_resource

    end

  end
end
