require "aws-sdk-resources"
require "clamp"
require "console_logger"
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

      option ["--debug"], :flag, "enable debugging"

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

      protected

      def parse(arguments)
        if arguments.first =~ /^(\w+)-[0-9a-f]+$/
          arguments = [$1] + arguments if self.class.find_subcommand($1)
        end
        super(arguments)
      end

      def display_data(data)
        puts YAML.dump(data)
      end

    end

  end
end
