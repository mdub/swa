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
        camelize_keys(i.data.to_h)
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

      def camelize_keys(data)
        case data
        when Hash
          data.map { |k,v| [camelize(k), camelize_keys(v)] }.to_h
        when Array
          data.map { |v| camelize_keys(v) }
        else
          data
        end
      end

      def camelize(symbol)
        symbol.to_s.split("_").map(&:capitalize).join("")
      end

    end

  end
end
