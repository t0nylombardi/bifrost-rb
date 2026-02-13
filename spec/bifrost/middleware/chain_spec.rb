# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bifrost::Middleware::Chain do
  describe "#call" do
    it "calls final block when middleware is empty" do
      chain = described_class.new([])

      result = chain.call(:message) { :done }

      expect(result).to eq(:done)
    end

    it "executes middleware in declaration order" do
      execution = []
      middleware = [
        lambda do |message, next_step|
          execution << [:m1_before, message]
          value = next_step.call
          execution << [:m1_after, value]
          value
        end,
        lambda do |message, next_step|
          execution << [:m2_before, message]
          value = next_step.call
          execution << [:m2_after, value]
          value
        end
      ]

      chain = described_class.new(middleware)
      result = chain.call(:payload) do
        execution << [:final, :payload]
        :result
      end

      expect(result).to eq(:result)
      expect(execution).to eq([
        [:m1_before, :payload],
        [:m2_before, :payload],
        [:final, :payload],
        [:m2_after, :result],
        [:m1_after, :result]
      ])
    end
  end
end
