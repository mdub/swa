module Swa
  module EC2

    class Instance

      def initialize(aws_instance)
        @aws_instance = aws_instance
      end

      def i
        @aws_instance
      end

      def summary
        summary_fields.map { |x| (x || "-") }.join(" ")
      end

      def summary_fields
        name = tags["Name"]
        [
          i.instance_id,
          i.image_id,
          i.instance_type,
          i.state.name,
          (i.private_ip_address || "-"),
          (%("#{name}") if name)
        ]
      end

      def data
        {
          "InstanceId" => i.instance_id,
          "ImageId" => i.image_id,
          "Tags" => tags,
          "DATA" => i.data.to_h
        }
      end

      def tags
        i.tags.each_with_object({}) do |tag, result|
          result[tag.key] = tag.value
        end
      end

    end

  end
end
