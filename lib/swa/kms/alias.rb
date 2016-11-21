require "swa/record"

module Swa
  module KMS

    class Alias < Record

      def id
        name
      end

      def summary
        [
          pad(name, 36),
          key
        ].join("  ")
      end

      def name
        aws_record.alias_name
      end

      def key
        aws_record.target_key_id
      end

    end

  end
end
