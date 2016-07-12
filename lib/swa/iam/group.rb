require "swa/resource"

module Swa
  module IAM

    class Group < Resource

      def summary
        group.arn
      end

      private

      alias_method :group, :aws_resource

    end

  end
end
