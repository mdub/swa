require "aws-sdk-athena"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/athena/catalog"
require "swa/athena/database"

module Swa
  module CLI

    class AthenaCommand < BaseCommand

      option "--catalog", "NAME", "Data catalog name", default: "AwsDataCatalog"
      option %w(--workgroup -W), "NAME", "Workgroup name"

      subcommand "catalogs", "Show catalogs" do

        include CollectionBehaviour

        private

        def collection
          query_for(:list_data_catalogs, :data_catalogs_summary, Swa::Athena::Catalog)
        end

      end

      subcommand "databases", "Show databases" do

        include CollectionBehaviour

        private

        def collection
          query_for(:list_databases, :database_list, Swa::Athena::Database, catalog_name: catalog)
        end

      end

      protected

      def athena_client
        ::Aws::Athena::Client.new(aws_config)
      end

      def query_for(query_method, response_key, model, **query_args)
        records = athena_client.public_send(query_method, **query_args).public_send(response_key)
        model.list(records)
      end

    end

  end
end
