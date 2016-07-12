require "swa/resource"

module Swa
  module IAM

    class User < Resource

      def summary
        user.arn
      end

      private

      alias_method :user, :aws_resource

    end

  end
end
