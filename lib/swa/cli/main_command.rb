require "swa/cli/base_command"
require "swa/cli/ec2_command"

module Swa
  module CLI

    class MainCommand < BaseCommand

      subcommand "ec2", "EC2 stuff", Ec2Command

    end

  end
end
