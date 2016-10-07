require "aws-sdk-resources"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/cli/tag_filter_options"
require "swa/s3/bucket"

module Swa
  module CLI

    class S3Command < BaseCommand

      subcommand ["buckets"], "List buckets" do

        include TagFilterOptions
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
        wrapped_resources = resource_model.list(aws_resources)
      end

    end

  end
end
