# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bifrost do
  it "has a version number" do
    expect(Bifrost::VERSION).not_to be nil
  end
end
