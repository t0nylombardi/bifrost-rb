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

    describe ".success" do
      it "builds a dry-monads Success result with the provided value" do
        monad = described_class.success("payload")

        expect(monad).to be_a(Dry::Monads::Result::Success)
        expect(monad.value!).to eq("payload")
      end
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

    describe ".failure" do
      it "builds a dry-monads Failure result with error and metadata tuple" do
        monad = described_class.failure(:invalid, field: :email)

        expect(monad).to be_a(Dry::Monads::Result::Failure)
        expect(monad.failure).to eq([:invalid, {field: :email}])
      end

      it "uses empty metadata by default" do
        monad = described_class.failure(:invalid)

        expect(monad.failure).to eq([:invalid, {}])
      end
    end
  end
end
