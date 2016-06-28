require "forwardable"
require "swa/resource"
require "swa/ec2/tagged_resource"

module Swa
  module EC2

    class Image < Resource

      include TaggedResource

      def summary
        [
          pad(ami.image_id, 12),
          ami.creation_date.sub(".000Z", "Z"),
          quoted(name)
        ].join("  ")
      end

      def name
        ami.name
      end

      extend Forwardable

      def_delegators :ami, :creation_date

      private

      alias_method :ami, :aws_resource

    end

  end
end
