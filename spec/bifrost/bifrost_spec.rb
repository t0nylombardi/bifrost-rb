# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bifrost do
  it "has a version number" do
    expect(described_class::VERSION).not_to be_nil
  end

  describe ".build" do
    it "yields configuration and returns a container" do
      test_command = Class.new
      test_query = Class.new
      command_handler = ->(_command) { :command_result }
      query_handler = ->(_query) { :query_result }

      container = described_class.build do |config|
        config.register_command(test_command, command_handler)
        config.register_query(test_query, query_handler)
      end

      expect(container).to be_a(Bifrost::Container)
      expect(container.commands.call(test_command.new)).to eq(:command_result)
      expect(container.queries.call(test_query.new)).to eq(:query_result)
    end
  end
end
