require "aws-sdk-resources"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/cli/tag_filter_options"
require "swa/s3/bucket"
require "swa/s3/object"

module Swa
  module CLI

    class S3Command < BaseCommand

      subcommand "bucket", "Show bucket" do

        parameter "NAME", "bucket name", :attribute_name => :bucket_name

        include ItemBehaviour

        private

        def bucket
          Swa::S3::Bucket.new(s3.bucket(bucket_name))
        end

        alias_method :item, :bucket

        subcommand "policy", "print bucket policy" do

          def execute
            puts item.policy
          end

        end

        subcommand "objects", "List objects" do

          include CollectionBehaviour

          protected

          def collection
            aws_bucket = s3.bucket(bucket_name)
            Swa::S3::Object.list(aws_bucket.objects)
          end

        end

      end

      subcommand "buckets", "List buckets" do

        include CollectionBehaviour

        private

        def collection
          query_for(:buckets, Swa::S3::Bucket)
        end

      end

      protected

      def s3
        ::Aws::S3::Resource.new(aws_config)
      end

      def query_for(query_method, resource_model)
        aws_resources = s3.public_send(query_method)
        resource_model.list(aws_resources)
      end

    end

  end
end