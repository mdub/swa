require "forwardable"
require "swa/data_presentation"

module Swa

  class Record

    def self.list(records)
      records.lazy.map(&method(:new))
    end

    def initialize(aws_record)
      @aws_record = aws_record
    end

    include DataPresentation

    def data
      camelize_keys(aws_record.to_h)
    end

    private

    attr_reader :aws_record

  end

end
