require "aws-sdk-lakeformation"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/lake_formation/permission"
require "swa/lake_formation/resource_info"

module Swa
  module CLI

    class LakeFormationCommand < BaseCommand

      subcommand ["permissions"], "Show permissions" do

        self.description = <<-EOF
          List permissions.
        EOF

        ALLOWED_RESOURCE_TYPES = %w(CATALOG DATABASE TABLE DATA_LOCATION LF_TAG LF_TAG_POLICY LF_TAG_POLICY_DATABASE LF_TAG_POLICY_TABLE)

        option ["--type", "-T"], "TYPE", "Resource type" do |value|
          value = value.upcase
          raise ArgumentError, "Invalid resource type: #{value}" unless ALLOWED_RESOURCE_TYPES.include?(value)
          value
        end

        include CollectionBehaviour

        private

        def collection
          query_args = {}
          query_args[:resource_type] = type if type
          query_for(:list_permissions, :principal_resource_permissions, Swa::LakeFormation::Permission, **query_args)
        end

      end

      subcommand ["resources"], "Show resources" do

        self.description = <<-EOF
          List resources.
        EOF

        include CollectionBehaviour

        private

        def collection
          query_for(:list_resources, :resource_info_list, Swa::LakeFormation::ResourceInfo)
        end

      end

      protected

      def lf_client
        ::Aws::LakeFormation::Client.new(aws_config)
      end

      def query_for(query_method, response_key, model, **query_args)
        records = lf_client.public_send(query_method, **query_args).public_send(response_key)
        model.list(records)
      end

    end

  end
end
