require "aws-sdk-resources"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/cli/tag_filter_options"
require "swa/iam/role"

module Swa
  module CLI

    class IamCommand < BaseCommand

      subcommand ["role"], "Show role" do

        parameter "ROLE-NAME", "role name"

        include ItemBehaviour

        private

        def item
          Swa::IAM::Role.new(iam.role(role_name))
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
