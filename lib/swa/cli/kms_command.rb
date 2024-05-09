require "aws-sdk-kms"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/kms/alias"
require "swa/kms/key"

module Swa
  module CLI

    class KmsCommand < BaseCommand

      subcommand ["aliases"], "Show aliases" do

        include CollectionBehaviour

        private

        def collection
          query_for(:list_aliases, :aliases, Swa::KMS::Alias)
        end

      end

      subcommand ["key"], "Show key" do

        parameter "ID", "key ID"

        include ItemBehaviour

        private

        def item
          Swa::KMS::Key.new(kms_client.describe_key(:key_id => id).key_metadata)
        end

      end

      subcommand ["keys"], "Show keys" do

        include CollectionBehaviour

        private

        def collection
          query_for(:list_keys, :keys, Swa::KMS::Key)
        end

      end

      protected

      def kms_client
        ::Aws::KMS::Client.new(aws_config)
      end

      def query_for(query_method, response_key, model, **query_args)
        model.list_from_query(kms_client, query_method, response_key, **query_args)
      end

    end

  end
end
