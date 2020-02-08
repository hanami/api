# Hanami::API

Minimal, extremely fast, lightweight Ruby framework for HTTP APIs.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem "hanami-api"
```

And then execute:

```shell
$ bundle install
```

Or install it yourself as:

```shell
$ gem install hanami-api
```

## Usage

Create `config.ru` at the root of your project:

```ruby
# frozen_string_literal: true

require "bundler/setup"
require "hanami/api"

class App < Hanami::API
  get "/" do
    "Hello, world"
  end
end

run App.new
```

Start the Rack server with `bundle exec rackup`

### Endpoints

### Scope

### Rack Middleware

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hanami/api.

