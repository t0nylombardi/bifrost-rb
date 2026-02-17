# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "fileutils"
require "bifrost/generators/naming_context"
require "bifrost/generators/directory_builder"
require "bifrost/generators/template_renderer"
require "bifrost/generators/instructions_printer"
require "bifrost/generators/domain"

RSpec.describe Bifrost::Generators::Domain do
  describe "#call" do
    it "returns success and generates files/directories for a valid root" do
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p(File.join(root, "app"))

        result = nil
        expect { result = described_class.new("users", root: root).call }.to output(/Domain 'User' created/).to_stdout

        expect(result).to be_success
        expect(File).to be_directory(File.join(root, "app/domains/users"))
        expect(File).to exist(File.join(root, "app/commands/users/create_user.rb"))
        expect(File).to exist(File.join(root, "app/queries/users/get_user.rb"))
      end
    end

    it "returns invalid_root failure when app directory is missing" do
      Dir.mktmpdir do |root|
        result = described_class.new("users", root: root).call

        expect(result).to be_failure
        expect(result.failure).to eq([:invalid_root, "No app directory found"])
      end
    end

    it "returns invalid_resource failure when resource normalization fails" do
      bad_resource = Object.new
      allow(bad_resource).to receive(:to_s).and_raise(ArgumentError, "boom")

      result = described_class.new(bad_resource).call

      expect(result).to be_failure
      expect(result.failure).to eq([:invalid_resource, "boom"])
    end

    it "returns filesystem_error failure when directory creation raises" do
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p(File.join(root, "app"))
        context = Bifrost::Generators::NamingContext.new("users")
        builder = instance_double(Bifrost::Generators::DirectoryBuilder)

        allow(Bifrost::Generators::NamingContext).to receive(:new).with("users").and_return(context)
        allow(Bifrost::Generators::DirectoryBuilder).to receive(:new).with(context, root: root).and_return(builder)
        allow(builder).to receive(:call).and_raise(Errno::EACCES, "Permission denied")

        result = described_class.new("users", root: root).call

        expect(result).to be_failure
        expect(result.failure.first).to eq(:filesystem_error)
      end
    end

    it "returns template_error failure when template rendering raises" do
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p(File.join(root, "app"))
        context = Bifrost::Generators::NamingContext.new("users")
        renderer = instance_double(Bifrost::Generators::TemplateRenderer)

        allow(Bifrost::Generators::NamingContext).to receive(:new).with("users").and_return(context)
        allow(Bifrost::Generators::TemplateRenderer)
          .to receive(:new).with(context, root: root, full: false).and_return(renderer)
        allow(renderer).to receive(:call).and_raise(StandardError, "template boom")

        result = described_class.new("users", root: root).call

        expect(result).to be_failure
        expect(result.failure).to eq([:template_error, "template boom"])
      end
    end
  end
end
