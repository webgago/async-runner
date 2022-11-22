# frozen_string_literal: true

require_relative "lib/async/runner/version"

Gem::Specification.new do |spec|
  spec.name = "async-runner"
  spec.version = Async::Runner::VERSION

  spec.summary = "Abstract runner with container-based parallelism using threads and processes where appropriate."
  spec.authors = ["Anton Sozontov"]
  spec.license = "MIT"

  spec.homepage = "https://github.com/webgago/async-runner"

  spec.files = Dir.glob('{lib,exe}/**/*', File::FNM_DOTMATCH, base: __dir__)
  spec.bindir        = "exe"
  spec.executables   = ['async-runner']
  spec.required_ruby_version = ">= 3.1"

  spec.add_dependency "async"
  spec.add_dependency "async-container"
  spec.add_dependency "samovar", "~> 2.1"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "covered"
  spec.add_development_dependency "rspec", "~> 3.6"

  spec.add_development_dependency "bake-test"
  spec.add_development_dependency "bake-test-external"
  spec.add_development_dependency "sus"
end
