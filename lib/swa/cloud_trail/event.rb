require "swa/record"
require "multi_json"

module Swa
  module CloudTrail

    class Event < Record

      def summary
        [
          pad(event_time, 25),
          pad(event_id, 36),
          [event_source,event_name].join(":")
        ].join("  ")
      end

      delegate :event_id
      delegate :event_name
      delegate :username

      def event_time
        aws_record.event_time.iso8601
      end

      def event_source
        aws_record.event_source.sub(/\.amazonaws\.com\z/, "")
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
