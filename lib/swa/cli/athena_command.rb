require "aws-sdk-athena"
require "bytesize"
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
      option %w[--workgroup -W], "NAME", "Workgroup name"

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

        def item
          Swa::Athena::Database.new(
            athena_client.get_database(catalog_name: catalog, database_name: database).database
          )
        end

      end

      subcommand ["databases", "dbs"], "Show databases" do

        include CollectionBehaviour

        def collection
          query_for(:list_databases, :database_list, Swa::Athena::Database, catalog_name: catalog)
        end

      end

      module CanOutputResults

        extend Clamp::Option::Declaration

        option ["--text", "-1"], :flag, "output first column as text"

        def display_query_results(query_results)
          output_rows(
            query_results.lazy.flat_map do |results|
              results.result_set.rows
            end
          )
        end

        def output_rows(rows)
          if text?
            output_rows_as_text(rows)
          else
            output_rows_as_csv(rows)
          end
        end

        def output_rows_as_csv(rows)
          CSV($stdout.dup) do |csv|
            rows.each do |row|
              csv << row.data.map(&:var_char_value)
            end
          end
        end

        def output_rows_as_text(rows)
          rows.drop(1).each do |row|
            puts row.data.first.var_char_value
          end
        end

      end

      subcommand ["execution", "query-execution"], "Inspect query execution" do

        parameter "ID", "execution ID", attribute_name: :execution_id

        include ItemBehaviour

        def item
          Swa::Athena::QueryExecution.new(
            athena_client.get_query_execution(query_execution_id: execution_id).query_execution
          )
        end

        subcommand "results", "Show results" do

          include CanOutputResults

          def execute
            display_query_results(athena_client.get_query_results(query_execution_id: execution_id))
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

      subcommand ["query", "q", "execute", "exec"], "Run a query" do

        option ["--database", "-D"], "NAME", "Database name"
        option ["--output-location", "-O"], "S3_URL", "S3 output location for query results"
        option ["--explain", "-E"], :flag, "Explain query"
        option ["--timeout"], "SECONDS", "Time to wait for completion", default: 120, &method(:Integer)

        include CanOutputResults

        parameter "[QUERY]", "SQL query", default: "STDIN"

        def execute
          if explain?
            self.query = "EXPLAIN #{query}"
            self.text = true
          end
          results, statistics = execute_query(query)
          show_statistics(statistics)
          display_query_results(results)
        end

        def default_query
          $stdin.read
        end

        def execute_query(query)
          start_query_response = athena_client.start_query_execution(
            query_execution_context: {
              catalog: catalog,
              database: database
            },
            query_string: query,
            result_configuration: {
              output_location: output_location
            },
            work_group: workgroup
          )
          query_execution_id = start_query_response.query_execution_id
          logger.debug "query_execution_id = #{query_execution_id}"
          query_still_running = true
          query_execution_output = wait_for_query(query_execution_id)
          query_still_running = false
          results = athena_client.get_query_results(query_execution_id: query_execution_id)
          [results, query_execution_output.query_execution.statistics]
        rescue Aws::Waiters::Errors::FailureStateError => e
          query_still_running = false
          signal_error e.response.query_execution.status.state_change_reason
        ensure
          if query_still_running
            logger.warn "Cancelling query #{query_execution_id}"
            athena_client.stop_query_execution(query_execution_id: query_execution_id)
          end
        end

        def wait_for_query(query_execution_id)
          poll_interval = 5
          max_attempts = timeout / poll_interval
          QueryCompletionWaiter.new(
            client: athena_client,
            max_attempts: max_attempts,
            delay: poll_interval
          ).wait(query_execution_id: query_execution_id)
        end

        def show_statistics(statistics)
          logger.debug "Total execution time = #{statistics.total_execution_time_in_millis} ms"
          logger.debug "Data scanned = #{ByteSize.bytes(statistics.data_scanned_in_bytes)}"
        end

      end

      subcommand ["workgroups", "wgs"], "Show work-groups" do

        include CollectionBehaviour

        def collection
          query_for(:list_work_groups, :work_groups, Swa::Athena::WorkGroup)
        end

      end

      protected

      def athena_client
        ::Aws::Athena::Client.new(aws_config)
      end

      def query_for(query_method, response_key, model, **query_args)
        model.list_from_query(athena_client, query_method, response_key, **query_args)
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
                  "state" => "success"
                },
                {
                  "matcher" => "path",
                  "argument" => "query_execution.status.state",
                  "expected" => "FAILED",
                  "state" => "failure"
                },
                {
                  "matcher" => "path",
                  "argument" => "query_execution.status.state",
                  "expected" => "CANCELLED",
                  "state" => "error"
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
