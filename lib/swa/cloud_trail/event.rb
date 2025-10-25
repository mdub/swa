# frozen_string_literal: true

require "swa/record"
require "multi_json"

module Swa

  module CloudTrail

    class Event < Record

      def summary
        [
          pad(event_time, 25),
          pad(event_id, 36),
          qualified_event_name
        ].join("  ")
      end

      delegate :event_id
      delegate :event_name
      delegate :event_source
      delegate :username

      def event_time
        aws_record.event_time.iso8601
      end

      def abbreviated_event_source
        event_source.sub(/\.amazonaws\.com\z/, "")
      end

      def qualified_event_name
        [abbreviated_event_source, event_name].join(":")
      end

      def id
        event_id
      end

      def data
        MultiJson.load(aws_record.cloud_trail_event)
      end

    end

  end

end
