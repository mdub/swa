require "aws-sdk-resources"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/cli/tag_filter_options"
require "swa/ec2/key_pair"
require "swa/ec2/image"
require "swa/ec2/instance"

module Swa
  module CLI

    class Ec2Command < BaseCommand

      subcommand ["instances", "is"], "list instances" do

        option "--named", "NAME", "with matching name"

        include TagFilterOptions
        include CollectionBehaviour

        private

        def named=(name)
          add_tag_filter("Name", name)
        end

        def instances
          options = {}
          options[:filters] = filters unless filters.empty?
          Swa::EC2::Instance.list(ec2.instances(options))
        end

        alias_method :collection, :instances

      end

      subcommand ["instance", "i"], "show instance" do

        parameter "INSTANCE-ID", "instance ID"

        include ItemBehaviour

        private

        def instance
          Swa::EC2::Instance.new(ec2.instance(instance_id))
        end

        alias_method :item, :instance

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

      subcommand ["image", "ami"], "show image" do

        parameter "IMAGE-ID", "image ID"

        include ItemBehaviour

        private

        def image
          Swa::EC2::Image.new(ec2.image(image_id))
        end

        alias_method :item, :image

      end

      subcommand ["key-pairs", "kps"], "list key-pairs" do

        include CollectionBehaviour

        private

        def key_pairs
          Swa::EC2::KeyPair.list(ec2.key_pairs)
        end

        alias_method :collection, :key_pairs

      end

      subcommand ["key-pair", "kp"], "show key-pair" do

        parameter "NAME", "key-pair NAME"

        include ItemBehaviour

        private

        def key_pair
          Swa::EC2::KeyPair.new(ec2.key_pair(name))
        end

        alias_method :item, :key_pair

      end

      protected

      def ec2
        ::Aws::EC2::Resource.new(aws_config)
      end

    end

  end
end
