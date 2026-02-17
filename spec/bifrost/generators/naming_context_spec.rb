# frozen_string_literal: true

require "spec_helper"
require "bifrost/generators/naming_context"

RSpec.describe Bifrost::Generators::NamingContext do
  describe "#initialize" do
    it "normalizes singular, plural, class and module names" do
      context = described_class.new("  BlogPosts ")

      expect(context.singular).to eq("blog_post")
      expect(context.plural).to eq("blog_posts")
      expect(context.class_name).to eq("BlogPost")
      expect(context.module_name).to eq("BlogPost")
    end
  end
end
