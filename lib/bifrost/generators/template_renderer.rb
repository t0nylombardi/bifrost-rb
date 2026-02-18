# frozen_string_literal: true

require "erb"

module Bifrost
  module Generators
    # Renders starter command/query/handler and domain registration templates
    # for a generated domain.
    #
    # Templates are intentionally minimal and are only written when target files
    # do not already exist, preserving user code by default.
    #
    # @api private
    class TemplateRenderer
      # @param context [Bifrost::Generators::NamingContext] Normalized naming
      #   context used in file names and Ruby constants.
      # @param root [String] Destination project root.
      # @param full [Boolean] When true, also generate update/delete/list files.
      def initialize(context, root:, full:)
        @context = context
        @root = root
        @full = full
      end

      # Renders base templates and optional extended templates.
      #
      # @return [void]
      def call
        base_steps.each { |step| send(step) }
        full_steps.each { |step| send(step) } if @full
      end

      private

      # Defines template generators executed for all invocations.
      #
      # @return [Array<Symbol>]
      def base_steps
        %i[
          generate_create
          generate_get
          generate_register
          generate_handlers
        ]
      end

      # Defines optional template generators executed when `@full` is true.
      #
      # @return [Array<Symbol>]
      def full_steps
        %i[
          generate_update
          generate_delete
          generate_list
        ]
      end

      # Generates all base command/query handler templates.
      #
      # @return [void]
      def generate_handlers
        generate_create_handler
        generate_get_handler
      end

      # Writes file content unless file already exists.
      #
      # @param relative_path [String] Path relative to `@root`.
      # @param content [String] File contents to persist.
      # @return [void]
      def write_file(relative_path, content)
        full_path = File.join(@root, relative_path)
        return if File.exist?(full_path)

        File.write(full_path, content)
      end

      # Generates `Create*` command object skeleton.
      #
      # @return [void]
      def generate_create
        write_file(
          "app/commands/#{@context.plural}/create_#{@context.singular}.rb",
          <<~RUBY
            module Commands
              module #{@context.plural.camelize}
                def self.create_#{@context.singular}(**attrs)
                  Create#{@context.class_name}.new(**attrs)
                end

                class Create#{@context.class_name}
                  def self.call(**attrs)
                    new(**attrs)
                  end

                  def initialize(**attrs)
                    @attrs = attrs
                  end

                  attr_reader :attrs
                end
              end
            end
          RUBY
        )
      end

      # Generates `Get*` query object skeleton.
      #
      # @return [void]
      def generate_get
        write_file(
          "app/queries/#{@context.plural}/get_#{@context.singular}.rb",
          <<~RUBY
            module Queries
              module #{@context.plural.camelize}
                def self.get_#{@context.singular}(id:)
                  Get#{@context.class_name}.new(id: id)
                end

                class Get#{@context.class_name}
                  def self.call(id:)
                    new(id: id)
                  end

                  def initialize(id:)
                    @id = id
                  end

                  attr_reader :id
                end
              end
            end
          RUBY
        )
      end

      # Generates per-domain registration helper that wires commands and
      # queries to their handlers.
      #
      # @return [void]
      def generate_register
        write_file(
          "app/domains/#{@context.plural}/register.rb",
          <<~RUBY
            module Domains
              module #{@context.module_name}
                def self.register(config, repo:)
                  config.register_command(
                    Commands::#{@context.plural.camelize}::Create#{@context.class_name},
                    Handlers::#{@context.plural.camelize}::Create#{@context.class_name}Handler.new(repo: repo)
                  )

                  config.register_query(
                    Queries::#{@context.plural.camelize}::Get#{@context.class_name},
                    Handlers::#{@context.plural.camelize}::Get#{@context.class_name}Handler.new(repo: repo)
                  )
                end
              end
            end
          RUBY
        )
      end

      # Generates `Create*Handler` command handler skeleton.
      #
      # @return [void]
      def generate_create_handler
        write_file(
          "app/handlers/#{@context.plural}/create_#{@context.singular}_handler.rb",
          <<~RUBY
            module Handlers
              module #{@context.plural.camelize}
                class Create#{@context.class_name}Handler
                  def initialize(repo:)
                    @repo = repo
                  end

                  def call(command)
                    @repo.create(command.attrs)
                  end
                end
              end
            end
          RUBY
        )
      end

      # Generates `Get*Handler` query handler skeleton.
      #
      # @return [void]
      def generate_get_handler
        write_file(
          "app/handlers/#{@context.plural}/get_#{@context.singular}_handler.rb",
          <<~RUBY
            module Handlers
              module #{@context.plural.camelize}
                class Get#{@context.class_name}Handler
                  def initialize(repo:)
                    @repo = repo
                  end

                  def call(query)
                    @repo.find(query.id)
                  end
                end
              end
            end
          RUBY
        )
      end

      # Reserved extension point for `Update*` command generation.
      #
      # @return [void]
      def generate_update
      end

      # Reserved extension point for `Delete*` command generation.
      #
      # @return [void]
      def generate_delete
      end

      # Reserved extension point for `List*` query generation.
      #
      # @return [void]
      def generate_list
      end
    end
  end
end
