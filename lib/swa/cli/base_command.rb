require "clamp"
require "console_logger"
require "jmespath"
require "multi_json"
require "yaml"

module Swa
  module CLI

    class BaseCommand < Clamp::Command

      option "--region", "REGION", "AWS region"
      option "--access-key", "KEY", "AWS access key",
             :attribute_name => :access_key_id
      option "--secret-key", "KEY", "AWS secret key",
             :attribute_name => :secret_access_key
      option "--session-token", "KEY", "AWS security token",
             :attribute_name => :session_token

      option "--format", "FORMAT", "format for data output",
             :attribute_name => :output_format,
             :environment_variable => "SWA_OUTPUT_FORMAT",
             :default => "YAML"

      option ["--json", "-J"], :flag, "output data in JSON format" do
        self.output_format = "JSON"
      end

      option ["--yaml", "-Y"], :flag, "output data in YAML format" do
        self.output_format = "YAML"
      end

      option ["--debug"], :flag, "enable debugging"

      def run(arguments)
        super(arguments)
      rescue Aws::Errors::MissingCredentialsError
        signal_error "no credentials provided"
      rescue Aws::Errors::ServiceError => e
        signal_error e.message
      end

      protected

      def parse_subcommand
        return false unless self.class.has_subcommands?
        request_help if subcommand_name == "?"
        super
      end

      def logger
        @logger ||= ConsoleLogger.new($stderr, debug?)
      end

      def aws_config
        {
          :access_key_id => access_key_id,
          :secret_access_key => secret_access_key,
          :session_token => session_token,
          :region => region,
          :logger => logger, :log_level => :debug
        }.reject { |_k, v| v.nil? }
      end

      def parse(arguments)
        if arguments.first =~ /^(\w+)-[0-9a-f]+$/
          arguments = [$1] + arguments if self.class.find_subcommand($1)
        end
        super(arguments)
      end

      def output_format=(arg)
        arg = arg.upcase
        unless %w(JSON YAML).member?(arg)
          raise ArgumentError, "unrecognised data format: #{arg.inspect}"
        end
        @output_format = arg
      end

      def format_data(data)
        case output_format
        when "JSON"
          MultiJson.dump(data, :pretty => true)
        when "YAML"
          YAML.dump(data)
        else
          raise "bad output format: #{output_format}"
        end
      end

      def display_data(data, jmespath_expression = nil)
        unless jmespath_expression.nil?
          data = JMESPath.search(jmespath_expression, data)
        end
        puts format_data(data)
      rescue JMESPath::Errors::SyntaxError => e
        signal_error("invalid JMESPath expression")
      end

    end

  end
end
