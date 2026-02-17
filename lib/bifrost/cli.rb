# frozen_string_literal: true

require "thor"

module Bifrost
  class CLI < Thor
    desc "create RESOURCE", "Generate CQRS domain structure"
    method_option :full, type: :boolean, default: false

    def create(resource)
      result = Bifrost::Generators::Domain.new(resource, full: options[:full]).call

      unless result.success?
        error, message = result.failure
        puts "✖ #{error}: #{message}"
      end
    end
  end
end
