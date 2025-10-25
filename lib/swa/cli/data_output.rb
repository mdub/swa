require "clamp"

module Swa

  module CLI

    module DataOutput

      extend Clamp::Option::Declaration

      option "--format", "FORMAT", "format for data output",
             attribute_name: :output_format,
             environment_variable: "SWA_OUTPUT_FORMAT",
             default: "YAML"

      option ["--json", "-J"], :flag, "output data in JSON format" do
        self.output_format = "JSON"
      end

      option ["--yaml", "-Y"], :flag, "output data in YAML format" do
        self.output_format = "YAML"
      end

      def output_format=(arg)
        arg = arg.upcase
        raise ArgumentError, "unrecognised data format: #{arg.inspect}" unless %w[JSON YAML].member?(arg)

        @output_format = arg
      end

      protected

      def format_data(data)
        case output_format
        when "JSON"
          MultiJson.dump(data, pretty: true)
        when "YAML"
          YAML.dump(data)
        else
          raise "bad output format: #{output_format}"
        end
      end

      def display_data(data, jmespath_expression = nil)
        data = JMESPath.search(jmespath_expression, data) unless jmespath_expression.nil?
        puts format_data(data)
      rescue JMESPath::Errors::SyntaxError
        signal_error("invalid JMESPath expression")
      end

    end

  end

end
