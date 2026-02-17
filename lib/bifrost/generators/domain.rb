# frozen_string_literal: true

require "dry/monads"

module Bifrost
  module Generators
    # Orchestrates scaffolding of a Bifrost domain in a host application.
    #
    # This object is intentionally small and result-driven. Each pipeline step
    # returns a {Dry::Monads::Result} and the first failure short-circuits the
    # generation flow.
    #
    # @example Generate only create/get skeletons
    #   Bifrost::Generators::Domain.new("users").call
    #
    # @example Generate full CRUD/list skeletons
    #   Bifrost::Generators::Domain.new("users", full: true).call
    #
    # @api public
    class Domain
      include Dry::Monads[:result]

      # @param resource [#to_s] Domain/resource name provided by the caller.
      # @param full [Boolean] When true, render extended templates
      #   (update/delete/list) in addition to create/get.
      # @param root [String] Project root where `app/` is expected.
      def initialize(resource, full: false, root: Dir.pwd)
        @resource = resource
        @full = full
        @root = root
      end

      # Runs the domain generation pipeline.
      #
      # @return [Dry::Monads::Result::Success<Bifrost::Generators::NamingContext>,
      #   Dry::Monads::Result::Failure<Array(Symbol, String)>]
      #   Returns `Success(context)` when generation finishes, otherwise
      #   `Failure([code, message])` with one of:
      #   - `:invalid_resource`
      #   - `:invalid_root`
      #   - `:filesystem_error`
      #   - `:template_error`
      def call
        normalize
          .bind { |context| validate_root(context) }
          .bind { |context| build_directories(context) }
          .bind { |context| render_templates(context) }
          .bind { |context| print_instructions(context) }
      end

      private

      # Builds a normalized naming context from the user input.
      #
      # @return [Dry::Monads::Result::Success<Bifrost::Generators::NamingContext>,
      #   Dry::Monads::Result::Failure<Array(Symbol, String)>]
      def normalize
        Success(NamingContext.new(@resource))
      rescue => e
        Failure([:invalid_resource, e.message])
      end

      # Ensures the destination root looks like an app project.
      #
      # @param context [Bifrost::Generators::NamingContext]
      # @return [Dry::Monads::Result::Success<Bifrost::Generators::NamingContext>,
      #   Dry::Monads::Result::Failure<Array(Symbol, String)>]
      def validate_root(context)
        return Failure([:invalid_root, "No app directory found"]) unless File.directory?(File.join(@root, "app"))
        Success(context)
      end

      # Creates required domain directories.
      #
      # @param context [Bifrost::Generators::NamingContext]
      # @return [Dry::Monads::Result::Success<Bifrost::Generators::NamingContext>,
      #   Dry::Monads::Result::Failure<Array(Symbol, String)>]
      def build_directories(context)
        DirectoryBuilder.new(context, root: @root).call
        Success(context)
      rescue => e
        Failure([:filesystem_error, e.message])
      end

      # Renders starter command/query templates.
      #
      # @param context [Bifrost::Generators::NamingContext]
      # @return [Dry::Monads::Result::Success<Bifrost::Generators::NamingContext>,
      #   Dry::Monads::Result::Failure<Array(Symbol, String)>]
      def render_templates(context)
        TemplateRenderer.new(context, root: @root, full: @full).call
        Success(context)
      rescue => e
        Failure([:template_error, e.message])
      end

      # Prints next-step instructions for the generated domain.
      #
      # @param context [Bifrost::Generators::NamingContext]
      # @return [Dry::Monads::Result::Success<Bifrost::Generators::NamingContext>]
      def print_instructions(context)
        InstructionsPrinter.new(context).call
        Success(context)
      end
    end
  end
end
