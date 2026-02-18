# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "fileutils"
require "bifrost/generators/initializer"

RSpec.describe Bifrost::Generators::Initializer do
  describe "#call" do
    it "creates app, config/bifrost.rb, and config.ru when app is selected" do
      Dir.mktmpdir do |root|
        allow($stdin).to receive(:gets).and_return("app\n")

        described_class.new(root: root).call

        bifrost_config_path = File.join(root, "config", "bifrost.rb")
        rackup_path = File.join(root, "config.ru")

        expect(File).to be_directory(File.join(root, "app"))
        expect(File).to exist(bifrost_config_path)
        expect(File).to exist(rackup_path)
        expect(File.read(bifrost_config_path)).to include('ROOT_PATH = File.expand_path("../app", __dir__)')
      end
    end

    it "creates lib directory when lib is selected" do
      Dir.mktmpdir do |root|
        allow($stdin).to receive(:gets).and_return("lib\n")

        described_class.new(root: root).call

        expect(File).to be_directory(File.join(root, "lib"))
        expect(File.read(File.join(root, "config", "bifrost.rb"))).to include('ROOT_PATH = File.expand_path("../lib", __dir__)')
      end
    end

    it "defaults to app for invalid input" do
      Dir.mktmpdir do |root|
        allow($stdin).to receive(:gets).and_return("invalid\n")

        described_class.new(root: root).call

        expect(File).to be_directory(File.join(root, "app"))
      end
    end

    it "does not overwrite existing config files" do
      Dir.mktmpdir do |root|
        allow($stdin).to receive(:gets).and_return("app\n")
        bifrost_config_path = File.join(root, "config", "bifrost.rb")
        rackup_path = File.join(root, "config.ru")
        FileUtils.mkdir_p(File.dirname(bifrost_config_path))
        File.write(bifrost_config_path, "existing bifrost config")
        File.write(rackup_path, "existing rackup")

        described_class.new(root: root).call

        expect(File.read(bifrost_config_path)).to eq("existing bifrost config")
        expect(File.read(rackup_path)).to eq("existing rackup")
      end
    end
  end
end
