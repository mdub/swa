require "swa/record"

module Swa
  module KMS

    class Key < Record

      def summary
        id
      end

      def id
        aws_record.key_id
      end

      def name
        aws_record.key_name
      end

    end

  end
end
