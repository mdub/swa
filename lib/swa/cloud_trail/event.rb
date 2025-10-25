require "swa/record"

module Swa
  module CloudTrail

    class Event < Record

      def summary
        [
          pad(event_time, 25),
          pad(event_id, 36),
          pad(event_source || "-", 24),
          event_name
        ].join("  ")
      end

      delegate :event_id
      delegate :event_name
      delegate :username
      delegate :event_source

      def event_time
        aws_record.event_time.iso8601
      end

      def id
        event_id
      end

    end

  end
end
