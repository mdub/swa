require "swa/cli/base_command"
require "swa/cli/cloud_formation_command"
require "swa/cli/ec2_command"
require "swa/cli/iam_command"
require "swa/cli/kms_command"
require "swa/cli/s3_command"

module Swa
  module CLI

    class MainCommand < BaseCommand

      subcommand ["cf", "cloudformation"], "CloudFormation stuff", CloudFormationCommand
      subcommand "ec2", "EC2 stuff", Ec2Command
      subcommand "iam", "IAM stuff", IamCommand
      subcommand "kms", "KMS stuff", KmsCommand
      subcommand "s3", "S3 stuff", S3Command

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
        case arguments.first
        when /^(\w+)-/
          subcommand = subcommand_for_prefix($1)
          arguments = [subcommand] + arguments if subcommand
        when %r{^s3://([^/]+)/(.+/)?$}
          arguments[0, 1] = ["s3", "bucket", $1, "objects", "--prefix", $2]
        when %r{^s3://([^/]+)/(.+)\*$}
          arguments[0, 1] = ["s3", "bucket", $1, "objects", "--prefix", $2]
        when %r{^s3://([^/]+)/(.+)$}
          arguments[0, 1] = ["s3", "bucket", $1, "object", $2]
        when %r{^s3://([^/]+)$}
          arguments[0, 1] = ["s3", "bucket", $1]
        end
        super(arguments)
      end

    end

  end
end
