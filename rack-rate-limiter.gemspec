# frozen_string_literal: true

require_relative "lib/rack/rate_limiter/version"

Gem::Specification.new do |spec|
  spec.name = "rack-rate-limiter"
  spec.version = Rack::RateLimiter::VERSION
  spec.authors = ["Rick Caudill"]
  spec.email = ["rick.g.caudill@gmail.com"]

  spec.summary = "Rack rate limiter."
  spec.description = "Rack rate limiter."
  spec.homepage = "http://github.com/rickcaudill/rack-rate-limiter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = "http://github.com/rickcaudill/rack-rate-limiter"
  spec.metadata["source_code_uri"] = "http://github.com/rickcaudill/rack-rate-limiter"
  spec.metadata["changelog_uri"] = "http://github.com/rickcaudill/rack-rate-limiter/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency 'rack', '< 4'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
