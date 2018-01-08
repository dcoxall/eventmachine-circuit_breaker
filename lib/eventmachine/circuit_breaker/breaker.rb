module EventMachine
  module CircuitBreaker
    class Breaker
      def initialize(strategy = Strategy::Basic.new)
        @strategy = strategy
      end

      def request(client, headers, body)
        close!(client) if strategy.open?
        [headers, body]
      end

      def response(client)
        strategy.handle_response(client)
        close!(client) if strategy.open?
      end

      private

      attr_reader :strategy

      def close!(client, reason: 'circuit open')
        client.close(reason)
      end
    end
  end
end
