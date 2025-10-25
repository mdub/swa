require "swa/record"

module Swa
  module CloudTrail

    class Event < Record

      def summary
        [
          pad(event_id, 68),
          pad(event_time, 28),
          pad(event_source || "-", 25),
          pad(event_name, 40),
          pad(username || "-", 30)
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
