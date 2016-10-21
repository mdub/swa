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

        protected

        def aws_bucket
          s3.bucket(bucket_name)
        end

        def bucket
          Swa::S3::Bucket.new(aws_bucket)
        end

        def bucket_name=(arg)
          @bucket_name = arg.sub(%r{^s3://}, "")
        end

        alias_method :item, :bucket

        subcommand "policy", "print bucket policy" do

          def execute
            display_data(bucket.policy_data)
          end

        end

        subcommand "objects", "List objects" do

          include CollectionBehaviour

          protected

          def collection
            Swa::S3::Object.list(aws_bucket.objects)
          end

        end

        subcommand "object", "Show object" do

          parameter "KEY", "object key", :attribute_name => :object_key

          include ItemBehaviour

          protected

          def object
            Swa::S3::Object.new(aws_bucket.object(object_key))
          end

          alias_method :item, :object

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
