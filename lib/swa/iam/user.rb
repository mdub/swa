# frozen_string_literal: true

require "swa/resource"

module Swa

  module IAM

    class User < Resource

      def id
        user.user_id
      end

      def summary
        user.name
      end

      alias user aws_resource

    end

  end

end
