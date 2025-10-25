require "swa/record"

module Swa

  module LakeFormation

    class ResourceInfo < Record

      def summary
        [
          resource_arn,
          role_arn
        ].join("  ")
      end

      delegate :resource_arn
      delegate :role_arn

    end

  end

end
