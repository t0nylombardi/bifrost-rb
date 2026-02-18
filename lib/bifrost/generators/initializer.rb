# frozen_string_literal: true

require "fileutils"

module Bifrost
  module Generators
    # Bootstraps Bifrost into a host application.
    #
    # The initializer creates the selected domain root (`app/` or `lib/`),
    # writes `config/bifrost.rb` when missing, and scaffolds a minimal
    # `config.ru` fallback when absent.
    #
    # @api public
    class Initializer
      # @param root [String] Destination project root where config files are written.
      def initialize(root:)
        @root = root
      end

      # Runs initialization flow for Bifrost.
      #
      # @return [void]
      def call
        directory = ask_directory
        create_app_directory(directory)
        create_config_directory
        generate_config_file(directory)
        generate_config_ru
        print_success(directory)
      end

      private

      # Prompts for the domain directory root and normalizes invalid input.
      #
      # @return [String] Either `"app"` or `"lib"`.
      def ask_directory
        puts "Where should Bifrost domains live? (app/lib)"
        input = $stdin.gets.strip

        return input if %w[app lib].include?(input)

        puts "Invalid option. Defaulting to app."
        "app"
      end

      # Ensures selected domain directory exists.
      #
      # @param directory [String] Directory selected by the user (`app` or `lib`).
      # @return [void]
      def create_app_directory(directory)
        FileUtils.mkdir_p(File.join(@root, directory))
      end

      # Ensures `config/` exists for generated boot files.
      #
      # @return [void]
      def create_config_directory
        FileUtils.mkdir_p(File.join(@root, "config"))
      end

      # Writes `config/bifrost.rb` unless it already exists.
      #
      # @param directory [String] Selected domain directory used in loader root.
      # @return [void]
      def generate_config_file(directory)
        path = File.join(@root, "config", "bifrost.rb")
        return if File.exist?(path)

        content = <<~RUBY
          require "bifrost"
          require "zeitwerk"

          module BifrostApp
            ROOT_PATH = File.expand_path("../#{directory}", __dir__)
          end

          loader = Zeitwerk::Loader.new
          loader.push_dir(BifrostApp::ROOT_PATH)
          loader.setup

          CONTAINER = Bifrost.build do |config|
            config.directory_path = BifrostApp::ROOT_PATH
          end
        RUBY

        File.write(path, content)
      end

      # Writes `config.ru` unless it already exists.
      #
      # @return [void]
      def generate_config_ru
        path = File.join(@root, "config.ru")
        return if File.exist?(path)

        content = <<~RUBY
          require_relative "app"
          run Sinatra::Application
        RUBY

        File.write(path, content)
      end

      # Prints post-initialization status to stdout.
      #
      # @param directory [String] Selected domain directory.
      # @return [void]
      def print_success(directory)
        puts "\n✔ Bifrost initialized."
        puts "✔ Domain directory: #{directory}/"
        puts "✔ Config file created: config/bifrost.rb"
      end
    end
  end
end
