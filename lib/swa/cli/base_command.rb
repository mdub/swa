require "clamp"
require "console_logger"
require "jmespath"
require "multi_json"
require "yaml"

module Swa
  module CLI

    class BaseCommand < Clamp::Command

      option ["--region"], "REGION", "AWS region"
      option "--access-key", "KEY", "AWS access key",
             :attribute_name => :access_key_id
      option "--secret-key", "KEY", "AWS secret key",
             :attribute_name => :secret_access_key
      option "--session-token", "KEY", "AWS security token",
             :attribute_name => :session_token

      option ["-Y", "--yaml"], :flag, "output data in YAML format"

      option ["--debug"], :flag, "enable debugging"

      def run(arguments)
        super(arguments)
      rescue Aws::Errors::MissingCredentialsError
        signal_error "no credentials provided"
      rescue Aws::Errors::ServiceError => e
        signal_error e.message
      end

      protected

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

      def format_data(data)
        if yaml?
          YAML.dump(data)
        else
          MultiJson.dump(data, :pretty => true)
        end
      end

      def display_data(data, jmespath_expression = nil)
        unless jmespath_expression.nil?
          data = JMESPath.search(jmespath_expression, data)
        end
        puts format_data(data)
      end

    end

  end
end
