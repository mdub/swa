require "swa/record"

module Swa

  module LakeFormation

    class Permission < Record

      def summary
        [
          principal_id,
          permissions.join(","),
          resource_summary
        ].join("  ")
      end

      delegate :permissions
      delegate :principal

      def principal_id
        aws_record.principal.data_lake_principal_identifier
      end

      def resource_summary
        h = aws_record.resource.to_hash.compact
        type, details = h.first
        "#{type}:#{details.values.join('/')}"
      end

    end

  end

end
