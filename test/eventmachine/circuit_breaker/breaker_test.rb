require "test_helper"

module EventMachine
  module CircuitBreaker
    class BreakerTest < Minitest::Test
      include EventMachine::TestHelper
      include WebMock::API

      class MockStrategy
        attr_reader :state, :responses

        def initialize(state)
          @state = state
          @responses = []
        end

        def open?
          state == :open
        end

        def handle_response(response)
          responses << response
        end
      end

      def setup
        stub_request(:get, "http://example.com/success").to_return(status: 200)
      end

      def test_breaker_closed_request_executed
        strategy = MockStrategy.new(:closed)
        within_eventmachine do |done|
          http_req(:get, "http://example.com/success", strategy) do |client|
            callback(client, done) do
              assert_predicate client.response_header, :successful?
            end
            errback(client, done, flunk: true)
          end
        end
      end

      def test_breaker_open_request_skipped
        strategy = MockStrategy.new(:open)
        within_eventmachine do |done|
          http_req(:get, "http://example.com/success", strategy) do |client|
            callback(client, done, flunk: true)
            errback(client, done) { refute_predicate client.error, :nil? }
          end
        end
      end

      def test_responses_are_sent_to_strategy
        strategy = MockStrategy.new(:closed)
        within_eventmachine do |done|
          http_req(:get, "http://example.com/success", strategy) do |client|
            callback(client, done) { assert_equal [client], strategy.responses }
            errback(client, done, flunk: true)
          end
        end
      end
    end
  end
end
