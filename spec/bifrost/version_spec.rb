# frozen_string_literal: true

require "spec_helper"

RSpec.describe "bifrost/version" do
  it "defines VERSION in the Bifrost namespace" do
    Bifrost.send(:remove_const, :VERSION) if Bifrost.const_defined?(:VERSION, false)

    load File.expand_path("../../lib/bifrost/version.rb", __dir__)

    expect(Bifrost::VERSION).to eq("0.1.0")
  end
end
