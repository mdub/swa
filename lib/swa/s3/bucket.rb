require "multi_json"
require "swa/resource"

module Swa
  module S3

    class Bucket < Resource

      def summary
        bucket.name
      end

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

      def delete
        bucket.delete
      end

      private

      alias_method :bucket, :aws_resource

    end

  end
end
