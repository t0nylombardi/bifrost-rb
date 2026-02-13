# frozen_string_literal: true

require "dry/monads"

module Bifrost
  # Result object namespace used by handlers to communicate success/failure.
  module Result
    extend Dry::Monads[:result]

    # Represents a successful result.
    class Success
      # @return [Object] wrapped successful value
      attr_reader :value

      # @param value [Object] successful payload
      # @return [void]
      def initialize(value)
        @value = value
      end

      # @param [Object] value successful payload
      # @return [Success] success result object
      def self.success(value)
        Success(value)
      end

      # @return [true]
      def success? = true

      # @return [false]
      def failure? = false
    end

    # Represents a failed result.
    class Failure
      # @return [Object] domain/application error object
      # @return [Hash] structured metadata associated with the failure
      attr_reader :error, :meta

      # @param error [Object] failure reason or error object
      # @param meta [Hash] additional structured failure context
      # @return [void]
      def initialize(error, meta = {})
        @error = error
        @meta = meta
      end

      # @param [Object] error failure reason or error object
      # @param [Hash] meta additional structured failure context
      # @return [Failure] failure result object
      def self.failure(error, meta = {})
        Failure([error, meta])
      end

      # @return [false]
      def success? = false

      # @return [true]
      def failure? = true
    end
  end
end
