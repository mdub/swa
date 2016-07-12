require "cgi"
require "swa/resource"

module Swa
  module IAM

    class Policy < Resource

      def summary
        [
          pad(policy.arn, 60),
          quoted(policy.description)
        ].join("  ")
      end

      def document
        CGI.unescape(policy.default_version.document)
      end

      private

      alias_method :policy, :aws_resource

    end

  end
end
