# frozen_string_literal: true

require "thor"

module Bifrost
  # Thor CLI entrypoint for Bifrost generators.
  #
  # @api public
  class CLI < Thor
    desc "init", "Initialize Bifrost in your project"

    # Runs project bootstrap and writes initial Bifrost config files.
    #
    # @return [void]
    def init
      initializer = Generators::Initializer.new(root: Dir.pwd)
      initializer.call
    end

    desc "create RESOURCE", "Generate CQRS domain structure"
    method_option :full, type: :boolean, default: false

    # Generates a domain scaffold for the provided resource.
    #
    # @param resource [String] Resource/domain name.
    # @return [void]
    def create(resource)
      result = Bifrost::Generators::Domain.new(resource, full: options[:full]).call

      unless result.success?
        error, message = result.failure
        puts "✖ #{error}: #{message}"
      end
    end
  end
end
