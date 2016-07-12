require "swa/resource"

module Swa
  module IAM

    class Role < Resource

      def summary
        role.name
      end

      private

      alias_method :role, :aws_resource

    end

  end
end
