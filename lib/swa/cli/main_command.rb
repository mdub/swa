require "swa/cli/base_command"
require "swa/cli/ec2_command"
require "swa/cli/iam_command"
require "swa/cli/kms_command"

module Swa
  module CLI

    class MainCommand < BaseCommand

      subcommand "ec2", "EC2 stuff", Ec2Command
      subcommand "iam", "IAM stuff", IamCommand
      subcommand "kms", "KMS stuff", KmsCommand

      protected

      RESOURCE_PREFIXES_BY_SERVICE = {
        "ec2" => %w(ami i sg subnet vpc)
      }

      def subcommand_for_prefix(prefix)
        RESOURCE_PREFIXES_BY_SERVICE.each do |subcommand, prefixes|
          return subcommand if prefixes.member?(prefix)
        end
      end

      def parse(arguments)
        if arguments.first =~ /^(\w+)-/
          subcommand = subcommand_for_prefix($1)
          arguments = [subcommand] + arguments if subcommand
        end
        super(arguments)
      end

    end

  end
end
