require "aws-sdk-cloudtrail"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cloud_trail/event"

module Swa
  module CLI

    class CloudtrailCommand < BaseCommand

      subcommand "query", "Query CloudTrail events" do

        include CollectionBehaviour

        option "--limit", "N", "number of events to return", default: 50 do |n|
          Integer(n)
        end

        private

        def collection
          query_for(:lookup_events, :events, Swa::CloudTrail::Event).take(limit)
        end

      end

      protected

      def cloudtrail_client
        ::Aws::CloudTrail::Client.new(aws_config)
      end

      def query_for(query_method, response_key, model, **query_args)
        model.list_from_query(cloudtrail_client, query_method, response_key, **query_args)
      end

    end

  end
end
