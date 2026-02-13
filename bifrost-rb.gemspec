# frozen_string_literal: true

require_relative "lib/bifrost/version"

Gem::Specification.new do |spec|
  spec.name = "bifrost-rb"
  spec.version = Bifrost::VERSION
  spec.authors = ["T0ny Lombardi"]
  spec.email = ["iam@t0nylombardi.com"]

  spec.summary = "Framework-agnostic CQRS engine for Ruby"
  spec.description = "Bifrost-rb is a result-driven, minimal CQRS engine with "\
    "dry-rb validation and middleware hooks for production workloads."
  spec.homepage = "https://github.com/t0nylombardi/bifrost-rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/t0nylombardi/bifrost-rb"
  spec.metadata["changelog_uri"] = "https://github.com/t0nylombardi/bifrost-rb/blob/main/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-monads", "~> 1.8"
  spec.add_dependency "dry-validation", "~> 1.11"
  spec.add_dependency "dry-struct", "~> 1.5"
  spec.add_dependency "dry-types", "~> 1.5"
end
