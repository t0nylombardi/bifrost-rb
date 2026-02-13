# frozen_string_literal: true

module Bifrost
  module Middleware
    # Composes middleware into a single executable callable.
    class Chain
      # @param middleware [Array<#call>] ordered middleware components
      # @return [void]
      def initialize(middleware)
        @middleware = middleware
      end

      # Runs middleware around the provided terminal block.
      #
      # @param message [Object] message object passed to each middleware
      # @yield final handler to execute after all middleware
      # @yieldreturn [Object] terminal return value
      # @return [Object] value returned by middleware chain
      def call(message, &final)
        stack = @middleware.reverse.inject(final) do |next_step, middleware|
          proc { middleware.call(message, next_step) }
        end

        stack.call
      end
    end
  end
end
