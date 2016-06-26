require "swa/data_presentation"

module Swa

  class Resource

    def initialize(aws_resource)
      @aws_resource = aws_resource
    end

    attr_reader :aws_resource
    alias_method :_resource_, :aws_resource

    include DataPresentation

    def data
      camelize_keys(_resource_.data.to_h)
    end

  end

end
