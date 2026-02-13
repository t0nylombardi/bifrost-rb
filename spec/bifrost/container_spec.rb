# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bifrost::Container do
  let(:configuration) { Bifrost::Configuration.new }

  describe "#initialize" do
    it "builds command and query buses with isolated middleware stacks" do
      command_class = Class.new
      query_class = Class.new
      command_message = command_class.new
      query_message = query_class.new
      call_log = []

      configuration.register_command(command_class, lambda do |_command|
        call_log << :command_handler
        :command_ok
      end)
      configuration.register_query(query_class, lambda do |_query|
        call_log << :query_handler
        :query_ok
      end)

      configuration.use_command_middleware(lambda do |_message, next_step|
        call_log << :command_middleware
        next_step.call
      end)
      configuration.use_query_middleware(lambda do |_message, next_step|
        call_log << :query_middleware
        next_step.call
      end)

      container = described_class.new(configuration)

      expect(container.commands).to be_a(Bifrost::Bus::CommandBus)
      expect(container.queries).to be_a(Bifrost::Bus::QueryBus)
      expect(container.commands.call(command_message)).to eq(:command_ok)
      expect(container.queries.call(query_message)).to eq(:query_ok)
      expect(call_log).to eq([:command_middleware, :command_handler, :query_middleware, :query_handler])
    end
  end
end
