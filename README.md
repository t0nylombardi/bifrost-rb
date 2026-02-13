# Bifrost-rb

Bifrost-rb is a framework-agnostic CQRS engine for Ruby.

It is designed to be:

- Result-driven (`Success` / `Failure` outcomes)
- Explicit and predictable (no hidden magic)
- Minimal but production-aware
- Easy to integrate in Rails, Sinatra, Roda, Hanami, or plain Ruby apps

## Status

`0.1.0` is the first functional foundation release.

Current public surface:

- `Bifrost.build` container builder
- Command/query handler registration
- Command/query middleware chains
- `Bifrost::Result::Success` and `Bifrost::Result::Failure`
- Explicit handler lookup failures via `Bifrost::Errors::HandlerNotFound`

## Installation

Add to your Gemfile:

```ruby
gem "bifrost-rb"
```

Or install directly:

```bash
gem install bifrost-rb
```

## Quick Start

```ruby
require "bifrost"

CreateUser = Struct.new(:email, keyword_init: true)
FindUserByEmail = Struct.new(:email, keyword_init: true)

command_handler = lambda do |command|
  # Persist user, publish events, etc.
  Bifrost::Result::Success.new(user_id: "usr_123", email: command.email)
end

query_handler = lambda do |query|
  if query.email == "missing@example.com"
    Bifrost::Result::Failure.new(:not_found, email: query.email)
  else
    Bifrost::Result::Success.new(user_id: "usr_123", email: query.email)
  end
end

container = Bifrost.build do |config|
  config.register_command(CreateUser, command_handler)
  config.register_query(FindUserByEmail, query_handler)
end

create_result = container.commands.call(CreateUser.new(email: "dev@example.com"))
lookup_result = container.queries.call(FindUserByEmail.new(email: "dev@example.com"))
```

## Middleware

```ruby
logging_middleware = lambda do |message, next_step|
  started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  result = next_step.call
  duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at

  puts "[Bifrost] #{message.class} completed in #{duration.round(4)}s"
  result
end

container = Bifrost.build do |config|
  config.register_command(CreateUser, command_handler)
  config.use_command_middleware(logging_middleware)
end
```

Middleware contract:

- Receives `(message, next_step)`
- Must call `next_step.call` to continue the chain
- May wrap behavior before/after dispatch (logging, tracing, metrics, auth, etc.)

## Result Contract

```ruby
result = container.commands.call(CreateUser.new(email: "dev@example.com"))

if result.success?
  puts result.value[:user_id]
else
  puts "Error: #{result.error}, meta: #{result.meta.inspect}"
end
```

`Bifrost::Result::Success`:

- `#success?` => `true`
- `#failure?` => `false`
- `#value` holds payload

`Bifrost::Result::Failure`:

- `#success?` => `false`
- `#failure?` => `true`
- `#error` holds failure reason
- `#meta` holds structured metadata

## Error Handling

When a handler is not registered, Bifrost raises:

- `Bifrost::Errors::HandlerNotFound`

Example:

```ruby
container.commands.call(UnregisteredCommand.new)
# => raises Bifrost::Errors::HandlerNotFound
```

## Development

```bash
bin/setup
bundle exec rspec
bundle exec standardrb
```

## Release

```bash
bundle exec rake install
bundle exec rake release
```

## Roadmap

- `dry-validation` integration
- Optional base abstractions for commands/queries
- Expanded middleware and instrumentation helpers

## Contributing

Issues and pull requests are welcome:

- https://github.com/t0nylombardi/bifrost-rb

## License

Bifrost-rb is released under the MIT License. See `LICENSE.txt`.
