# frozen_string_literal: true

require "swa/record"

module Swa

  module Glue

    class Database < Record

      def summary
        name
      end

      delegate :catalog_id
      delegate :name

    end

  end

end
