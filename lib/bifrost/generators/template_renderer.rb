# frozen_string_literal: true

require "erb"

module Bifrost
  module Generators
    # Renders starter command/query classes for a generated domain.
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
        generate_create
        generate_get

        return unless @full

        generate_update
        generate_delete
        generate_list
      end

      private

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
              module #{@context.module_name}
                class Create#{@context.class_name}
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
              module #{@context.module_name}
                class Get#{@context.class_name}
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
