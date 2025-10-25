# frozen_string_literal: true

require "aws-sdk-cloudformation"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/cloud_formation/stack"

module Swa

  module CLI

    class CloudFormationCommand < BaseCommand

      subcommand ["stack", "s"], "Show stack" do

        parameter "NAME", "stack name"

        include ItemBehaviour

        subcommand "template", "Show template" do

          def execute
            display_data(stack.template_data)
          end

        end

        %w[parameters outputs resources].each do |thing|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            subcommand "#{thing}", "Show #{thing}" do
              def execute
                display_data(stack.#{thing})
              end
            end
          RUBY
        end

        private

        def stack
          Swa::CloudFormation::Stack.new(cloud_formation.stack(name))
        end

        alias_method :item, :stack

      end

      subcommand ["stacks"], "Show stacks" do

        include CollectionBehaviour

        def collection
          query_for(:stacks, Swa::CloudFormation::Stack)
        end

      end

      protected

      def cloud_formation
        ::Aws::CloudFormation::Resource.new(aws_config)
      end

      def query_for(query_method, model)
        aws_resources = cloud_formation.public_send(query_method, query_options)
        model.list(aws_resources)
      end

    end

  end

end
