require "eventmachine/circuit_breaker/version"
require "eventmachine/circuit_breaker/breaker"
require "eventmachine/circuit_breaker/strategy/basic"

module EventMachine
  module CircuitBreaker
    def new(options = {})
      Breaker.new(options[:strategy])
    end
    module_function :new
  end
end
