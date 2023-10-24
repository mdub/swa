require "swa/record"

module Swa
  module Glue

    class Crawl < Record

      def summary
        [
          crawl_id,
          pad(state, 9),
          start_time.iso8601,
          end_time.iso8601
        ].join("  ")
      end

      delegate :crawl_id
      delegate :state
      delegate :start_time
      delegate :end_time
      
    end

  end
end
