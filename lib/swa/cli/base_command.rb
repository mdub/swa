require "aws-sdk-resources"
require "clamp"
require "yaml"

module Swa
  module CLI

    class BaseCommand < Clamp::Command

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
