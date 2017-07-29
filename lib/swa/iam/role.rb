require "swa/resource"
require "swa/iam/credentials"

module Swa
  module IAM

    class Role < Resource

      def id
        role.role_id
      end

      def arn
        role.arn
      end

      def summary
        role.name
      end

      private

      alias_method :role, :aws_resource

    end

  end
end
