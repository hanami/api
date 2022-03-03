# Hanami::API

Minimal, extremely fast, lightweight Ruby framework for HTTP APIs.

## Version

**This branch contains the code for `hanami-api` 0.3.x.**

## Status

[![Gem Version](https://badge.fury.io/rb/hanami-api.svg)](https://badge.fury.io/rb/hanami-api)
[![CI](https://github.com/hanami/api/workflows/ci/badge.svg?branch=main)](https://github.com/hanami/api/actions?query=workflow%3Aci+branch%3Amain)
[![Test Coverage](https://codecov.io/gh/hanami/api/branch/main/graph/badge.svg)](https://codecov.io/gh/hanami/api)
[![Depfu](https://badges.depfu.com/badges/a8545fb67cf32a2c75b6227bc0821027/overview.svg)](https://depfu.com/github/hanami/api?project=Bundler)
[![Inline Docs](http://inch-ci.org/github/hanami/api.svg)](http://inch-ci.org/github/hanami/api)

## Contact

* Home page: http://hanamirb.org
* Mailing List: http://hanamirb.org/mailing-list
* API Doc: http://rdoc.info/gems/hanami-api
* Bugs/Issues: https://github.com/hanami/api/issues
* Support: http://stackoverflow.com/questions/tagged/hanami
* Chat: http://chat.hanamirb.org

## Rubies

__Hanami::API__ supports Ruby (MRI) 3.0+

## Installation

Add these lines to your application's `Gemfile`:

```ruby
gem "hanami-api"
gem "puma" # or "webrick", or "thin", "falcon"
```

And then execute:

```shell
$ bundle install
```

Or install it yourself as:

```shell
$ gem install hanami-api
```

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
      * [String (body)](#string-body)
      * [Enumerator (body)](#enumerator-body)
      * [Integer (status code)](#integer-status-code)
      * [Integer, String (status code, body)](#integer-string-status-code-body)
      * [Integer, Enumerator (status code, body)](#integer-enumerator-status-code-body)
      * [Integer, Hash, String (status code, headers, body)](#integer-hash-string-status-code-headers-body)
      * [Integer, Hash, Enumerator (status code, headers, body)](#integer-hash-enumerator-status-code-headers-body)
  + [Block context](#block-context)
    - [env](#env)
    - [status](#status)
    - [headers](#headers)
    - [body](#body)
    - [params](#params)
    - [halt](#halt)
    - [redirect](#redirect)
    - [back](#back)
    - [json](#json)
  + [Scope](#scope)
  + [Helpers](#helpers)
  + [Rack Middleware](#rack-middleware)
  + [Streamed Responses](#streamed-responses)
  + [Body Parsers](#body-parsers)
* [Testing](#testing)
* [Development](#development)
* [Contributing](#contributing)

## Performance

Benchmark against an app with 10,000 routes, hitting the 10,000th to measure the worst case scenario.
Based on [`jeremyevans/r10k`](https://github.com/jeremyevans/r10k), `Hanami::API` scores first for speed, and second for memory footprint.

### Runtime

Runtime to complete 20,000 requests (lower is better).

| Framework  | Seconds to complete |
|------------|---------------------|
| hanami-api | 0.116               |
| watts      | 0.235               |
| roda       | 0.348               |
| syro       | 0.356               |
| rack-app   | 0.623               |
| cuba       | 1.291               |
| rails      | 17.047              |
| sinatra    | 197.477             |

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
  * `delete`
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

##### String (body)

```ruby
get "/" do
  "Hello, world"
end
```

It will return `[200, {}, ["Hello, world"]]`

##### Enumerator (body)

```ruby
get "/" do
  Enumerator.new { ... }
end
```

It will return `[200, {}, Enumerator]`, see [Streamed Responses](#streamed-responses)

##### Integer (status code)

```ruby
get "/" do
  418
end
```

It will return `[418, {}, ["I'm a teapot"]]`

##### Integer, String (status code, body)

```ruby
get "/" do
  [401, "You shall not pass"]
end
```

It will return `[401, {}, ["You shall not pass"]]`

##### Integer, Enumerator (status code, body)

```ruby
get "/" do
  [401, Enumerator.new { ... }]
end
```

It will return `[401, {}, Enumerator]`, see [Streamed Responses](#streamed-responses)

##### Integer, Hash, String (status code, headers, body)

```ruby
get "/" do
  [401, {"X-Custom-Header" => "foo"}, "You shall not pass"]
end
```

It will return `[401, {"X-Custom-Header" => "foo"}, ["You shall not pass"]]`

##### Integer, Hash, Enumerator (status code, headers, body)

```ruby
get "/" do
  [401, {"X-Custom-Header" => "foo"}, Enumerator.new { ... }]
end
```

It will return `[401, {"X-Custom-Header" => "foo"}, Enumerator]`, see [Streamed Responses](#streamed-responses)

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

Set HTTP response body using a [Streamed Response](#streamed-responses)

```ruby
get "/" do
  body Enumerator.new { ... }
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

You can also use a [Streamed Response](#streamed-responses) here

```ruby
get "/authenticate" do
  halt(401, Enumerator.new { ... })
end
```

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

If you want a [Streamed Response](#streamed-responses)

```ruby
get "/users" do
  users = Enumerator.new { ... }
  json(users)
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

### Helpers

Define helper methods available within the block context.
Helper methods have access to default utilities available in block context (e.g. `#halt`).

Helpers can be defined inline by passing a block to the `.helpers` method:

```ruby
require "hanami/api"

class MyAPI < Hanami::API
  helpers do
    def redirect_to_root
      # redirect method is provided by Hanami::API block context
      redirect "/"
    end
  end

  root { "Hello, World" }

  get "/legacy" do
    redirect_to_root
  end
end
```

Alternatively, `.helpers` accepts a module.

```ruby
require "hanami/api"

class MyAPI < Hanami::API
  module Authentication
    private

    def unauthorized
      halt(401)
    end
  end

  helpers(Authentication)

  root { "Hello, World" }

  get "/secrets" do
    unauthorized
  end
end
```

You can use `.helpers` multiple times in the same app.

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

### Streamed Responses

When the work to be done by the server takes time, it may be a good idea to
stream your response. For this, you just use an `Enumerator` anywhere you would
normally use a `String` as body or another `Object` as JSON response. Here's an
example of streaming JSON data:

```ruby
scope "stream" do
  use ::Rack::Chunked

  get "/data" do
    Enumerator.new do |yielder|
      data = %w[a b c]
      data.each do |item|
        yielder << item
      end
    end
  end

  get "/to_enum" do
    %w[a b c].to_enum
  end

  get "/json" do
    result = Enumerator.new do |yielder|
      data = %w[a b c]
      data.each do |item|
        yielder << item
      end
    end

    json(result)
  end
end
```

Note:

* Returning an `Enumerator` will also work without `Rack::Chunked`, it just
  won't stream but return the whole body at the end instead.
* Data pushed to `yielder` MUST be a `String`.
* Streaming does not work with WEBrick as it buffers its response. We recommend
  using `puma`, though you may find success with other servers.
* To manual test this feature use a web browser or cURL:

```shell
$ curl --raw -i http://localhost:2300/stream/data
```

### Body Parsers

Rack ignores request bodies unless they come from a form submission.
If you have an endpoint that accepts JSON, the request payload isn’t available in `params`.

In order to parse JSON payload and make it avaliable in `params`, you should add the following lines to `config.ru`:

```ruby
# frozen_string_literal: true
require "hanami/middleware/body_parser"

use Hanami::Middleware::BodyParser, :json
```

## Testing

## Unit testing
You can unit test your `Hanami::API` app by passing a `env` hash to your app's `#call` method.

The keys that (based on the Rack standard) `Hanami::API` uses for routing are:
* `PATH_INFO`
* `REQUEST_METHOD`


For example, a spec for the basic app in the [Usage section](https://github.com/hanami/api#usage) could be:

```
require "my_project/app"

RSpec.describe App do
  describe "#call" do
    it "returns successfully" do
      env = {"PATH_INFO" => "/", "REQUEST_METHOD" => "GET"]}
      response = subject.call({"PATH_INFO" => "/", "REQUEST_METHOD" => "GET"]})
      expect(response).to eq([200, {}, ["Hello, world"]])
    end
  end
end
```

## Integration testing
Add this line to your application's `Gemfile`:

```ruby
gem "rack-test", group: :test
```

In a test, load `Rack::Test`:

```ruby
require "rack/test"
```

and then, inside your spec/test, include its helper methods:

```ruby
include Rack::Test::Methods
```

Then you can use its methods like `get` and `last_response`, e.g.:

```ruby
it "returns the status 200" do
  get "/"
  expect(last_response.status).to eq 200
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hanami/api.
