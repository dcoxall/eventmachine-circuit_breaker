# EventMachine::CircuitBreaker

[![Build Status](https://travis-ci.org/dcoxall/eventmachine-circuit_breaker.svg?branch=master)](https://travis-ci.org/dcoxall/eventmachine-circuit_breaker)

**This project is still in active development**

This library is meant to provide a simple way to enable the circuit breaker pattern to em-http requests by providing some middleware that can prevent requests and manage circuit state based on response parameters.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eventmachine-circuit_breaker'
```

And then execute:

    $ bundle


## Usage

```ruby
require 'eventmachine/circuit_breaker'
require 'em-http-request'

# circuit breaker for all requests
EventMachine.run do
  EventMachine::HttpRequest.use EventMachine::CircuitBreaker
  # now you can use em-http-request as normal
end

# circuit breaker per connection
EventMachine.run do
  connection = EventMachine::HttpRequest.new("http://example.com")
  connection.use EventMachine::CircuitBreaker
  connection.get
  # ...
end

# sharing circuit state
EventMachine.run do
  circuit_strategy = EventMachine::CircuitBreaker::Strategy::Basic.new

  connection_1 = EventMachine::HttpRequest.new("http://example.com/foo")
  connection_1.use EventMachine::CircuitBreaker, strategy: circuit_strategy
  connection_1.get
  # ...

  connection_2 = EventMachine::HttpRequest.new("http://example.com/bar")
  connection_2.use EventMachine::CircuitBreaker, strategy: circuit_strategy
  connection_2.get
  # ...
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dcoxall/eventmachine-circuit_breaker.
