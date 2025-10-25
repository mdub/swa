require "swa/record"

module Swa

  module Glue

    class Crawler < Record

      def summary
        [
          pad(name, 48),
          pad(state, 10),
          pad(last_crawl_status, 12),
          role
        ].join("  ")
      end

      delegate :name
      delegate :state
      delegate :role

      def last_crawl_status
        aws_record.last_crawl&.status || "NEW"
      end

    end

  end

end
