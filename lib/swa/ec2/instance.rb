# frozen_string_literal: true

require "base64"
require "swa/resource"
require "swa/ec2/tagged_resource"

module Swa

  module EC2

    class Instance < Resource

      include TaggedResource

      def id
        i.instance_id
      end

      def summary
        [
          field(i, :instance_id),
          field(i, :image_id),
          field(i, :instance_type),
          pad(i.state.name, 10),
          field(i, :private_ip_address),
          field(i, :public_ip_address),
          quoted(name),
          decorated_key_name
        ].join("  ")
      end

      def name
        tags["Name"]
      end

      def console_output
        encoded_output = i.console_output.output
        Base64.decode64(encoded_output) if encoded_output
      end

      delegate :launch_time
      delegate :stop, :start, :reboot, :terminate

      private

      alias i aws_resource

      def decorated_key_name
        "🔑 #{i.key_name}" if i.key_name
      end

    end

  end

end
