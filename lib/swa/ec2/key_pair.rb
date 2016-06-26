require "swa/resource"

module Swa
  module EC2

    class KeyPair < Resource

      def summary
        [
          pad(name, 45),
          aws_resource.key_fingerprint
        ].join(" ")
      end

      def name
        aws_resource.name
      end

    end

  end
end
