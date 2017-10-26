# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "eventmachine/circuit_breaker/version"

Gem::Specification.new do |spec|
  spec.name          = "eventmachine-circuit_breaker"
  spec.version       = EventMachine::CircuitBreaker::VERSION
  spec.authors       = ["Darren Coxall"]
  spec.email         = ["darren@darrencoxall.com"]

  spec.summary       = %q{A circuit breaker designed for use with EventMachine.}
  spec.description   = %q{A circuit breaker for use with eventmachine and em-http-request.}
  spec.homepage      = "https://github.com/dcoxall/eventmachine-circuit_breaker"
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "eventmachine"
  spec.add_runtime_dependency "em-http-request"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "webmock", "~> 2.0"
end
