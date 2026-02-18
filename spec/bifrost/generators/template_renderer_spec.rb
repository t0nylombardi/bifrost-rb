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
        FileUtils.mkdir_p(File.join(root, "app/handlers/users"))
        FileUtils.mkdir_p(File.join(root, "app/domains/users"))
        context = Bifrost::Generators::NamingContext.new("users")

        described_class.new(context, root: root, full: false).call

        create_file = File.join(root, "app/commands/users/create_user.rb")
        get_file = File.join(root, "app/queries/users/get_user.rb")

        expect(File).to exist(create_file)
        expect(File).to exist(get_file)
        expect(File.read(create_file)).to include("module Users")
        expect(File.read(get_file)).to include("module Users")
        expect(File.read(create_file)).to include("def self.create_user(**attrs)")
        expect(File.read(get_file)).to include("def self.get_user(id:)")
        expect(File.read(create_file)).to include("class CreateUser")
        expect(File.read(get_file)).to include("class GetUser")
      end
    end

    it "builds command and query objects through module APIs" do
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p(File.join(root, "app/commands/users"))
        FileUtils.mkdir_p(File.join(root, "app/queries/users"))
        FileUtils.mkdir_p(File.join(root, "app/handlers/users"))
        FileUtils.mkdir_p(File.join(root, "app/domains/users"))
        context = Bifrost::Generators::NamingContext.new("users")

        described_class.new(context, root: root, full: false).call

        begin
          Object.send(:remove_const, :Commands) if Object.const_defined?(:Commands)
          Object.send(:remove_const, :Queries) if Object.const_defined?(:Queries)

          load File.join(root, "app/commands/users/create_user.rb")
          load File.join(root, "app/queries/users/get_user.rb")

          command = Commands::Users.create_user(name: "Ada")
          query = Queries::Users.get_user(id: 42)

          expect(command).to be_a(Commands::Users::CreateUser)
          expect(command.attrs).to eq({name: "Ada"})
          expect(query).to be_a(Queries::Users::GetUser)
          expect(query.id).to eq(42)
        ensure
          Object.send(:remove_const, :Commands) if Object.const_defined?(:Commands)
          Object.send(:remove_const, :Queries) if Object.const_defined?(:Queries)
        end
      end
    end

    it "generates domain register template" do
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p(File.join(root, "app/commands/users"))
        FileUtils.mkdir_p(File.join(root, "app/queries/users"))
        FileUtils.mkdir_p(File.join(root, "app/handlers/users"))
        FileUtils.mkdir_p(File.join(root, "app/domains/users"))
        context = Bifrost::Generators::NamingContext.new("users")

        described_class.new(context, root: root, full: false).call

        register_file = File.join(root, "app/domains/users/register.rb")

        expect(File).to exist(register_file)
        expect(File.read(register_file)).to include("module Domains")
        expect(File.read(register_file)).to include("def self.register(config, repo:)")
        expect(File.read(register_file)).to include("Commands::Users::CreateUser")
        expect(File.read(register_file)).to include("Queries::Users::GetUser")
      end
    end

    it "generates handler skeletons" do
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p(File.join(root, "app/commands/users"))
        FileUtils.mkdir_p(File.join(root, "app/queries/users"))
        FileUtils.mkdir_p(File.join(root, "app/handlers/users"))
        FileUtils.mkdir_p(File.join(root, "app/domains/users"))
        context = Bifrost::Generators::NamingContext.new("users")

        described_class.new(context, root: root, full: false).call

        create_handler = File.join(root, "app/handlers/users/create_user_handler.rb")
        get_handler = File.join(root, "app/handlers/users/get_user_handler.rb")

        expect(File).to exist(create_handler)
        expect(File).to exist(get_handler)
        expect(File.read(create_handler)).to include("class CreateUserHandler")
        expect(File.read(get_handler)).to include("class GetUserHandler")
      end
    end

    it "does not overwrite existing files" do
      Dir.mktmpdir do |root|
        create_file = File.join(root, "app/commands/users/create_user.rb")
        get_file = File.join(root, "app/queries/users/get_user.rb")
        create_handler = File.join(root, "app/handlers/users/create_user_handler.rb")
        get_handler = File.join(root, "app/handlers/users/get_user_handler.rb")
        register_file = File.join(root, "app/domains/users/register.rb")
        FileUtils.mkdir_p(File.dirname(create_file))
        FileUtils.mkdir_p(File.dirname(get_file))
        FileUtils.mkdir_p(File.dirname(create_handler))
        FileUtils.mkdir_p(File.dirname(get_handler))
        FileUtils.mkdir_p(File.dirname(register_file))
        File.write(create_file, "existing create")
        File.write(get_file, "existing get")
        File.write(create_handler, "existing create handler")
        File.write(get_handler, "existing get handler")
        File.write(register_file, "existing register")
        context = Bifrost::Generators::NamingContext.new("users")

        described_class.new(context, root: root, full: false).call

        expect(File.read(create_file)).to eq("existing create")
        expect(File.read(get_file)).to eq("existing get")
        expect(File.read(create_handler)).to eq("existing create handler")
        expect(File.read(get_handler)).to eq("existing get handler")
        expect(File.read(register_file)).to eq("existing register")
      end
    end

    it "executes full generation path when full flag is true" do
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p(File.join(root, "app/commands/users"))
        FileUtils.mkdir_p(File.join(root, "app/queries/users"))
        FileUtils.mkdir_p(File.join(root, "app/handlers/users"))
        FileUtils.mkdir_p(File.join(root, "app/domains/users"))
        context = Bifrost::Generators::NamingContext.new("users")

        expect { described_class.new(context, root: root, full: true).call }.not_to raise_error
      end
    end
  end
end
