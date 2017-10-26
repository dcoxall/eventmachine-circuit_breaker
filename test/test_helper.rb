$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "minitest/autorun"
require "eventmachine/circuit_breaker"
require "webmock/minitest"

module EventMachine::TestHelper
  def within_eventmachine(&block)
    done = -> { EventMachine.stop }
    EventMachine.run do
      block.call(done)
    end
  end

  def http_req(verb, url, strategy = nil)
    connection = EventMachine::HttpRequest.new(url)
    unless strategy.nil?
      connection.use EventMachine::CircuitBreaker, strategy: strategy
    end
    connection.public_send(verb).tap do |client|
      yield(client) if block_given?
    end
  end

  def callback(client, done = nil, flunk: false)
    client.callback do
      flunk "Unexpectedly triggered" if flunk
      yield if block_given?
      done.call unless done.nil?
    end
  end

  def errback(client, done = nil, flunk: false)
    client.errback do
      flunk "Unexpectedly triggered" if flunk
      yield if block_given?
      done.call unless done.nil?
    end
  end
end
