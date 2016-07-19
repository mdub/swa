require "aws-sdk-resources"
require "swa/cli/base_command"
require "swa/cli/collection_behaviour"
require "swa/cli/item_behaviour"
require "swa/kms/key"

module Swa
  module CLI

    class KmsCommand < BaseCommand

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

      def query_for(query_method, response_key, model)
        records = kms_client.public_send(query_method).public_send(response_key)
        model.list(records)
      end

    end

  end
end
