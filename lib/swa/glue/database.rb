require "swa/record"

module Swa
  module Glue

    class Database < Record

      def summary
        name
      end

      delegate :name

    end

  end
end
