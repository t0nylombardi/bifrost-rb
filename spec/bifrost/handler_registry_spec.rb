# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bifrost::HandlerRegistry do
  let(:command_class) { Class.new }
  let(:query_class) { Class.new }
  let(:command_handler) { ->(_command) { :command_ok } }
  let(:query_handler) { ->(_query) { :query_ok } }
  let(:registry) do
    described_class.new(
      command_handlers: {command_class => command_handler},
      query_handlers: {query_class => query_handler}
    )
  end

  describe "#command_handler_for" do
    it "returns the registered command handler" do
      command = command_class.new

      expect(registry.command_handler_for(command)).to eq(command_handler)
    end

    it "raises handler not found when command class is not registered" do
      command = Class.new.new

      expect { registry.command_handler_for(command) }
        .to raise_error(Bifrost::Errors::HandlerNotFound, /No command handler registered/)
    end
  end

  describe "#query_handler_for" do
    it "returns the registered query handler" do
      query = query_class.new

      expect(registry.query_handler_for(query)).to eq(query_handler)
    end

    it "raises handler not found when query class is not registered" do
      query = Class.new.new

      expect { registry.query_handler_for(query) }
        .to raise_error(Bifrost::Errors::HandlerNotFound, /No query handler registered/)
    end
  end
end
