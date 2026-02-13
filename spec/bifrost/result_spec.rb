# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bifrost::Result do
  describe Bifrost::Result::Success do
    it "stores value and exposes success predicates" do
      result = described_class.new("payload")

      expect(result.value).to eq("payload")
      expect(result.success?).to be(true)
      expect(result.failure?).to be(false)
    end
  end

  describe Bifrost::Result::Failure do
    it "stores error and default metadata" do
      result = described_class.new(:invalid)

      expect(result.error).to eq(:invalid)
      expect(result.meta).to eq({})
      expect(result.success?).to be(false)
      expect(result.failure?).to be(true)
    end

    it "stores explicit metadata" do
      result = described_class.new(:invalid, field: :email)

      expect(result.meta).to eq({field: :email})
    end
  end
end
