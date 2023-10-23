require "aws-sdk-glue"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/glue/crawler"
require "swa/glue/database"
require "swa/glue/table"

module Swa
  module CLI

    class GlueCommand < BaseCommand

      subcommand ["crawler"], "Show crawler" do

        parameter "NAME", "crawler name"

        include ItemBehaviour

        private

        def item
          Swa::Glue::Crawler.new(glue_client.get_crawler(:name => name).crawler)
        end

      end

      subcommand ["crawlers"], "Show crawlers" do

        include CollectionBehaviour

        private

        def collection
          query_for(:get_crawlers, :crawlers, Swa::Glue::Crawler)
        end

      end

      subcommand ["database"], "Show database" do

        parameter "NAME", "database name"

        include ItemBehaviour

        private

        def item
          Swa::Glue::Database.new(glue_client.get_database(:name => name).database)
        end

        subcommand ["tables"], "Show tables" do

          include CollectionBehaviour
  
          private
  
          def collection
            query_for(:get_tables, :table_list, Swa::Glue::Table, :database_name => name)
          end
  
        end
  
      end

      subcommand ["databases"], "Show databases" do

        include CollectionBehaviour

        private

        def collection
          query_for(:get_databases, :database_list, Swa::Glue::Database)
        end

      end

      protected

      def glue_client
        ::Aws::Glue::Client.new(aws_config)
      end

      def query_for(query_method, response_key, model, **query_args)
        records = glue_client.public_send(query_method, **query_args).public_send(response_key)
        model.list(records)
      end

    end

  end
end
