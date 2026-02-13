# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bifrost::Errors do
  describe Bifrost::Errors::HandlerNotFound do
    it "inherits from StandardError" do
      expect(described_class).to be < StandardError
    end
  end
end
