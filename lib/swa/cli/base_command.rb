require "chronic"
require "clamp"
require "console_logger"
require "jmespath"
require "multi_json"
require "swa/cli/data_output"
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

      include DataOutput

      option ["--debug"], :flag, "enable debugging"

      def run(arguments)
        super(arguments)
      rescue Aws::Errors::MissingCredentialsError
        signal_error "no credentials provided"
      rescue Aws::Errors::MissingRegionError, Aws::Errors::InvalidRegionError => e
        signal_error e.message
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

      def parse_datetime(datetime_string)
        result = Chronic.parse(datetime_string, :guess => false, :endian_precedence => :little)
        raise ArgumentError, "unrecognised date/time #{datetime_string.inspect}" unless result
        result
      end

    end

  end
end
