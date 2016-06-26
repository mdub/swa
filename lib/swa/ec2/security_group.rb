require "swa/ec2/tagged_resource"
require "swa/resource"

module Swa
  module EC2

    class SecurityGroup < Resource

      def summary
        [
          pad(sg.group_id, 12),
          pad(sg.vpc_id, 13),
          quoted(sg.group_name)
        ].join(" ")
      end

      def name
        aws_resource.name
      end

      private

      alias_method :sg, :aws_resource

    end

  end
end
