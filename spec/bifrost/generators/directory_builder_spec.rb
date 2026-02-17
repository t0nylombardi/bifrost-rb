# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "bifrost/generators/directory_builder"
require "bifrost/generators/naming_context"

RSpec.describe Bifrost::Generators::DirectoryBuilder do
  describe "#call" do
    it "creates all expected CQRS directories for the domain" do
      Dir.mktmpdir do |root|
        context = Bifrost::Generators::NamingContext.new("users")

        described_class.new(context, root: root).call

        expect(File).to be_directory(File.join(root, "app/domains/users"))
        expect(File).to be_directory(File.join(root, "app/commands/users"))
        expect(File).to be_directory(File.join(root, "app/queries/users"))
        expect(File).to be_directory(File.join(root, "app/handlers/users"))
      end
    end
  end
end
