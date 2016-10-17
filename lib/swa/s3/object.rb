require "swa/resource"

module Swa
  module S3

    class Object < Resource

      def summary
        object.key
      end

      private

      alias_method :object, :aws_resource

    end

  end
end
