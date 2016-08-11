require "aws-sdk-resources"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/cloud_formation/stack"

module Swa
  module CLI

    class CloudFormationCommand < BaseCommand

      subcommand ["stacks"], "Show stacks" do

        include CollectionBehaviour

        private

        def collection
          query_for(:stacks, Swa::CloudFormation::Stack)
        end

      end

      protected

      def cloud_formation
        ::Aws::CloudFormation::Resource.new(aws_config)
      end

      def query_for(query_method, model)
        aws_resources = cloud_formation.public_send(query_method, query_options)
        model.list(aws_resources)
      end

    end

  end
end
