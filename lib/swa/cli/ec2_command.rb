require "aws-sdk-resources"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/cli/tag_filter_options"
require "swa/ec2/image"
require "swa/ec2/instance"
require "swa/ec2/key_pair"
require "swa/ec2/security_group"
require "swa/ec2/snapshot"
require "swa/ec2/subnet"
require "swa/ec2/volume"
require "swa/ec2/vpc"

module Swa
  module CLI

    class Ec2Command < BaseCommand

      subcommand ["image", "ami"], "Show image" do

        parameter "IMAGE-ID", "image id"

        include ItemBehaviour

        subcommand ["delete"], "Delete image and snapshots" do
          def execute
            image.delete
          end
        end

        subcommand ["deregister"], "Deregister image" do
          def execute
            image.deregister
          end
        end

        private

        def image
          Swa::EC2::Image.new(ec2.image(image_id))
        end

        alias_method :item, :image

      end

      subcommand ["images", "amis"], "List images" do

        self.description = <<-EOF
          List images (AMIs).

          By default only AMIs owned by the current account are listed;
          use `--owned-by` to select a different scope.
        EOF

        option "--owned-by", "OWNER", "with specified owner", :default => "self"
        option "--named", "PATTERN", "with matching name"

        option ["--created-after", "--after"], "WHEN", "earliest creation-date"
        option ["--created-before", "--before"], "WHEN", "latest creation-date"

        include TagFilterOptions
        include CollectionBehaviour

        private

        def named=(name_pattern)
          add_filter("name", name_pattern)
        end

        def created_after=(datetime_string)
          min_creation_date = parse_datetime(datetime_string).max
          selector.add do |image|
            Time.parse(image.creation_date) > min_creation_date
          end
        end

        def created_before=(datetime_string)
          max_creation_date = parse_datetime(datetime_string).min
          selector.add do |image|
            Time.parse(image.creation_date) < max_creation_date
          end
        end

        def images
          query_options[:owners] = [owned_by]
          query_for(:images, Swa::EC2::Image)
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

        self.description = <<-EOF
          List images (AMIs).

          By default only runnning instances are listed;
          use `--state` to override ('*' for all states).
        EOF

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

        option ["--launched-after", "--after"], "WHEN", "earliest launch-time"
        option ["--launched-before", "--before"], "WHEN", "latest launch-time"

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

        def launched_after=(datetime_string)
          min_launch_time = parse_datetime(datetime_string).max
          selector.add do |instance|
            instance.launch_time > min_launch_time
          end
        end

        def launched_before=(datetime_string)
          max_launch_time = parse_datetime(datetime_string).min
          selector.add do |instance|
            instance.launch_time < max_launch_time
          end
        end

        private

        def instances
          add_filter("instance-state-name", state)
          query_for(:instances, Swa::EC2::Instance)
        end

        alias_method :collection, :instances

      end

      subcommand ["key-pair", "kp"], "Show key-pair" do

        parameter "NAME", "key-pair name"

        include ItemBehaviour

        subcommand "delete", "Delete the key-pair" do
          def execute
            key_pair.delete
          end
        end

        private

        def key_pair
          Swa::EC2::KeyPair.new(ec2.key_pair(name))
        end

        alias_method :item, :key_pair

      end

      subcommand ["key-pairs", "kps"], "List key-pairs" do

        self.description = <<-EOF
          List key-pairs.
        EOF

        include CollectionBehaviour

        private

        def key_pairs
          query_for(:key_pairs, Swa::EC2::KeyPair)
        end

        alias_method :collection, :key_pairs

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
          query_for(:security_groups, Swa::EC2::SecurityGroup)
        end

        alias_method :collection, :security_groups

      end

      subcommand ["snapshot", "snap"], "Show snapshot" do

        parameter "SNAPSHOT-ID", "snapshot id"

        include ItemBehaviour

        subcommand ["delete"], "Delete the snapshot" do
          def execute
            snapshot.delete
          end
        end

        private

        def snapshot
          Swa::EC2::Snapshot.new(ec2.snapshot(snapshot_id))
        end

        alias_method :item, :snapshot

      end

      subcommand ["snapshots", "snaps"], "List snapshots" do

        self.description = <<-EOF
          List EBS snapshots.

          By default only snapshots owned by the current account are listed;
          use `--owned-by` to select a different scope.
        EOF

        option "--owned-by", "OWNER", "with specified owner", :default => "self"

        include TagFilterOptions
        include CollectionBehaviour

        private

        def snapshots
          query_options[:owner_ids] = [owned_by]
          query_for(:snapshots, Swa::EC2::Snapshot)
        end

        alias_method :collection, :snapshots

      end

      subcommand ["subnet"], "Show subnet" do

        parameter "SUBNET-ID", "subnet id"

        include ItemBehaviour

        private

        def subnet
          Swa::EC2::Subnet.new(ec2.subnet(subnet_id))
        end

        alias_method :item, :subnet

      end

      subcommand ["subnets"], "List subnets" do

        include TagFilterOptions
        include CollectionBehaviour

        private

        def subnets
          query_for(:subnets, Swa::EC2::Subnet)
        end

        alias_method :collection, :subnets

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

        self.description = <<-EOF
          List EBS volumes.
        EOF

        include TagFilterOptions
        include CollectionBehaviour

        private

        def volumes
          query_for(:volumes, Swa::EC2::Volume)
        end

        alias_method :collection, :volumes

      end

      subcommand ["vpc"], "Show vpc" do

        parameter "VPC-ID", "vpc id"

        include ItemBehaviour

        private

        def vpc
          Swa::EC2::Vpc.new(ec2.vpc(vpc_id))
        end

        alias_method :item, :vpc

      end

      subcommand ["vpcs"], "List vpcs" do

        include TagFilterOptions
        include CollectionBehaviour

        option "--named", "NAME", "with matching name" do |name|
          add_tag_filter("Name", name)
        end

        private

        def vpcs
          query_for(:vpcs, Swa::EC2::Vpc)
        end

        alias_method :collection, :vpcs

      end

      protected

      def ec2
        ::Aws::EC2::Resource.new(aws_config)
      end

      def query_for(query_method, resource_model)
        aws_resources = ec2.public_send(query_method, query_options)
        wrapped_resources = resource_model.list(aws_resources)
        selector.apply(wrapped_resources)
      end

    end

  end
end
