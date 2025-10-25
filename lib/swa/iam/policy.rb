require "cgi"
require "swa/resource"

module Swa

  module IAM

    class Policy < Resource

      def id
        policy.policy_id
      end

      def summary
        [
          pad(policy.arn, 60),
          quoted(policy.description)
        ].join("  ")
      end

      def document
        CGI.unescape(policy.default_version.document)
      end

      alias policy aws_resource

    end

  end

end
