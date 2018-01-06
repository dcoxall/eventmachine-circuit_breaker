module EventMachine
  module CircuitBreaker
    module Strategy
      class Basic
        def initialize(failure_count: 5, recovery_time: 30)
          @mutex = EventMachine::CircuitBreaker::RWMutex.new
          close!
          @failure_limit = failure_count
          @recovery_time = recovery_time
        end

        def open?
          mutex.read_lock { @state == :open }
        end

        def handle_response(client)
          increment_failures if client.response_header.server_error?
          close! if half_open? && client.response_header.successful?
        end

        private

        attr_reader :mutex

        def half_open?
          mutex.read_lock { @state == :half_open }
        end

        def increment_failures
          mutex.write_lock { @failures += 1 }
          open! if mutex.read_lock { @failures >= @failure_limit }
        end

        def half_open!
          mutex.write_lock { @state = :half_open }
        end

        def open!
          mutex.write_lock { @state = :open }

          EventMachine.add_timer(@recovery_time) { half_open! }
        end

        def close!
          mutex.write_lock do
            @state = :closed
            @failures = 0
          end
        end
      end
    end
  end
end
