require "test_helper"

module EventMachine
  module CircuitBreaker
    module Strategy
      class BasicTest < Minitest::Test
        include EventMachine::TestHelper
        include WebMock::API

        def setup
          stub_request(:get, "http://example.com/success").to_return(status: 200)
          stub_request(:get, "http://example.com/fail").to_return(status: 500)
        end

        def test_defaults_to_closed
          within_eventmachine do |done|
            strategy = Basic.new
            refute_predicate strategy, :open?
            done.call
          end
        end

        def test_closes_after_configured_failures
          within_eventmachine do |done|
            strategy = Basic.new(failure_count: 2)
            multi = EventMachine::MultiRequest.new

            callback(multi, done) do
              multi.responses[:callback].each do |_, client|
                refute_predicate strategy, :open?
                strategy.handle_response(client)
              end
              assert_predicate strategy, :open?
            end

            multi.add :fail_1, http_req(:get, "http://example.com/fail")
            multi.add :fail_2, http_req(:get, "http://example.com/fail")
          end
        end

        def test_recovers_after_configured_time
          within_eventmachine do |done|
            strategy = Basic.new(failure_count: 1, recovery_time: 0.2)

            http_req(:get, "http://example.com/fail", strategy) do |client|
              callback(client, done, flunk: true)
              errback(client) do
                # confirm request opened the circuit
                assert_predicate strategy, :open?
              end
            end

            EventMachine.add_timer(0.1) do
              # circuit should still be open
              assert_predicate strategy, :open?
            end

            EventMachine.add_timer(0.3) do
              refute_predicate strategy, :open?
              done.call
            end
          end
        end

        def test_allows_single_request_to_test_recovery_fail
          within_eventmachine do |done|
            strategy = Basic.new(failure_count: 1, recovery_time: 0.1)

            http_req(:get, "http://example.com/fail", strategy) do |client|
              callback(client, done, flunk: true)
              errback(client) do
                # confirm request opened the circuit
                assert_predicate strategy, :open?
              end
            end

            # wait for recovery and try again
            EventMachine.add_timer(0.2) do
              http_req(:get, "http://example.com/fail", strategy) do |client|
                callback(client, done, flunk: true)
                errback(client, done) do
                  # confirm request opened the circuit
                  assert_predicate strategy, :open?
                end
              end
            end
          end
        end

        def test_allows_single_request_to_test_recovery_success
          within_eventmachine do |done|
            strategy = Basic.new(failure_count: 1, recovery_time: 0.1)

            http_req(:get, "http://example.com/fail", strategy) do |client|
              callback(client, done, flunk: true)
              errback(client) do
                # confirm request opened the circuit
                assert_predicate strategy, :open?
              end
            end

            # wait for recovery and try again
            EventMachine.add_timer(0.2) do
              http_req(:get, "http://example.com/success", strategy) do |client|
                callback(client, done) do
                  # confirm request closed the circuit
                  refute_predicate strategy, :open?
                end
                errback(client, done, flunk: true)
              end
            end
          end
        end

      end
    end
  end
end
