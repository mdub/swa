# frozen_string_literal: true

require "swa/record"

module Swa

  module Athena

    class WorkGroup < Record

      def summary
        [
          pad(name, 48),
          pad(state, 12),
          description
        ].join("  ")
      end

      delegate :name
      delegate :state
      delegate :description

    end

  end

end
