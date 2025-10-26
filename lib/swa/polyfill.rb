# frozen_string_literal: true

# Polyfills for older Rubies

class Array

  unless method_defined?(:to_h)
    def to_h
      to_h
    end
  end

end
