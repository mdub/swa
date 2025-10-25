require "swa/record"

module Swa

  module Athena

    class QueryExecution < Record

      def summary
        [
          pad(id, 48),
          pad(state, 12)
        ].join("  ")
      end

      delegate :id

      def id
        aws_record.query_execution_id
      end

      def state
        aws_record.status.state
      end

    end

  end

end
