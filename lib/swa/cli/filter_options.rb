require "clamp"

module Swa
  module CLI

    module FilterOptions

      extend Clamp::Option::Declaration

      option "--filter", "NAME=VALUE", "apply a filter",
             :multivalued => true, :attribute_name => :filters

      protected

      def filters
        @filters ||= []
      end

      def add_filter(name, *values)
        filters << {
          name: name,
          values: values
        }
      end

      def append_to_filters(arg)
        name, value = arg.split("=", 2)
        raise ArgumentError, "no value supplied" unless value
        add_filter(name, value)
      end

    end

  end
end
