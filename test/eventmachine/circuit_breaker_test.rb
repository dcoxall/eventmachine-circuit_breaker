require "test_helper"

module EventMachine
  class CircuitBreakerTest < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::EventMachine::CircuitBreaker::VERSION
    end
  end
end
