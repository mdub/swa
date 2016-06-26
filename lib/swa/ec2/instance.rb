require "swa/resource"
require "swa/ec2/tagged_resource"

module Swa
  module EC2

    class Instance < Resource

      include TaggedResource

      def summary
        [
          pad(i.instance_id, 11),
          pad(i.image_id, 13),
          pad(i.instance_type, 10),
          pad(i.state.name, 11),
          pad(i.private_ip_address, 15),
          pad(i.public_ip_address, 15),
          quoted(name)
        ].join(" ")
      end

      def name
        tags["Name"]
      end

      private

      alias_method :i, :aws_resource

    end

  end
end
