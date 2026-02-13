# frozen_string_literal: true

require "bifrost/middleware/chain"

module Bifrost
  module Bus
    # Dispatches query messages through middleware and their resolved handler.
    class QueryBus
      # @param registry [Bifrost::HandlerRegistry] handler lookup service
      # @param middleware [Array<#call>] ordered middleware for query execution
      # @return [void]
      def initialize(registry:, middleware:)
        @registry = registry
        @middleware = middleware
      end

      # Executes a query and returns the handler result.
      #
      # @param query [Object] query object dispatched to its registered handler
      # @return [Object] value returned by middleware/handler chain
      # @raise [Bifrost::Errors::HandlerNotFound] when no query handler is registered
      def call(query)
        handler = @registry.query_handler_for(query)
        execute_with_middleware(query, handler)
      end

      private

      # Applies middleware chain and invokes handler as terminal step.
      #
      # @param message [Object] query passed through middleware
      # @param handler [#call] query handler callable
      # @return [Object] middleware/handler result
      def execute_with_middleware(message, handler)
        Middleware::Chain.new(@middleware).call(message) do
          handler.call(message)
        end
      end
    end
  end
end
