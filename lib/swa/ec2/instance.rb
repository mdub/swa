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
        [
          pad(i.instance_id, 11),
          pad(i.image_id, 13),
          pad(i.instance_type, 10),
          pad(i.state.name, 11),
          pad(i.private_ip_address, 15),
          pad(i.public_ip_address, 15),
          quoted_name
        ].join(" ")
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

      def name
        tags["Name"]
      end

      def quoted_name
        %("#{name}") if name
      end

      private

      def pad(s, width)
        s = (s || "").to_s
        s.ljust(width)
      end

    end

  end
end
