# frozen_string_literal: true

require "spec_helper"
require "bifrost/cli"
require "bifrost/generators/domain"

RSpec.describe Bifrost::CLI do
  describe "#create" do
    it "builds a domain generator with full option and executes it" do
      cli = described_class.new
      result = instance_double("Result", success?: true)
      generator = instance_double(Bifrost::Generators::Domain, call: result)

      allow(cli).to receive(:options).and_return({full: true})
      expect(Bifrost::Generators::Domain).to receive(:new).with("users", full: true).and_return(generator)
      expect(generator).to receive(:call)

      cli.create("users")
    end

    it "prints a formatted failure message when generation fails" do
      cli = described_class.new
      result = instance_double("Result", success?: false, failure: [:invalid_resource, "Name is required"])
      generator = instance_double(Bifrost::Generators::Domain, call: result)

      allow(cli).to receive(:options).and_return({full: false})
      allow(Bifrost::Generators::Domain).to receive(:new).with("users", full: false).and_return(generator)
      expect(cli).to receive(:puts).with("✖ invalid_resource: Name is required")

      cli.create("users")
    end
  end
end
