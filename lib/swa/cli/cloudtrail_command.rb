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

        option %w[-a --after], "TIME", "filter events after this time" do |value|
          parse_datetime(value).end
        end

        option %w[-b --before], "TIME", "filter events before this time" do |value|
          parse_datetime(value).begin
        end

        option "--where", "FIELD=VALUE", "filter by field (can be specified multiple times)", :multivalued => true do |spec|
          field, value = spec.split("=", 2)
          raise ArgumentError, "invalid --where format, expected FIELD=VALUE" if field.nil? || value.nil?
          { field: field, pattern: compile_pattern(value) }
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

          # Add time range filters
          query_args[:start_time] = after if after
          query_args[:end_time] = before if before

          events = query_for(:lookup_events, :events, Swa::CloudTrail::Event, **query_args)

          # Apply programmatic filters
          events = events.select { |event| name === event.event_name } if name
          events = events.select { |event| source === event.event_source } if source

          # Apply --where filters
          if where_list && !where_list.empty?
            events = events.select do |event|
              where_list.all? { |condition| matches_where_condition?(event, condition) }
            end
          end

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

        def matches_where_condition?(event, condition)
          field_path = condition[:field]
          pattern = condition[:pattern]

          # Get the event data as a hash
          event_data = event.data

          # Extract field value using JMESPath
          begin
            field_value = JMESPath.search(field_path, event_data)
          rescue JMESPath::Errors::SyntaxError
            signal_error("invalid field path in --where: #{field_path}")
          end

          # Convert field value to string for matching
          return false if field_value.nil?
          field_value_str = field_value.to_s

          # Match using pattern (either string or regex)
          pattern === field_value_str
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
