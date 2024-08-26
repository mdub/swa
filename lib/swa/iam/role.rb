require "swa/resource"
require "swa/iam/credentials"
require "swa/iam/policy"
require "swa/iam/role_policy"
require "uri"

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

      def attached_policies
        Policy.list(role.attached_policies)
      end

      def policies
        RolePolicy.list(role.policies)
      end

      def policy(name)
        RolePolicy.new(role.policy(name))
      end

      def assume_role_policy_document
        URI.decode_uri_component(role.assume_role_policy_document)
      end

      private

      alias_method :role, :aws_resource

    end

  end
end
