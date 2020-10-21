# frozen_string_literal: true

require_relative "lib/hanami/api/version"

Gem::Specification.new do |spec|
  spec.name          = "hanami-api"
  spec.version       = Hanami::API::VERSION
  spec.authors       = ["Luca Guidi"]
  spec.email         = ["me@lucaguidi.com"]

  spec.summary       = "Hanami API"
  spec.description   = "Extremely fast and lightweight HTTP API"
  spec.homepage      = "http://rubygems.org"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hanami/api"
  spec.metadata["changelog_uri"] = "https://github.com/hanami/api/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "hanami-router", "~> 2.0.alpha"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "rubocop", "~> 0.86"
  spec.add_development_dependency "yard", "~> 0.9"
end
