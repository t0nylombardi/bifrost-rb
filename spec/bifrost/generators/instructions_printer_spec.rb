# frozen_string_literal: true

require "spec_helper"
require "bifrost/generators/instructions_printer"
require "bifrost/generators/naming_context"

RSpec.describe Bifrost::Generators::InstructionsPrinter do
  describe "#call" do
    it "prints next step registration instructions" do
      context = Bifrost::Generators::NamingContext.new("users")
      printer = described_class.new(context)

      expect { printer.call }
        .to output(include("Domain 'User' created.").and(include("Domains::User.register(config"))).to_stdout
    end
  end
end
