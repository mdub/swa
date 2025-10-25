require "swa/record"

module Swa

  module Athena

    class Database < Record

      def summary
        [
          pad(name, 48),
          description
        ].join("  ")
      end

      delegate :name
      delegate :description

    end

  end

end
