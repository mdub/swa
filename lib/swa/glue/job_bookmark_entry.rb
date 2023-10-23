require "swa/record"

module Swa
  module Glue

    class JobBookmarkEntry < Record

      def summary
        job_bookmark
      end

      delegate :job_bookmark
      
    end

  end
end
