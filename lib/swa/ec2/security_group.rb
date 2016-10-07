require "swa/ec2/tagged_resource"
require "swa/resource"

module Swa
  module EC2

    class SecurityGroup < Resource

      def summary
        [
          field(sg, :group_id),
          field(sg, :vpc_id),
          quoted(sg.group_name)
        ].join("  ")
      end

      def name
        aws_resource.name
      end

      private

      alias_method :sg, :aws_resource

    end

  end
end
