# frozen_string_literal: true

require "multi_json"
require "swa/resource"
require "swa/s3/object"
require "swa/s3/object_list_entry"
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

      def object_list_entries(options = {})
        options = options.merge(bucket: bucket.name)
        resp = bucket.client.list_objects_v2(options)
        ::Enumerator.new do |y|
          resp.each_page do |page|
            page.data.common_prefixes.each do |prefix_data|
              y << Swa::S3::ObjectPrefix.new(bucket.name, prefix_data)
            end
            page.data.contents.each do |object_data|
              y << Swa::S3::ObjectSummary.new(bucket.name, object_data)
            end
          end
        end
      end

      def delete
        bucket.delete
      end

      alias bucket aws_resource

    end

  end

end
