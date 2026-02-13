# frozen_string_literal: true

require "bifrost/middleware/chain"

module Bifrost
  module Bus
    # Dispatches command messages through middleware and their resolved handler.
    class CommandBus
      # @param registry [Bifrost::HandlerRegistry] handler lookup service
      # @param middleware [Array<#call>] ordered middleware for command execution
      # @return [void]
      def initialize(registry:, middleware:)
        @registry = registry
        @middleware = middleware
      end

      # Executes a command and returns the handler result.
      #
      # @param command [Object] command object dispatched to its registered handler
      # @return [Object] value returned by middleware/handler chain
      # @raise [Bifrost::Errors::HandlerNotFound] when no command handler is registered
      def call(command)
        handler = @registry.command_handler_for(command)
        execute_with_middleware(command, handler)
      end

      private

      # Applies middleware chain and invokes handler as terminal step.
      #
      # @param message [Object] command passed through middleware
      # @param handler [#call] command handler callable
      # @return [Object] middleware/handler result
      def execute_with_middleware(message, handler)
        Middleware::Chain.new(@middleware).call(message) do
          handler.call(message)
        end
      end
    end
  end
end
