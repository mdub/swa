require "cgi"
require "swa/resource"

module Swa

  module IAM

    class RolePolicy < Resource

      def name
        role_policy.name
      end

      def summary
        name
      end

      def document
        CGI.unescape(role_policy.policy_document)
      end

      alias role_policy aws_resource

    end

  end

end
