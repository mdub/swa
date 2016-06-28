require "aws-sdk-resources"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/cli/tag_filter_options"
require "swa/ec2/key_pair"
require "swa/ec2/image"
require "swa/ec2/instance"
require "swa/ec2/security_group"
require "swa/ec2/snapshot"
require "swa/ec2/volume"

module Swa
  module CLI

    class Ec2Command < BaseCommand

      subcommand ["key-pair", "kp"], "Show key-pair" do

        parameter "NAME", "key-pair name"

        include ItemBehaviour

        private

        def key_pair
          Swa::EC2::KeyPair.new(ec2.key_pair(name))
        end

        alias_method :item, :key_pair

      end

      subcommand ["key-pairs", "kps"], "List key-pairs" do

        include CollectionBehaviour

        private

        def key_pairs
          Swa::EC2::KeyPair.list(ec2.key_pairs)
        end

        alias_method :collection, :key_pairs

      end

      subcommand ["image", "ami"], "Show image" do

        parameter "IMAGE-ID", "image id"

        include ItemBehaviour

        private

        def image
          Swa::EC2::Image.new(ec2.image(image_id))
        end

        alias_method :item, :image

      end

      subcommand ["images", "amis"], "List images" do

        option "--owned-by", "OWNER", "with specified owner", :default => "self"
        option "--named", "PATTERN", "with matching name"

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

      subcommand ["instance", "i"], "Show instance" do

        parameter "INSTANCE-ID", "instance id"

        include ItemBehaviour

        subcommand ["console-output", "console"], "Display console output" do

          def execute
            puts instance.console_output
          end

        end

        %w(stop start reboot terminate).each do |action|
          class_eval <<-RUBY
            subcommand "#{action}", "#{action.capitalize} the instance" do
              def execute
                instance.#{action}
              end
            end
          RUBY
        end

        private

        def instance
          Swa::EC2::Instance.new(ec2.instance(instance_id))
        end

        alias_method :item, :instance

      end

      subcommand ["instances", "is"], "List instances" do

        option ["--state"], "STATE", "with specified status",
               :default => "running"

        option "--named", "NAME", "with matching name" do |name|
          add_tag_filter("Name", name)
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

        %w(stop start reboot terminate).each do |action|
          class_eval <<-RUBY
            subcommand "#{action}", "#{action.capitalize} all instances" do
              def execute
                instances.each do |i|
                  i.#{action}
                end
              end
            end
          RUBY
        end

        private

        def instances
          add_filter("instance-state-name", state)
          options = {:filters => filters}
          Swa::EC2::Instance.list(ec2.instances(options))
        end

        alias_method :collection, :instances

      end

      subcommand ["security-group", "sg"], "Show security-group" do

        parameter "GROUP-ID", "security-group id"

        include ItemBehaviour

        private

        def security_group
          Swa::EC2::SecurityGroup.new(ec2.security_group(group_id))
        end

        alias_method :item, :security_group

      end

      subcommand ["security-groups", "sgs"], "List security-groups" do

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

      subcommand ["snapshot", "snap"], "Show snapshot" do

        parameter "SNAPSHOT-ID", "snapshot id"

        include ItemBehaviour

        private

        def snapshot
          Swa::EC2::Snapshot.new(ec2.snapshot(snapshot_id))
        end

        alias_method :item, :snapshot

      end

      subcommand ["snapshots", "snaps"], "List snapshots" do

        option "--owned-by", "OWNER", "with specified owner", :default => "self"

        include TagFilterOptions
        include CollectionBehaviour

        private

        def snapshots
          options = {
            :owner_ids => [owned_by]
          }
          options[:filters] = filters unless filters.empty?
          Swa::EC2::Snapshot.list(ec2.snapshots(options))
        end

        alias_method :collection, :snapshots

      end

      subcommand ["volume", "vol"], "Show volume" do

        parameter "VOLUME-ID", "volume id"

        include ItemBehaviour

        private

        def volume
          Swa::EC2::Volume.new(ec2.volume(volume_id))
        end

        alias_method :item, :volume

      end

      subcommand ["volumes", "vols"], "List volumes" do

        include TagFilterOptions
        include CollectionBehaviour

        private

        def volumes
          options = {}
          options[:filters] = filters unless filters.empty?
          Swa::EC2::Volume.list(ec2.volumes(options))
        end

        alias_method :collection, :volumes

      end

      protected

      def ec2
        ::Aws::EC2::Resource.new(aws_config)
      end

    end

  end
end
