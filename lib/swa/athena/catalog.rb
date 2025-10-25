# frozen_string_literal: true

require "swa/record"

module Swa

  module Athena

    class Catalog < Record

      def summary
        [
          pad(name, 48),
          type
        ].join("  ")
      end

      def name
        aws_record.catalog_name
      end

      delegate :type

    end

  end

end
