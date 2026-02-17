# frozen_string_literal: true

module Bifrost
  module Generators
    # Prints post-generation guidance for wiring a new domain.
    #
    # @api private
    class InstructionsPrinter
      # @param context [Bifrost::Generators::NamingContext] Naming values used
      #   to render the generated domain module in output instructions.
      def initialize(context)
        @context = context
      end

      # Outputs next-step instructions to STDOUT.
      #
      # @return [void]
      def call
        puts <<~INS
          ✔ Domain '#{@context.module_name}' created.

          Add this to config/bifrost.rb:
            Domains::#{@context.module_name}.register(config, repo: YourRepo.new)
        INS
      end
    end
  end
end
