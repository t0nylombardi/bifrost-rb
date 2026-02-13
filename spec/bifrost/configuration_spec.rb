# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bifrost::Configuration do
  let(:configuration) { described_class.new }

  describe "#initialize" do
    it "starts with empty registries and middleware stacks" do
      expect(configuration.command_handlers).to eq({})
      expect(configuration.query_handlers).to eq({})
      expect(configuration.command_middleware).to eq([])
      expect(configuration.query_middleware).to eq([])
    end
  end

  describe "#register_command" do
    it "stores the handler by command class and returns the handler" do
      command_class = Class.new
      handler = ->(_command) { :ok }

      result = configuration.register_command(command_class, handler)

      expect(result).to eq(handler)
      expect(configuration.command_handlers).to eq({command_class => handler})
    end
  end

  describe "#register_query" do
    it "stores the handler by query class and returns the handler" do
      query_class = Class.new
      handler = ->(_query) { :ok }

      result = configuration.register_query(query_class, handler)

      expect(result).to eq(handler)
      expect(configuration.query_handlers).to eq({query_class => handler})
    end
  end

  describe "#use_command_middleware" do
    it "appends middleware and returns the updated stack" do
      middleware = ->(_message, next_step) { next_step.call }

      result = configuration.use_command_middleware(middleware)

      expect(result).to eq([middleware])
      expect(configuration.command_middleware).to eq([middleware])
    end
  end

  describe "#use_query_middleware" do
    it "appends middleware and returns the updated stack" do
      middleware = ->(_message, next_step) { next_step.call }

      result = configuration.use_query_middleware(middleware)

      expect(result).to eq([middleware])
      expect(configuration.query_middleware).to eq([middleware])
    end
  end
end
