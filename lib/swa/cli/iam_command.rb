require "aws-sdk-resources"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/iam/group"
require "swa/iam/instance_profile"
require "swa/iam/policy"
require "swa/iam/role"
require "swa/iam/user"

module Swa
  module CLI

    class IamCommand < BaseCommand

      subcommand ["group"], "Show group" do

        parameter "NAME", "group name/ARN"

        include ItemBehaviour

        private

        def item
          Swa::IAM::Group.new(iam.group(File.basename(name)))
        end

      end

      subcommand ["groups"], "Show groups" do

        self.description = <<-EOF
          List groups.
        EOF

        include CollectionBehaviour

        private

        def collection
          query_for(:groups, Swa::IAM::Group)
        end

      end

      subcommand ["instance-profile", "ip"], "Show instance-profile" do

        parameter "NAME", "name/ARN"

        include ItemBehaviour

        private

        def item
          Swa::IAM::InstanceProfile.new(iam.instance_profile(File.basename(name)))
        end

      end

      subcommand ["instance-profiles", "ips"], "Show instance-profiles" do

        self.description = <<-EOF
          List instance-profiles.
        EOF

        include CollectionBehaviour

        private

        def collection
          query_for(:instance_profiles, Swa::IAM::InstanceProfile)
        end

      end

      subcommand ["policy"], "Show policy" do

        parameter "ARN", "policy ARN"

        include ItemBehaviour

        private

        def item
          Swa::IAM::Policy.new(iam.policy(arn))
        end

        subcommand "document", "print current policy document" do

          def execute
            puts item.document
          end

        end

      end

      subcommand ["policies"], "Show policies" do

        self.description = <<-EOF
          List policies.
        EOF

        include CollectionBehaviour

        private

        def collection
          query_for(:policies, Swa::IAM::Policy)
        end

      end

      subcommand ["role"], "Show role" do

        parameter "NAME", "role name/ARN"

        include ItemBehaviour

        private

        def item
          Swa::IAM::Role.new(iam.role(File.basename(name)))
        end

      end

      subcommand ["roles"], "Show roles" do

        self.description = <<-EOF
          List roles.
        EOF

        include CollectionBehaviour

        private

        def collection
          query_for(:roles, Swa::IAM::Role)
        end

      end

      subcommand ["user"], "Show user" do

        parameter "NAME", "user name/ARN"

        include ItemBehaviour

        private

        def item
          Swa::IAM::User.new(iam.user(File.basename(name)))
        end

      end

      subcommand ["users"], "Show users" do

        self.description = <<-EOF
          List users.
        EOF

        include CollectionBehaviour

        private

        def collection
          query_for(:users, Swa::IAM::User)
        end

      end

      protected

      def iam
        ::Aws::IAM::Resource.new(aws_config)
      end

      def query_for(query_method, resource_model)
        aws_resources = iam.public_send(query_method)
        wrapped_resources = resource_model.list(aws_resources)
      end

    end

  end
end
