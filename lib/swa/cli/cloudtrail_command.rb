require "aws-sdk-cloudtrail"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cloud_trail/event"

module Swa
  module CLI

    class CloudtrailCommand < BaseCommand

      subcommand "events", "CloudTrail events" do

        include CollectionBehaviour

        option "--max", "N", "number of events to return", default: 50 do |n|
          Integer(n)
        end

        option "--source", "SERVICE", "filter by event source (e.g. kms)" do |value|
          value = value.include?(".") ? value : "#{value}.amazonaws.com"
          compile_pattern(value)
        end

        option "--name", "EVENT_NAME", "filter by event name (e.g. Decrypt)" do |value|
          compile_pattern(value)
        end

        private

        def collection
          query_args = {}

          # CloudTrail API only supports ONE lookup attribute at a time
          # Use API filter for exact matches (not patterns with wildcards)
          if name && name.is_a?(String)
            query_args[:lookup_attributes] = [{ attribute_key: "EventName", attribute_value: name }]
          elsif source && source.is_a?(String)
            query_args[:lookup_attributes] = [{ attribute_key: "EventSource", attribute_value: source }]
          end

          events = query_for(:lookup_events, :events, Swa::CloudTrail::Event, **query_args)

          # Apply programmatic filters
          events = events.select { |event| name === event.event_name } if name
          events = events.select { |event| source === event.event_source } if source

          events.take(max)
        end

        def compile_pattern(value)
          if value.include?("*") || value.include?("?")
            # Convert shell-style wildcards to regex
            regex_pattern = Regexp.escape(value).gsub('\*', '.*').gsub('\?', '.')
            Regexp.new("^#{regex_pattern}$", Regexp::IGNORECASE)
          else
            # Return as string for exact match and API filtering
            value
          end
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
