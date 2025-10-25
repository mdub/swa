require "forwardable"
require "swa/data_presentation"

module Swa

  class Record

    def self.list(records)
      records.lazy.map(&method(:new))
    end

    def self.list_from_query(client, query_method, response_key, **query_args)
      records = client.public_send(query_method, **query_args).each.lazy.flat_map do |page|
        response_key ? page.public_send(response_key) : page
      end
      list(records)
    end

    def initialize(aws_record)
      @aws_record = aws_record
    end

    include DataPresentation

    def data
      stringify_keys(aws_record.to_h)
    end

    extend Forwardable

    def self.delegate(*methods)
      def_delegators :aws_record, *methods
    end

    private

    attr_reader :aws_record

  end

end
