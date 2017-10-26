module EventMachine
  module CircuitBreaker
    module Strategy
      class Basic
        def initialize(failure_count: 5, recovery_time: 30)
          close!
          @failure_limit = failure_count
          @recovery_time = recovery_time
        end

        def open?
          @state == :open
        end

        def handle_response(client)
          increment_failures if client.response_header.server_error?
          close! if half_open? && client.response_header.successful?
        end

        private

        def half_open?
          @state == :half_open
        end

        def increment_failures
          @failures += 1
          open! if @failures >= @failure_limit
        end

        def half_open!
          @state = :half_open
        end

        def open!
          @state = :open

          EventMachine.add_timer(@recovery_time) { half_open! }
        end

        def close!
          @state = :closed
          @failures = 0
        end
      end
    end
  end
end
