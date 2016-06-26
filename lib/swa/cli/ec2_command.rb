require "aws-sdk-resources"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/cli/tag_filter_options"
require "swa/ec2/key_pair"
require "swa/ec2/image"
require "swa/ec2/instance"
require "swa/ec2/security_group"

module Swa
  module CLI

    class Ec2Command < BaseCommand

      subcommand ["key-pair", "kp"], "show key-pair" do

        parameter "NAME", "key-pair name"

        include ItemBehaviour

        private

        def key_pair
          Swa::EC2::KeyPair.new(ec2.key_pair(name))
        end

        alias_method :item, :key_pair

      end

      subcommand ["key-pairs", "kps"], "list key-pairs" do

        include CollectionBehaviour

        private

        def key_pairs
          Swa::EC2::KeyPair.list(ec2.key_pairs)
        end

        alias_method :collection, :key_pairs

      end

      subcommand ["image", "ami"], "show image" do

        parameter "IMAGE-ID", "image id"

        include ItemBehaviour

        private

        def image
          Swa::EC2::Image.new(ec2.image(image_id))
        end

        alias_method :item, :image

      end

      subcommand ["images", "amis"], "list images" do

        option "--owned-by", "OWNER", "limit to those with selected owner", :default => "self"
        option "--named", "PATTERN", "limit to those with matching name"

        include TagFilterOptions
        include CollectionBehaviour

        private

        def named=(name_pattern)
          add_filter("name", name_pattern)
        end

        def images
          options = {
            :owners => [owned_by]
          }
          options[:filters] = filters unless filters.empty?
          Swa::EC2::Image.list(ec2.images(options))
        end

        alias_method :collection, :images

      end

      subcommand ["instance", "i"], "show instance" do

        parameter "INSTANCE-ID", "instance id"

        include ItemBehaviour

        private

        def instance
          Swa::EC2::Instance.new(ec2.instance(instance_id))
        end

        alias_method :item, :instance

      end

      subcommand ["instances", "is"], "list instances" do

        option "--named", "NAME", "with matching name" do |name|
          add_tag_filter("Name", name)
        end

        option ["--state"], "STATE", "with specified status" do |state|
          add_filter("instance-state-name", state)
        end

        option ["--image", "--ami"], "IMAGE-ID", "with specified AMI" do |image_id|
          add_filter("image-id", image_id)
        end

        option ["--group", "--sg"], "GROUP-ID", "in specified security-group" do |group|
          if group =~ /^sg-/
            add_filter("instance.group-id", group)
          else
            add_filter("instance.group-name", group)
          end
        end

        include TagFilterOptions
        include CollectionBehaviour

        private

        def instances
          options = {}
          options[:filters] = filters unless filters.empty?
          Swa::EC2::Instance.list(ec2.instances(options))
        end

        alias_method :collection, :instances

      end

      subcommand ["security-group", "sg"], "show security-group" do

        parameter "GROUP-ID", "security-group id"

        include ItemBehaviour

        private

        def security_group
          Swa::EC2::SecurityGroup.new(ec2.security_group(group_id))
        end

        alias_method :item, :security_group

      end

      subcommand ["security-groups", "sgs"], "list security-groups" do

        include TagFilterOptions
        include CollectionBehaviour

        private

        def security_groups
          options = {}
          options[:filters] = filters unless filters.empty?
          Swa::EC2::SecurityGroup.list(ec2.security_groups(options))
        end

        alias_method :collection, :security_groups

      end

      protected

      def ec2
        ::Aws::EC2::Resource.new(aws_config)
      end

    end

  end
end
