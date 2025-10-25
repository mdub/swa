# frozen_string_literal: true

require "swa/record"

module Swa

  module Glue

    class Table < Record

      def summary
        name
      end

      delegate :name

    end

  end

end
