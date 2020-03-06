# Hanami::API

Minimal, extremely fast, lightweight Ruby framework for HTTP APIs.

* [Installation](#installation)
* [Performance](#performance)
  + [Runtime](#runtime)
  + [Memory](#memory)
  + [Requests per second](#requests-per-second)
* [Usage](#usage)
  + [Routes](#routes)
  + [HTTP methods](#http-methods)
  + [Endpoints](#endpoints)
    - [Rack endpoint](#rack-endpoint)
    - [Block endpoint](#block-endpoint)
      * [String](#string)
      * [Integer](#integer)
      * [Integer, String](#integer--string)
      * [Integer, Hash, String](#integer--hash--string)
  + [Block context](#block-context)
    - [`env`](#env)
    - [`status`](#status)
    - [`headers`](#headers)
    - [`body`](#body)
    - [`params`](#params)
    - [`halt`](#halt)
    - [`redirect`](#redirect)
    - [`back`](#back)
    - [`json`](#json)
  + [Scope](#scope)
  + [Rack Middleware](#rack-middleware)
* [Development](#development)
* [Contributing](#contributing)

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

## Performance

Benchmark against an app with 10,000 routes, hitting the 10,000th to measure the worst case scenario.
Based on [`jeremyevans/r10k`](https://github.com/jeremyevans/r10k), `Hanami::API` scores first for speed, and second for memory footprint.

### Runtime

Runtime to complete 20,000 requests (lower is better).

| Framework  | Seconds to complete |
|------------|---------------------|
| hanami-api | 0.11628299998119473 |
| watts      | 0.23525599995628    |
| roda       | 0.348202999914065   |
| syro       | 0.355627000099048   |
| rack-app   | 0.6226229998283088  |
| cuba       | 1.2913489998318255  |
| rails      | 17.04722599987872   |
| sinatra    | 197.47695700009353  |

### Memory

Memory footprint for 10,000 routes app (lower is better).

| Framework  | Bytes  |
|------------|--------|
| roda       | 47252  |
| hanami-api | 53988  |
| cuba       | 55420  |
| syro       | 60256  |
| rack-app   | 82976  |
| watts      | 84956  |
| sinatra    | 124980 |
| rails      | 143048 |

### Requests per second

For this benchmark there are two apps for each framework: one with the root route, and one with 10,000 routes.
Requests per second hitting the 1st (and only route) and the 10,000th route to measure the best and worst case scenario (higher is better).

| Framework  | 1st route | 10,000th route |
|------------|-----------|----------------|
| hanami-api | 14719.95  | 14290.20       |
| watts      | 13912.31  | 12609.68       |
| roda       | 13965.20  | 11051.27       |
| syro       | 13079.12  | 10689.51       |
| rack-app   | 10274.01  | 10306.46       |
| cuba       | 13061.82  | 7084.33        |
| rails      | 1345.27   | 303.06         |
| sinatra    | 5038.74   | 28.14          |

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

### Routes

A route is a combination of three elements:

  * HTTP method (e.g. `get`)
  * Path (e.g. `"/"`)
  * Endpoint (e.g. `MyEndpoint.new`)

```ruby
get "/", to: MyEndpoint.new
```

### HTTP methods

`Hanami::API` supports the following HTTP methods:

  * `get`
  * `head`
  * `post`
  * `patch`
  * `put`
  * `options`
  * `trace`
  * `link`
  * `unlink`

### Endpoints

`Hanami::API` supports two kind of endpoints: block and Rack.

#### Rack endpoint

The framework is compatible with Rack. Any Rack endpoint, can be passed to the route:

```ruby
get "/", to: MyRackEndpoint.new
```

#### Block endpoint

A block passed to the route definition is named a block endpoint.
The returning value will compose the Rack response. It can be:

##### String

```ruby
get "/" do
  "Hello, world"
end
```

It will return `[200, {}, ["Hello, world"]]`

##### Integer

```ruby
get "/" do
  418
end
```

It will return `[418, {}, ["I'm a teapot"]]`

##### Integer, String

```ruby
get "/" do
  [401, "You shall not pass"]
end
```

It will return `[401, {}, ["You shall not pass"]]`

##### Integer, Hash, String

```ruby
get "/" do
  [401, {"X-Custom-Header" => "foo"}, "You shall not pass"]
end
```

It will return `[401, {"X-Custom-Header" => "foo"}, ["You shall not pass"]]`

### Block context

When using the block syntax there is a rich API to use.

#### env

The `#env` method exposes the Rack environment for the current request

#### status

Get HTTP status

```ruby
get "/" do
  puts status
    # => 200
end
```

Set HTTP status

```ruby
get "/" do
  status(201)
end
```

#### headers

Get HTTP response headers

```ruby
get "/" do
  puts headers
    # => {}
end
```

Set HTTP status

```ruby
get "/" do
  headers["X-My-Header"] = "OK"
end
```

#### body

Get HTTP response body

```ruby
get "/" do
  puts body
    # => nil
end
```

Set HTTP response body

```ruby
get "/" do
  body "Hello, world"
end
```

#### params

Access params for current request

```ruby
get "/" do
  id = params[:id]
  # ...
end
```

#### halt

Halts the flow of the block and immediately returns with the current HTTP status

```ruby
get "/authenticate" do
  halt(401)

  # this code will never be reached
end
```

It sets a Rack response: `[401, {}, ["Unauthorized"]]`

```ruby
get "/authenticate" do
  halt(401, "You shall not pass")

  # this code will never be reached
end
```

It sets a Rack response: `[401, {}, ["You shall not pass"]]`

#### redirect

Redirects request and immediately halts it

```ruby
get "/legacy" do
  redirect "/dashboard"

  # this code will never be reached
end
```

It sets a Rack response: `[301, {"Location" => "/new"}, ["Moved Permanently"]]`

```ruby
get "/legacy" do
  redirect "/dashboard", 302

  # this code will never be reached
end
```

It sets a Rack response: `[302, {"Location" => "/new"}, ["Moved"]]`

#### back

Utility for redirect back using HTTP request header `HTTP_REFERER`

```ruby
get "/authenticate" do
  if authenticate(env)
    redirect back
  else
    # ...
  end
end
```

#### json

Sets a JSON response for the given object

```ruby
get "/user/:id" do
  user = UserRepository.new.find(params[:id])
  json(user)
end
```

```ruby
get "/user/:id" do
  user = UserRepository.new.find(params[:id])
  json(user, "application/vnd.api+json")
end
```

### Scope

Prefixing routes is possible with routing scopes:

```ruby
scope "api" do
  scope "v1" do
    get "/users", to: Actions::V1::Users::Index.new
  end
end
```

It will generate a route with `"/api/v1/users"` as path.

### Rack Middleware

To mount a Rack middleware it's possible with `.use`

```ruby
# frozen_string_literal: true

require "bundler/setup"
require "hanami/api"

class App < Hanami::API
  use ElapsedTime

  scope "api" do
    use ApiAuthentication

    scope "v1" do
      use ApiV1Deprecation
    end

    scope "v2" do
      # ...
    end
  end
end
```

Middleware are inherited from top level scope.

In the example above, `ElapsedTime` is used for each incoming request because
it's part of the top level scope. `ApiAuthentication` it's used for all the API
versions, because it's defined in the `"api"` scope. `ApiV1Deprecation` is used
only by the routes in `"v1"` scope, but not by `"v2"`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hanami/api.

