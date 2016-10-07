module Swa

  module DataPresentation

    protected

    def quoted(value)
      %("#{value}") if value && !value.empty?
    end

    def pad(s, width)
      s = (s || "").to_s
      s.ljust(width)
    end

    def rpad(s, width)
      s = (s || "").to_s
      s.rjust(width)
    end

    WIDTH_BY_TYPE = {
      :availability_zone => 15,
      :cidr_block => 18,
      :group_id => 11,
      :image_id => 12,
      :instance_id => 19,
      :instance_type => 10,
      :private_ip_address => 14,
      :public_ip_address => 14,
      :snapshot_id => 22,
      :subnet_id => 15,
      :volume_id => 21,
      :volume_type => 9,
      :vpc_id => 12
    }

    def field(resource, field_name, type = field_name)
      width = WIDTH_BY_TYPE.fetch(type.to_sym)
      value = resource.public_send(field_name)
      pad(value, width)
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
