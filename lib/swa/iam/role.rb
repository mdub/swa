require "swa/resource"
require "swa/iam/credentials"
require "swa/iam/role_policy"

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

      def policies
        RolePolicy.list(role.policies)
      end

      def policy(name)
        RolePolicy.new(role.policy(name))
      end

      private

      alias_method :role, :aws_resource

    end

  end
end
