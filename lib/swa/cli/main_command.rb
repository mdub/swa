require "swa/cli/base_command"
require "swa/cli/ec2_command"
require "swa/cli/iam_command"

module Swa
  module CLI

    class MainCommand < BaseCommand

      subcommand "ec2", "EC2 stuff", Ec2Command
      subcommand "iam", "IAM stuff", IamCommand

    end

  end
end
