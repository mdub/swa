require "swa/resource"

module Swa
  module IAM

    class InstanceProfile < Resource

      def id
        profile.instance_profile_id
      end

      def summary
        arn
      end

      delegate :name
      delegate :arn

      private

      alias_method :profile, :aws_resource

    end

  end
end
