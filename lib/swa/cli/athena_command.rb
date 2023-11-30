require "aws-sdk-athena"
require "csv"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/athena/catalog"
require "swa/athena/database"
require "swa/athena/query_execution"
require "swa/athena/work_group"

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

      subcommand "database", "Database" do

        parameter "NAME", "database name", attribute_name: :database

        include ItemBehaviour

        private

        def item
          Swa::Athena::Database.new(
            athena_client.get_database(catalog_name: catalog, database_name: database).database
          )
        end

      end

      subcommand ["databases", "dbs"], "Show databases" do

        include CollectionBehaviour

        private

        def collection
          query_for(:list_databases, :database_list, Swa::Athena::Database, catalog_name: catalog)
        end

      end

      subcommand ["execution", "query-execution"], "Inspect query execution" do

        parameter "ID", "execution ID", attribute_name: :execution_id

        include ItemBehaviour

        private

        def item
          Swa::Athena::QueryExecution.new(
            athena_client.get_query_execution(query_execution_id: execution_id).query_execution
          )
        end

        subcommand "results", "Show results" do

          def execute
            query_results = athena_client.get_query_results(query_execution_id: execution_id)
            output_results_as_csv(query_results.result_set)
          end

        end

      end

      subcommand ["executions", "query-executions"], "List query executions" do

        def execute
          athena_client.list_query_executions(work_group: workgroup).query_execution_ids.each do |id|
            puts id
          end
        end

      end

      subcommand ["executions", "query-executions"], "List query executions" do

        include CollectionBehaviour

        private

        def collection
          query_for(:list_query_executions, :query_execution_ids, Swa::Athena::QueryExecution, work_group: workgroup)
        end

      end

      subcommand ["query", "q", "run"], "Run a query" do

        parameter "QUERY", "SQL query"

        def execute
          start_query_response = athena_client.start_query_execution(query_string: query, work_group: workgroup)
          wait_for_query(start_query_response.query_execution_id)
          query_results = athena_client.get_query_results(query_execution_id: start_query_response.query_execution_id)
          output_results_as_csv(query_results.result_set)
        end

        private

        def wait_for_query(query_execution_id)
          QueryCompletionWaiter.new(client: athena_client).wait(query_execution_id: query_execution_id)
        end

      end

      subcommand ["workgroups", "wgs"], "Show work-groups" do

        include CollectionBehaviour

        private

        def collection
          query_for(:list_work_groups, :work_groups, Swa::Athena::WorkGroup)
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

      def output_results_as_csv(result_set)
        CSV($stdout.dup) do |csv|
          result_set.rows.each do |row|
            csv << row.data.map(&:var_char_value)
          end
        end
      end

      class QueryCompletionWaiter

        def initialize(options)
          @client = options.fetch(:client)
          @waiter = Aws::Waiters::Waiter.new({
            max_attempts: 30,
            delay: 5,
            poller: Aws::Waiters::Poller.new(
              operation_name: :get_query_execution,
              acceptors: [
                {
                  "matcher" => "path",
                  "argument" => "query_execution.status.state",
                  "expected" => "SUCCEEDED",
                  "state" => "success",
                },
                {
                  "matcher" => "path",
                  "argument" => "query_execution.status.state",
                  "expected" => "FAILED",
                  "state" => "failure",
                },
                {
                  "matcher" => "path",
                  "argument" => "query_execution.status.state",
                  "expected" => "CANCELLED",
                  "state" => "error",
                }
              ]
            )
          }.merge(options))
        end

        def wait(params = {})
          @waiter.wait(client: @client, params: params)
        end

      end

    end

  end
end
