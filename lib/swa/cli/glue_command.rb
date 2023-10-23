require "aws-sdk-glue"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/glue/crawler"
require "swa/glue/database"
require "swa/glue/job"
require "swa/glue/job_run"
require "swa/glue/job_bookmark_entry"
require "swa/glue/partition"
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

        subcommand ["table"], "Show table" do

          parameter "NAME", "table name", attribute_name: :table_name

          include ItemBehaviour

          subcommand ["partitions"], "Show partitions" do

            include CollectionBehaviour

            private

            def collection
              query_for(:get_partitions, :partitions, Swa::Glue::Partition, :database_name => name, :table_name => table_name)
            end

          end

          private

          def item
            Swa::Glue::Table.new(glue_client.get_table(
              :database_name => name, :name => table_name
            ).table)
          end

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

      subcommand ["job"], "Show job" do

        parameter "NAME", "job name"

        include ItemBehaviour

        private

        def item
          Swa::Glue::Job.new(glue_client.get_job(:job_name => name).job)
        end

        subcommand ["run"], "Show run" do

          parameter "ID", "run ID", attribute_name: :run_id

          include ItemBehaviour

          subcommand ["bookmark"], "Show bookmark" do

            self.default_subcommand = "summary"

            include ItemBehaviour

            private

            def item
              Swa::Glue::JobBookmarkEntry.new(
                glue_client.get_job_bookmark(:job_name => name, :run_id => run_id).job_bookmark_entry
              )
            end

          end

          private

          def item
            Swa::Glue::JobRun.new(glue_client.get_job_run(:job_name => name, :run_id => run_id).job_run)
          end

        end

        subcommand ["runs"], "Show runs" do

          include CollectionBehaviour

          private

          def collection
            query_for(:get_job_runs, :job_runs, Swa::Glue::JobRun, :job_name => name)
          end

        end

      end

      subcommand ["jobs"], "Show jobs" do

        include CollectionBehaviour

        private

        def collection
          query_for(:get_jobs, :jobs, Swa::Glue::Job)
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
