# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bifrost::Bus::CommandBus do
  let(:command) { Struct.new(:id).new(1) }
  let(:handler) { ->(message) { [:handled, message.id] } }
  let(:registry) { instance_double(Bifrost::HandlerRegistry) }

  describe "#call" do
    it "dispatches command through middleware and handler" do
      execution = []
      middleware = [
        lambda do |message, next_step|
          execution << [:m1_before, message.id]
          value = next_step.call
          execution << [:m1_after, value]
          value
        end,
        lambda do |message, next_step|
          execution << [:m2_before, message.id]
          value = next_step.call
          execution << [:m2_after, value]
          value
        end
      ]
      bus = described_class.new(registry: registry, middleware: middleware)

      allow(registry).to receive(:command_handler_for).with(command).and_return(handler)

      result = bus.call(command)

      expect(result).to eq([:handled, 1])
      expect(execution).to eq([
        [:m1_before, 1],
        [:m2_before, 1],
        [:m2_after, [:handled, 1]],
        [:m1_after, [:handled, 1]]
      ])
    end

    it "propagates handler lookup errors" do
      bus = described_class.new(registry: registry, middleware: [])

      allow(registry).to receive(:command_handler_for)
        .with(command)
        .and_raise(Bifrost::Errors::HandlerNotFound, "missing")

      expect { bus.call(command) }.to raise_error(Bifrost::Errors::HandlerNotFound, "missing")
    end
  end
end
