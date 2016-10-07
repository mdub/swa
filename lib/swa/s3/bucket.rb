require "base64"
require "swa/resource"

module Swa
  module S3

    class Bucket < Resource

      def summary
        bucket.name
      end

      private

      alias_method :bucket, :aws_resource

    end

  end
end
