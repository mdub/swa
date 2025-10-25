# frozen_string_literal: true

require "swa/resource"

module Swa

  module IAM

    class Group < Resource

      def id
        group.group_id
      end

      def name
        group.group_name
      end

      delegate :arn

      def summary
        arn
      end

      alias group aws_resource

    end

  end

end
