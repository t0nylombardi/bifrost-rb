# frozen_string_literal: true

module Bifrost
  # Collects all runtime wiring required to build a {Bifrost::Container}.
  #
  # The configuration object is intentionally mutable during boot and treated
  # as immutable once passed to the container.
  class Configuration
    # @return [Hash<Class, #call>] mapping command classes to callable handlers
    # @return [Hash<Class, #call>] mapping query classes to callable handlers
    # @return [Array<#call>] middleware stack for command dispatch
    # @return [Array<#call>] middleware stack for query dispatch
    attr_reader :command_handlers, :query_handlers, :command_middleware, :query_middleware

    # Initializes empty handler registries and middleware stacks.
    #
    # @return [void]
    def initialize
      @command_handlers = {}
      @query_handlers = {}
      @command_middleware = []
      @query_middleware = []
    end

    # Registers a command handler for a specific command type.
    #
    # @param command_class [Class] command class used as registry key
    # @param handler [#call] callable receiving an instance of `command_class`
    # @return [#call] the registered handler
    def register_command(command_class, handler)
      @command_handlers[command_class] = handler
    end

    # Registers a query handler for a specific query type.
    #
    # @param query_class [Class] query class used as registry key
    # @param handler [#call] callable receiving an instance of `query_class`
    # @return [#call] the registered handler
    def register_query(query_class, handler)
      @query_handlers[query_class] = handler
    end

    # Appends a middleware component to the command middleware chain.
    #
    # @param middleware [#call] callable with signature `call(message, next_step)`
    # @return [Array<#call>] updated middleware stack
    def use_command_middleware(middleware)
      @command_middleware << middleware
    end

    # Appends a middleware component to the query middleware chain.
    #
    # @param middleware [#call] callable with signature `call(message, next_step)`
    # @return [Array<#call>] updated middleware stack
    def use_query_middleware(middleware)
      @query_middleware << middleware
    end
  end
end
