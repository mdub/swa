# frozen_string_literal: true

require "swa/record"

module Swa

  module Glue

    class Job < Record

      def summary
        [
          pad(name, 48),
          role
        ].join("  ")
      end

      delegate :name
      delegate :role

    end

  end

end
