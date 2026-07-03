# frozen_string_literal: true

require "swa/record"

module Swa

  module Glue

    class TableVersion < Record

      def summary
        [
          rpad(version_id, 8),
          update_time
        ].join("  ")
      end

      def id
        version_id
      end

      delegate :version_id

      def update_time
        aws_record.table&.update_time&.iso8601
      end

    end

  end

end
