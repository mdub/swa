require "swa/resource"
require "swa/ec2/tagged_resource"

module Swa
  module EC2

    class Instance < Resource

      include TaggedResource

      def summary
        [
          pad(i.instance_id, 10),
          pad(i.image_id, 12),
          pad(i.instance_type, 10),
          pad(i.state.name, 10),
          pad(i.private_ip_address, 14),
          pad(i.public_ip_address, 14),
          quoted(name)
        ].join("  ")
      end

      def name
        tags["Name"]
      end

      def console_output
        i.console_output.output
      end

      delegate :launch_time
      delegate :stop, :start, :reboot, :terminate

      private

      alias_method :i, :aws_resource

    end

  end
end
