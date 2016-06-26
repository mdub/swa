require "swa/resource"

module Swa
  module EC2

    module TaggedResource

      def tags
        aws_resource.tags.each_with_object({}) do |tag, result|
          result[tag.key] = tag.value
        end
      end

    end

  end
end
