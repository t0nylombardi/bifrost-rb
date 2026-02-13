# frozen_string_literal: true

require "bifrost/bus/command_bus"
require "bifrost/bus/query_bus"
require "bifrost/handler_registry"

module Bifrost
  # Runtime dependency container exposing command and query buses.
  class Container
    # @return [Bifrost::Bus::CommandBus] command dispatch bus
    # @return [Bifrost::Bus::QueryBus] query dispatch bus
    attr_reader :commands, :queries

    # Builds a runtime container from finalized configuration.
    #
    # @param config [Bifrost::Configuration] configuration containing handlers and middleware
    # @return [void]
    def initialize(config)
      registry = HandlerRegistry.new(
        command_handlers: config.command_handlers,
        query_handlers: config.query_handlers
      )

      @commands = Bus::CommandBus.new(
        registry: registry,
        middleware: config.command_middleware
      )

      @queries = Bus::QueryBus.new(
        registry: registry,
        middleware: config.query_middleware
      )
    end
  end
end
