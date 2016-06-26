require "swa/resource"
require "swa/ec2/tagged_resource"

module Swa
  module EC2

    class Image < Resource

      include TaggedResource

      def summary
        [
          pad(ami.image_id, 13),
          quoted_name
        ].join(" ")
      end

      def name
        ami.name
      end

      def quoted_name
        %("#{name}") if name
      end

      private

      alias_method :ami, :aws_resource

    end

  end
end
