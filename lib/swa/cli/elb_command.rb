require "aws-sdk-elasticloadbalancing"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/elb/load_balancer"

module Swa
  module CLI

    class ElbCommand < BaseCommand

      subcommand ["load-balancer", "lb"], "Show load-balancer" do

        parameter "NAME", "ELB name"

        include ItemBehaviour

        private

        def item
          results = describe_load_balancers(:load_balancer_names => [name])
          signal_error "No such ELB '#{name}'" unless results.any?
          Swa::ELB::LoadBalancer.new(results.first)
        end

      end

      subcommand ["load-balancers", "lbs"], "Show load-balancers" do

        include CollectionBehaviour

        private

        def collection
          Swa::ELB::LoadBalancer.list(describe_load_balancers)
        end

      end

      protected

      def elb_client
        ::Aws::ElasticLoadBalancing::Client.new(aws_config)
      end

      def describe_load_balancers(options = {})
        elb_client.describe_load_balancers(options).load_balancer_descriptions
      end

    end

  end
end
