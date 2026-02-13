# frozen_string_literal: true

require "bifrost/configuration"
require "bifrost/container"
require "bifrost/errors"
require "bifrost/result"
require "bifrost/version"

# Root namespace for the Bifrost CQRS engine.
module Bifrost
  # Builds a fully wired container from a configuration block.
  #
  # @yieldparam config [Bifrost::Configuration] mutable engine configuration
  # @yieldreturn [void]
  # @return [Bifrost::Container] configured runtime container exposing command and query buses
  def self.build
    config = Configuration.new
    yield(config)
    Container.new(config)
  end
end
