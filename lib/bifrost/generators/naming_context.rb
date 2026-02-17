# frozen_string_literal: true

require "active_support/inflector"

module Bifrost
  module Generators
    # Holds normalized naming variants derived from a resource identifier.
    #
    # The context ensures all generator components use the same predictable
    # singular/plural/class/module names.
    #
    # @example
    #   ctx = Bifrost::Generators::NamingContext.new("BlogPosts")
    #   ctx.singular   # => "blog_post"
    #   ctx.plural     # => "blog_posts"
    #   ctx.class_name # => "BlogPost"
    #   ctx.module_name # => "BlogPosts"
    #
    # @api public
    class NamingContext
      # @return [String] Underscored singular resource name (e.g. `user`).
      attr_reader :singular, :plural, :class_name, :module_name

      # @param resource [#to_s] User-provided resource name.
      # @raise [NoMethodError] If ActiveSupport inflection methods are
      #   unavailable for the resulting object.
      def initialize(resource)
        normalized = resource.to_s.strip.underscore.singularize

        @singular = normalized
        @plural = normalized.pluralize
        @class_name = normalized.classify
        @module_name = @plural.classify
      end
    end
  end
end
