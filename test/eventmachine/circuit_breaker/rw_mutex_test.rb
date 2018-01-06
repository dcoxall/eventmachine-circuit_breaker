require "test_helper"
require "fiber"

module EventMachine
  module CircuitBreaker
    class RWMutexTest < Minitest::Test

      def test_multiple_reads
        mutex = RWMutex.new
        fiber_1 = read_fiber(mutex) { 1 }
        fiber_2 = read_fiber(mutex) { 2 }

        assert_equal 3, fiber_1.resume + fiber_2.resume
      end

      def test_read_preference
        @value  = 0
        mutex   = RWMutex.new
        fiber_1 = read_fiber(mutex)     { @value }
        fiber_2 = read_fiber(mutex)     { @value }
        fiber_3 = write_fiber(mutex, 0) { @value += 1 }

        assert_equal 1, fiber_1.resume + fiber_2.resume + fiber_3.resume
      end

      private

      def read_fiber(mutex, duration = 0.2)
        Fiber.new do
          mutex.read_lock do
            sleep duration
            yield
          end
        end
      end

      def write_fiber(mutex, duration = 0.2)
        Fiber.new do
          mutex.write_lock do
            sleep duration
            yield
          end
        end
      end

    end
  end
end
