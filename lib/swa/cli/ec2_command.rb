require "aws-sdk-resources"
require "swa/cli/base_command"
require "swa/cli/tag_filter_options"
require "swa/ec2/image"
require "swa/ec2/instance"

module Swa
  module CLI

    class Ec2Command < BaseCommand

      subcommand ["instances", "is"], "list instances" do

        option "--named", "NAME", "with matching name"

        include TagFilterOptions

        self.default_subcommand = "summary"

        subcommand ["summary", "s"], "brief summary (one per line)" do

          def execute
            instances.each do |i|
              puts i.summary
            end
          end

        end

        subcommand ["detail", "d"], "full details" do

          def execute
            display_data(instances.map(&:data).to_a)
          end

        end

        private

        def named=(name)
          add_tag_filter("Name", name)
        end

        def instances
          options = {}
          options[:filters] = filters unless filters.empty?
          ec2.instances(options).lazy.map(&Swa::EC2::Instance.method(:new))
        end

      end

      subcommand ["instance", "i"], "list instances" do

        parameter "INSTANCE-ID", "instance ID"

        self.default_subcommand = "summary"

        subcommand ["summary", "s"], "brief summary (one per line)" do

          def execute
            puts instance.summary
          end

        end

        subcommand ["detail", "d"], "full details" do

          def execute
            display_data(instance.data)
          end

        end

        private

        def instance
          Swa::EC2::Instance.new(ec2.instance(instance_id))
        end

      end

      subcommand ["images", "amis"], "list images" do

        option "--owned-by", "OWNER", "limit to those with selected owner", :default => "self"
        option "--named", "PATTERN", "limit to those with matching name"

        include TagFilterOptions

        self.default_subcommand = "summary"

        subcommand ["summary", "s"], "brief summary (one per line)" do

          def execute
            images.each do |i|
              puts i.summary
            end
          end

        end

        subcommand ["detail", "d"], "full details" do

          def execute
            display_data(images.map(&:data).to_a)
          end

        end

        private

        def named=(name_pattern)
          add_filter("name", name_pattern)
        end

        def images
          options = {
            :owners => [owned_by]
          }
          options[:filters] = filters unless filters.empty?
          ec2.images(options).lazy.map(&Swa::EC2::Image.method(:new))
        end

      end

      protected

      def ec2
        ::Aws::EC2::Resource.new
      end

    end

  end
end
