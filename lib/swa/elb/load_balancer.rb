# frozen_string_literal: true

require "swa/record"

module Swa

  module ELB

    class LoadBalancer < Record

      def summary
        [
          pad(name, 36),
          scheme
        ].join("  ")
      end

      def name
        aws_record.load_balancer_name
      end

      delegate :scheme

    end

  end

end
