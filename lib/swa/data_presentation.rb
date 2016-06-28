module Swa

  module DataPresentation

    protected

    def quoted(value)
      %("#{value}") if value
    end

    def pad(s, width)
      s = (s || "").to_s
      s.ljust(width)
    end

    def rpad(s, width)
      s = (s || "").to_s
      s.rjust(width)
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
