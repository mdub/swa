# Polyfills for older Rubies

class Array

  unless method_defined?(:to_h)
    def to_h
      Hash[self]
    end
  end

end
