# Bifrost-rb

Bifrost-rb is a framework-agnostic CQRS engine for Ruby.

It is designed to be:

- Result-driven (`Success` / `Failure` outcomes)
- Explicit and predictable (no hidden magic)
- Minimal but production-aware
- Easy to integrate in Rails, Sinatra, Roda, Hanami, or plain Ruby apps

## Status

`0.1.0` is an initial foundation release.

The public CQRS API is currently being built. The roadmap below captures the intended stable surface.

## Roadmap

- `Bifrost::Command` and `Bifrost::Query` base objects
- Monadic result contract for all executions
- Contract validation via `dry-validation`
- Middleware chain hooks for logging, metrics, and tracing
- Lightweight dependency container and explicit execution context

## Installation

Add to your Gemfile:

```ruby
gem "bifrost-rb"
```

Or install directly:

```bash
gem install bifrost-rb
```

## Intended Usage (Target API)

The API below is the direction for upcoming releases and may evolve slightly before `1.0`.

```ruby
result = Users::RegisterCommand.call(
  params: { email: "dev@example.com", password: "s3cret-passphrase" },
  context: { request_id: "req_123" }
)

if result.success?
  puts result.value![:user_id]
else
  puts result.failure[:errors]
end
```

## Development

```bash
bin/setup
bundle exec rspec
```

## Release

```bash
bundle exec rake install
bundle exec rake release
```

## Contributing

Issues and pull requests are welcome:

- https://github.com/t0nylombardi/bifrost-rb

## License

Bifrost-rb is released under the MIT License. See `LICENSE.txt`.
