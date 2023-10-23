require "swa/record"

module Swa
  module Glue

    class JobRun < Record

      def summary
        [
          pad(id, 68),
          pad(job_run_state, 8),
          pad(started_on, 28)
        ].join(" ")
      end

      delegate :id
      delegate :job_run_state

      def started_on
        aws_record.started_on.iso8601
      end
      
    end

  end
end
