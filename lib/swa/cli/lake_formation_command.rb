require "aws-sdk-lakeformation"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/lake_formation/data_lake_settings"
require "swa/lake_formation/permission"
require "swa/lake_formation/resource_info"
require "swa/lake_formation/tag"

module Swa
  module CLI

    class LakeFormationCommand < BaseCommand

      subcommand ["data-lake-settings", "settings"], "Show Data Lake Settings" do

        self.default_subcommand = "data"

        include ItemBehaviour

        private

        def item
          Swa::LakeFormation::DataLakeSettings.new(lf_client.get_data_lake_settings.data_lake_settings)
        end

        def execute
          response =
          display_data(stringify_keys(response.data_lake_settings.to_h))
        end

      end

      subcommand ["lf-tags", "tags"], "Show LF-Tags" do

        self.description = <<-EOF
          List LF-Tags.
        EOF

        include CollectionBehaviour

        private

        def collection
          query_for(:list_lf_tags, :lf_tags, Swa::LakeFormation::Tag)
        end
      end

      subcommand ["permissions"], "Show permissions" do

        self.description = <<-EOF
          List permissions.
        EOF

        option ["--resource", "-R"], "DATABASE[.TABLE]", "Resource", attribute_name: :resource_filter do |value|
          parse_resource_filter(value)
        end

        option ["--principal", "-P"], "ARN", "Principal ARN"

        include CollectionBehaviour

        private

        def collection
          query_args = {}
          if resource_filter
            query_args[:resource] = resource_filter
          end
          if principal
            query_args[:principal] = {
              data_lake_principal_identifier: principal
            }
          end
          query_for(:list_permissions, :principal_resource_permissions, Swa::LakeFormation::Permission, **query_args)
        end

        def parse_resource_filter(value)
          case value
          when /\A(\w+)\z/
            {
              database: {
                name: value
              }
            }
          when /\A(\w+)\.(\w+|\*)\z/
            {
              table: {
                database_name: $1,
                name: $2
              }
            }.tap do |filter|
              if $2 == "*"
                filter[:table].delete(:name)
                filter[:table][:table_wildcard] = {}
              end
            end
          else
            raise ArgumentError, "Invalid resource filter: #{value.inspect}"
          end
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
        model.list_from_query(lf_client, query_method, response_key, **query_args)
      end

    end

  end
end
