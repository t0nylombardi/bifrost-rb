# frozen_string_literal: true

module Bifrost
  # Namespace for Bifrost-specific error types.
  module Errors
    # Raised when no handler is registered for an incoming command or query.
    class HandlerNotFound < StandardError; end
  end
end
