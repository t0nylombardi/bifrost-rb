# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "fileutils"
require "bifrost/generators/template_renderer"
require "bifrost/generators/naming_context"

RSpec.describe Bifrost::Generators::TemplateRenderer do
  describe "#call" do
    it "generates create and get templates" do
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p(File.join(root, "app/commands/users"))
        FileUtils.mkdir_p(File.join(root, "app/queries/users"))
        context = Bifrost::Generators::NamingContext.new("users")

        described_class.new(context, root: root, full: false).call

        create_file = File.join(root, "app/commands/users/create_user.rb")
        get_file = File.join(root, "app/queries/users/get_user.rb")

        expect(File).to exist(create_file)
        expect(File).to exist(get_file)
        expect(File.read(create_file)).to include("class CreateUser")
        expect(File.read(get_file)).to include("class GetUser")
      end
    end

    it "does not overwrite existing files" do
      Dir.mktmpdir do |root|
        create_file = File.join(root, "app/commands/users/create_user.rb")
        get_file = File.join(root, "app/queries/users/get_user.rb")
        FileUtils.mkdir_p(File.dirname(create_file))
        FileUtils.mkdir_p(File.dirname(get_file))
        File.write(create_file, "existing create")
        File.write(get_file, "existing get")
        context = Bifrost::Generators::NamingContext.new("users")

        described_class.new(context, root: root, full: false).call

        expect(File.read(create_file)).to eq("existing create")
        expect(File.read(get_file)).to eq("existing get")
      end
    end

    it "executes full generation path when full flag is true" do
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p(File.join(root, "app/commands/users"))
        FileUtils.mkdir_p(File.join(root, "app/queries/users"))
        context = Bifrost::Generators::NamingContext.new("users")

        expect { described_class.new(context, root: root, full: true).call }.not_to raise_error
      end
    end
  end
end
