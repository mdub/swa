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

        subcommand "objects", "List objects" do

          option "--prefix", "PREFIX", "object prefix"

          self.default_subcommand = "list"

          subcommand ["list", "ls"], "One-line summary" do

            def execute
              objects.each do |i|
                puts i.summary
              end
            end

          end

          subcommand ["data", "d"], "Full details" do

            parameter "[QUERY]", "JMESPath expression"

            def execute
              display_data(objects.map(&:data).to_a, query)
            end

          end

          protected

          def objects
            bucket.objects(:prefix => prefix)
          end

        end

        subcommand "policy", "print bucket policy" do

          def execute
            display_data(bucket.policy_data)
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
