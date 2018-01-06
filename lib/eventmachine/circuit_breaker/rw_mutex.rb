require "thread"

module EventMachine
  module CircuitBreaker
    class RWMutex
      def initialize
        @counter = 0
        @counter_mutex = Mutex.new
        @global_mutex  = Mutex.new
      end

      def read_lock
        @counter_mutex.synchronize do
          @counter += 1
          @global_mutex.lock if @counter == 1
        end
        yield if block_given?
      ensure
        @counter_mutex.synchronize do
          @counter -= 1
          @global_mutex.unlock if @counter == 0
        end
      end

      def write_lock
        @global_mutex.synchronize do
          yield if block_given?
        end
      end
    end
  end
end
