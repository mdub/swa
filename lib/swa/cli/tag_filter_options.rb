# frozen_string_literal: true

require "swa/cli/filter_options"

module Swa

  module CLI

    module TagFilterOptions

      extend Clamp::Option::Declaration

      include FilterOptions

      option "--tagged", "KEY[=VALUE]", "with matching tag",
             multivalued: true, attribute_name: :tag_list
      option "--not-tagged", "KEY[=VALUE]", "WITHOUT matching tag",
             multivalued: true, attribute_name: :tag_blacklist

      option "--stack", "NAME", "from the named CloudFormation stack"

      protected

      def append_to_tag_list(arg)
        key, value_pattern = arg.split("=", 2)
        add_tag_filter(key, value_pattern)
      end

      def append_to_tag_blacklist(arg)
        key, value_pattern = arg.split("=", 2)
        if value_pattern
          selector.add do |resource|
            value = resource.tags[key]
            value.nil? || !File.fnmatch(value_pattern, value)
          end
        else
          selector.add do |resource|
            resource.tags[key].nil?
          end
        end
      end

      def stack=(name)
        add_tag_filter("aws:cloudformation:stack-name", name)
      end

      private

      def add_tag_filter(key, value_pattern = nil)
        if value_pattern
          add_filter("tag:#{key}", value_pattern)
        else
          add_filter("tag-key", key)
        end
      end

    end

  end

end
