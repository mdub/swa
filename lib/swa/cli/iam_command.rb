# frozen_string_literal: true

require "aws-sdk-iam"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/iam/credentials"
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

        def collection
          query_for(:groups, Swa::IAM::Group)
        end

      end

      subcommand ["instance-profile", "ip"], "Show instance-profile" do

        parameter "NAME", "name/ARN"

        include ItemBehaviour

        def item
          Swa::IAM::InstanceProfile.new(iam.instance_profile(File.basename(name)))
        end

      end

      subcommand ["instance-profiles", "ips"], "Show instance-profiles" do

        self.description = <<-EOF
          List instance-profiles.
        EOF

        include CollectionBehaviour

        def collection
          query_for(:instance_profiles, Swa::IAM::InstanceProfile)
        end

      end

      subcommand ["policy"], "Show policy" do

        parameter "ARN", "policy ARN"

        include ItemBehaviour

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

        option "--scope", "SCOPE", "'AWS' or 'Local'" do |arg|
          case arg.downcase
          when "all", "*"
            "All"
          when "local"
            "Local"
          when "aws"
            "AWS"
          else
            raise ArgumentError, "must be one of 'All', 'AWS' or 'Local'"
          end
        end

        include CollectionBehaviour

        def collection
          query_for(:policies, Swa::IAM::Policy, query_options)
        end

        def query_options
          { scope: scope }.reject { |_k, v| v.nil? }
        end

      end

      subcommand ["role"], "Show role" do

        parameter "NAME", "role name/ARN"

        include ItemBehaviour

        def role
          Swa::IAM::Role.new(iam.role(File.basename(name)))
        end

        def item
          role
        end

        subcommand "assume", "Assume the role" do

          option "--session-name", "NAME", "STS session-name",
                 environment_variable: "USER",
                 default: "swa"

          parameter "[COMMAND] ...", "command to execute"

          def execute
            env = assume.to_env
            if command_list.empty?
              dump_env(env)
            else
              exec(env, *command_list)
            end
          end

          def assume
            response = sts_client.assume_role(
              role_arn: item.arn,
              role_session_name: session_name
            )
            Swa::IAM::Credentials.new(response.credentials.to_h)
          end

          def dump_env(env)
            env.each do |k, v|
              puts "#{k}=#{v}"
            end
          end

        end

        subcommand ["attached-policies"], "Show attached managed policies." do

          include CollectionBehaviour

          def collection
            role.attached_policies
          end

        end

        subcommand ["policies"], "Show role policies." do

          include CollectionBehaviour

          def collection
            role.policies
          end

        end

        subcommand ["policy"], "Show named role policy" do

          parameter "NAME", "policy name", attribute_name: :policy_name

          include ItemBehaviour

          subcommand "document", "print policy document" do

            def execute
              puts item.document
            end

          end

          def item
            role.policy(policy_name)
          end

        end

        subcommand ["simulate"], "Simulate an action" do

          parameter "ACTION ...", "action to simulate"

          option %w[--resource -R], "RESOURCE", "resource ARN", multivalued: true do |arg|
            arg.sub(%r{\As3://}, "arn:aws:s3:::")
          end

          def execute
            evaluation_results = iam.client.simulate_principal_policy(
              policy_source_arn: role.arn,
              action_names: action_list,
              resource_arns: resource_list
            ).each.flat_map(&:evaluation_results).map { |result| stringify_keys(result.to_h) }
            display_data(evaluation_results)
          end

          include DataPresentation

        end

        subcommand "trust-policy", "print AssumeRolePolicyDocument" do

          self.default_subcommand = "data"

          subcommand ["data", "d"], "Display as data" do

            parameter "[QUERY]", "JMESPath expression"

            def execute
              display_data(trust_policy_data, query)
            end

            def trust_policy_data
              JSON.parse(role.assume_role_policy_document)
            end

          end

          subcommand ["document", "doc"], "Print source document" do

            def execute
              puts role.assume_role_policy_document
            end

          end

        end

      end

      subcommand ["roles"], "Show roles" do

        self.description = <<-EOF
          List roles.
        EOF

        include CollectionBehaviour

        def collection
          query_for(:roles, Swa::IAM::Role)
        end

      end

      subcommand ["user"], "Show user" do

        parameter "NAME", "user name/ARN"

        include ItemBehaviour

        def item
          Swa::IAM::User.new(iam.user(File.basename(name)))
        end

      end

      subcommand ["users"], "Show users" do

        self.description = <<-EOF
          List users.
        EOF

        include CollectionBehaviour

        def collection
          query_for(:users, Swa::IAM::User)
        end

      end

      protected

      def iam
        ::Aws::IAM::Resource.new(aws_config)
      end

      def query_for(query_method, resource_model, *query_args)
        aws_resources = iam.public_send(query_method, *query_args)
        resource_model.list(aws_resources)
      end

      def sts_client
        ::Aws::STS::Client.new(aws_config)
      end

    end

  end

end
