# frozen_string_literal: true

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "cli" => "CLI"
)

loader.setup

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
