# frozen_string_literal: true

require "dry/monads"
require "fileutils"

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
          .bind { |context| generate_config(context) }
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

      # Creates `config/bifrost.rb` when it does not already exist.
      #
      # @param context [Bifrost::Generators::NamingContext]
      # @return [Dry::Monads::Result::Success<Bifrost::Generators::NamingContext>,
      #   Dry::Monads::Result::Failure<Array(Symbol, String)>]
      def generate_config(context)
        generate_config_file
        Success(context)
      rescue => e
        Failure([:filesystem_error, e.message])
      end

      # Writes the gem bootstrap config file if missing.
      #
      # @return [void]
      def generate_config_file
        config_path = File.join(@root, "config", "bifrost.rb")
        return if File.exist?(config_path)

        FileUtils.mkdir_p(File.dirname(config_path))
        File.write(config_path, config_template)
      end

      # Returns the default `config/bifrost.rb` template content.
      #
      # @return [String]
      def config_template
        <<~CFG_TEMPLATE
          require "bifrost"

          # Require domain registration files
          Dir[File.join(__dir__, "../app/domains/**/register.rb")].each do |file|
            require file
          end

          BIFROST_CONTAINER = Bifrost.build do |config|
            # Register domains below
            #
            # Example:
            # repo = Domains::Users::Repository.new
            # Domains::Users.register(config, repo: repo)
          end
        CFG_TEMPLATE
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
