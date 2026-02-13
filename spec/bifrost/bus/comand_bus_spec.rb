# frozen_string_literal: true

require "spec_helper"

RSpec.describe "bifrost/bus/comand_bus" do
  it "loads the canonical command bus implementation" do
    expect { require "bifrost/bus/comand_bus" }.not_to raise_error
    expect(Bifrost::Bus::CommandBus).to be_a(Class)
  end
end
