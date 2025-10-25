require "swa/record"

module Swa

  module LakeFormation

    class Tag < Record

      def summary
        [
          tag_key,
          tag_values.join(",")
        ].join("=")
      end

      delegate :tag_key
      delegate :tag_values

    end

  end

end
