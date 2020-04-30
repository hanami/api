# frozen_string_literal: true

RSpec.describe Hanami::API do
  describe "Rack middleware" do
    let(:app) { Rack::MockRequest.new(api) }

    let(:api) do
      elapsed = elapsed_middleware
      auth = auth_middleware
      rate_limiter = rate_limiter_middleware
      api_version = api_version_middleware
      api_deprecation = api_deprecation_middleware

      Class.new(described_class) do
        use elapsed
        root to: ->(*) { [200, { "Content-Length" => "4" }, ["Home"]] }

        scope "/admin" do
          use auth

          root to: lambda { |env|
            body = "Admin: User ID (#{env['AUTH_USER_ID']})"
            [200, { "Content-Length" => body.bytesize.to_s }, [body]]
          }
        end

        # Without leading slash
        # See: https://github.com/hanami/api/issues/8
        scope "api" do
          use rate_limiter

          root to: lambda { |*|
            body = "API"
            [200, { "Content-Length" => body.bytesize.to_s }, [body]]
          }

          scope "v1" do
            use api_version
            use api_deprecation

            root to: lambda { |*|
              body = "API v1"
              [200, { "Content-Length" => body.bytesize.to_s }, [body]]
            }
          end
        end
      end.new
    end

    let(:elapsed_middleware) do
      Class.new do
        def initialize(app)
          @app = app
        end

        def call(env)
          with_time_instrumentation do
            @app.call(env)
          end
        end

        private

        def with_time_instrumentation
          starting = now
          status, headers, body = yield
          ending = now

          headers["X-Elapsed"] = (ending - starting).round(5).to_s
          [status, headers, body]
        end

        def now
          Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end
      end
    end

    let(:auth_middleware) do
      Class.new do
        def initialize(app)
          @app = app
        end

        def call(env)
          env["AUTH_USER_ID"] = user_id = "23"
          status, headers, body = @app.call(env)
          headers["X-Auth-User-ID"] = user_id

          [status, headers, body]
        end
      end
    end

    let(:rate_limiter_middleware) do
      Class.new do
        def initialize(app)
          @app = app
        end

        def call(env)
          status, headers, body = @app.call(env)
          headers["X-API-Rate-Limit-Quota"] = "4000"

          [status, headers, body]
        end
      end
    end

    let(:api_version_middleware) do
      Class.new do
        def initialize(app)
          @app = app
        end

        def call(env)
          status, headers, body = @app.call(env)
          headers["X-API-Version"] = "1"

          [status, headers, body]
        end
      end
    end

    let(:api_deprecation_middleware) do
      Class.new do
        def initialize(app)
          @app = app
        end

        def call(env)
          status, headers, body = @app.call(env)
          headers["X-API-Deprecated"] = "API v1 is deprecated"

          [status, headers, body]
        end
      end
    end

    it "uses Rack middleware" do
      response = app.get("/", lint: true)

      expect(response.status).to be(200)
      expect(response.headers).to have_key("X-Elapsed")
      expect(response.headers).to_not have_key("X-Auth-User-ID")
      expect(response.headers).to_not have_key("X-API-Rate-Limit-Quota")
      expect(response.headers).to_not have_key("X-API-Version")
    end

    it "uses Rack middleware for other paths" do
      response = app.get("/foo", lint: true)

      expect(response.status).to be(404)
      expect(response.headers).to have_key("X-Elapsed")
      expect(response.headers).to_not have_key("X-Auth-User-ID")
      expect(response.headers).to_not have_key("X-API-Rate-Limit-Quota")
      expect(response.headers).to_not have_key("X-API-Version")
    end

    context "scoped" do
      it "uses Rack middleware" do
        response = app.get("/admin", lint: true)

        expect(response.status).to be(200)
        expect(response.headers).to have_key("X-Elapsed")
        expect(response.headers).to have_key("X-Auth-User-ID")
        expect(response.headers).to_not have_key("X-API-Rate-Limit-Quota")
        expect(response.headers).to_not have_key("X-API-Version")
      end

      it "uses Rack middleware for other paths" do
        response = app.get("/admin/users", lint: true)

        expect(response.status).to be(404)
        expect(response.headers).to have_key("X-Elapsed")
        expect(response.headers).to have_key("X-Auth-User-ID")
        expect(response.headers).to_not have_key("X-API-Rate-Limit-Quota")
        expect(response.headers).to_not have_key("X-API-Version")
      end

      # See: https://github.com/hanami/api/issues/8
      it "uses Rack middleware for scope w/o leading slash" do
        response = app.get("/api", lint: true)

        expect(response.status).to be(200)
        expect(response.headers).to have_key("X-Elapsed")
        expect(response.headers).to_not have_key("X-Auth-User-ID")
        expect(response.headers).to have_key("X-API-Rate-Limit-Quota")
        expect(response.headers).to_not have_key("X-API-Version")
      end

      # See: https://github.com/hanami/api/issues/8
      it "uses Rack middleware for nested scope w/o leading slash" do
        response = app.get("/api/v1", lint: true)

        expect(response.status).to be(200)
        expect(response.headers).to have_key("X-Elapsed")
        expect(response.headers).to_not have_key("X-Auth-User-ID")
        expect(response.headers).to have_key("X-API-Rate-Limit-Quota")
        expect(response.headers).to have_key("X-API-Version")
      end
    end
  end
end
