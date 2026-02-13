# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bifrost::Bus::QueryBus do
  let(:query) { Struct.new(:id).new(3) }
  let(:handler) { ->(message) { [:resolved, message.id] } }
  let(:registry) { instance_double(Bifrost::HandlerRegistry) }

  describe "#call" do
    it "dispatches query through middleware and handler" do
      execution = []
      middleware = [
        lambda do |message, next_step|
          execution << [:m1_before, message.id]
          value = next_step.call
          execution << [:m1_after, value]
          value
        end
      ]
      bus = described_class.new(registry: registry, middleware: middleware)

      allow(registry).to receive(:query_handler_for).with(query).and_return(handler)

      result = bus.call(query)

      expect(result).to eq([:resolved, 3])
      expect(execution).to eq([
        [:m1_before, 3],
        [:m1_after, [:resolved, 3]]
      ])
    end

    it "propagates handler lookup errors" do
      bus = described_class.new(registry: registry, middleware: [])

      allow(registry).to receive(:query_handler_for)
        .with(query)
        .and_raise(Bifrost::Errors::HandlerNotFound, "missing")

      expect { bus.call(query) }.to raise_error(Bifrost::Errors::HandlerNotFound, "missing")
    end
  end
end
