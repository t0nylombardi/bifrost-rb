# frozen_string_literal: true

require "fileutils"

module Bifrost
  module Generators
    # Creates directory structure required by a generated domain.
    #
    # @api private
    class DirectoryBuilder
      # @param context [Bifrost::Generators::NamingContext] Normalized naming
      #   values used for directory paths.
      # @param root [String] Destination project root.
      def initialize(context, root:)
        @context = context
        @root = root
      end

      # Creates each required folder using `FileUtils.mkdir_p`.
      #
      # Existing directories are left intact.
      #
      # @return [void]
      def call
        directories.each do |dir|
          path = File.join(@root, dir)
          FileUtils.mkdir_p(path)
        end
      end

      private

      # @return [Array<String>] Relative directories for a single domain.
      def directories
        [
          "app/domains/#{@context.plural}",
          "app/commands/#{@context.plural}",
          "app/queries/#{@context.plural}",
          "app/handlers/#{@context.plural}"
        ]
      end
    end
  end
end
