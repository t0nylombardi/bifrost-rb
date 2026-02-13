# frozen_string_literal: true

module Bifrost
  # Resolves handlers for incoming command/query messages by message class.
  class HandlerRegistry
    # @param command_handlers [Hash<Class, #call>] command handler mapping
    # @param query_handlers [Hash<Class, #call>] query handler mapping
    # @return [void]
    def initialize(command_handlers:, query_handlers:)
      @command_handlers = command_handlers
      @query_handlers = query_handlers
    end

    # Returns the registered command handler for a command instance.
    #
    # @param command [Object] command object
    # @return [#call] callable handler for command class
    # @raise [Bifrost::Errors::HandlerNotFound] when no handler exists for `command.class`
    def command_handler_for(command)
      @command_handlers.fetch(command.class) do
        raise Errors::HandlerNotFound, "No command handler registered for #{command.class}"
      end
    end

    # Returns the registered query handler for a query instance.
    #
    # @param query [Object] query object
    # @return [#call] callable handler for query class
    # @raise [Bifrost::Errors::HandlerNotFound] when no handler exists for `query.class`
    def query_handler_for(query)
      @query_handlers.fetch(query.class) do
        raise Errors::HandlerNotFound, "No query handler registered for #{query.class}"
      end
    end
  end
end
