require "aws-sdk-resources"
require "swa/cli/base_command"
require "swa/ec2/image"
require "swa/ec2/instance"

module Swa
  module CLI

    class Ec2Command < BaseCommand

      subcommand ["instances", "is"], "list instances" do

        option "--filter", "NAME=VALUE", "apply a filter",
               :multivalued => true, :attribute_name => :filters
        option "--tagged", "KEY[=VALUE]", "with matching tag",
               :multivalued => true, :attribute_name => :tag_list
        option "--named", "NAME", "with matching name"
        option "--stack", "NAME", "from the named CloudFormation stack"

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

        protected

        def append_to_filters(arg)
          name, value = arg.split("=", 2)
          raise ArgumentError, "no value supplied" unless value
          add_filter(name, value)
        end

        def append_to_tag_list(arg)
          key, value_pattern = arg.split("=", 2)
          add_tag_filter(key, value_pattern)
        end

        def named=(name)
          add_tag_filter("Name", name)
        end

        def stack=(name)
          add_tag_filter("aws:cloudformation:stack-name", name)
        end

        private

        def filters
          @filters ||= []
        end

        def add_filter(name, *values)
          filters << {
            name: name,
            values: values
          }
        end

        def add_tag_filter(key, value_pattern = nil)
          if value_pattern
            add_filter("tag:#{key}", value_pattern)
          else
            add_filter("tag-key", key)
          end
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

        def images
          options = {
            :owners => [owned_by]
          }
          # options[:filters] = filters unless filters.empty?
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
