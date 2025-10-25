require "aws-sdk-glue"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/glue/crawl"
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

        subcommand ["crawls"], "Show crawls" do

          include CollectionBehaviour

          private

          def collection
            query_for(:list_crawls, :crawls, Swa::Glue::Crawl, crawler_name: name)
          end

        end

        def item
          Swa::Glue::Crawler.new(glue_client.get_crawler(name: name).crawler)
        end

      end

      subcommand ["crawlers"], "Show crawlers" do

        include CollectionBehaviour

        def collection
          query_for(:get_crawlers, :crawlers, Swa::Glue::Crawler)
        end

      end

      subcommand ["database"], "Show database" do

        option %w[--catalog], "NAME", "Catalog ID"

        parameter "NAME", "database name"

        include ItemBehaviour

        def item
          Swa::Glue::Database.new(glue_client.get_database(catalog_id: catalog, name: name).database)
        end

        subcommand ["arn"], "Show database ARN" do

          def execute
            puts "arn:aws:glue:#{region}:#{item.catalog_id}:database/#{name}"
          end

        end

        subcommand ["delete"], "Delete database" do

          def execute
            glue_client.delete_database(name: name, **catalog_constraint)
          end

        end

        subcommand ["table"], "Show table" do

          parameter "NAME", "table name", attribute_name: :table_name

          include ItemBehaviour

          subcommand ["partitions"], "Show partitions" do

            include CollectionBehaviour

            def collection
              query_for(:get_partitions, :partitions, Swa::Glue::Partition, catalog_id: catalog,
                                                                            database_name: name, table_name: table_name)
            end

          end

          subcommand ["delete"], "Delete table" do

            def execute
              glue_client.delete_table(catalog_id: catalog, database_name: name, name: table_name)
            end

          end

          subcommand ["lf-tags"], "Show associated LakeFormation tags" do

            include CollectionBehaviour

            def collection
              Swa::LakeFormation::Tag.list_from_query(
                lf_client, :get_resource_lf_tags, :lf_tags_on_table, resource: lf_resource_spec
              )
            end

          end

          subcommand ["lf-permissions"], "Show LakeFormation permissions" do

            option ["--principal", "-P"], "ARN", "Principal ARN"

            include CollectionBehaviour

            def collection
              query_args = {
                resource: lf_resource_spec
              }
              if principal
                query_args[:principal] = {
                  data_lake_principal_identifier: principal
                }
              end
              Swa::LakeFormation::Permission.list_from_query(
                lf_client, :list_permissions, :principal_resource_permissions, **query_args
              )
            end

          end

          def item
            Swa::Glue::Table.new(glue_client.get_table(
              catalog_id: catalog, database_name: name, name: table_name
            ).table)
          end

          def lf_resource_spec
            {
              table: {
                database_name: name,
                name: table_name
              }
            }
          end

        end

        subcommand ["tables"], "Show tables" do

          include CollectionBehaviour

          def collection
            query_for(:get_tables, :table_list, Swa::Glue::Table, catalog_id: catalog, database_name: name)
          end

        end

      end

      subcommand ["databases"], "Show databases" do

        option %w[--catalog], "NAME", "Catalog ID"

        include CollectionBehaviour

        def collection
          query_for(:get_databases, :database_list, Swa::Glue::Database, catalog_id: catalog)
        end

      end

      subcommand ["job"], "Show job" do

        parameter "NAME", "job name"

        include ItemBehaviour

        def item
          Swa::Glue::Job.new(glue_client.get_job(job_name: name).job)
        end

        subcommand ["run"], "Show run" do

          parameter "ID", "run ID", attribute_name: :run_id

          include ItemBehaviour

          subcommand ["bookmark"], "Show bookmark" do

            self.default_subcommand = "summary"

            include ItemBehaviour

            def item
              Swa::Glue::JobBookmarkEntry.new(
                glue_client.get_job_bookmark(job_name: name, run_id: run_id).job_bookmark_entry
              )
            end

          end

          def item
            Swa::Glue::JobRun.new(glue_client.get_job_run(job_name: name, run_id: run_id).job_run)
          end

        end

        subcommand ["runs"], "Show runs" do

          include CollectionBehaviour

          def collection
            query_for(:get_job_runs, :job_runs, Swa::Glue::JobRun, job_name: name)
          end

        end

      end

      subcommand ["jobs"], "Show jobs" do

        include CollectionBehaviour

        def collection
          query_for(:get_jobs, :jobs, Swa::Glue::Job)
        end

      end

      protected

      def glue_client
        ::Aws::Glue::Client.new(aws_config)
      end

      def query_for(query_method, response_key, model, **query_args)
        model.list_from_query(glue_client, query_method, response_key, **query_args)
      end

      def lf_client
        ::Aws::LakeFormation::Client.new(aws_config)
      end

      def parse_parameters
        case remaining_arguments.first
        when /^(\w+)\.(\w+)$/
          remaining_arguments[0, 1] = ["database", ::Regexp.last_match(1), "table", ::Regexp.last_match(2)]
        end
        super
      end

    end

  end

end
