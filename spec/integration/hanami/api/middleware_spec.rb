# frozen_string_literal: true

RSpec.describe Hanami::API do
  describe "Rack middleware" do
    let(:app) { Rack::MockRequest.new(api) }

    let(:api) do
      elapsed = elapsed_middleware
      auth = auth_middleware

      Class.new(described_class) do
        use elapsed
        root to: ->(*) { [200, { "Content-Length" => "4" }, ["Home"]] }

        scope "/admin" do
          use auth

          root to: lambda { |env|
            body = "Admin: User ID (#{env['AUTH_USER_ID']})"
            [200, { "Content-Length" => body.bytesize }, [body]]
          }
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

    it "uses Rack middleware" do
      response = app.get("/", lint: true)

      expect(response.headers).to have_key("X-Elapsed")
      expect(response.headers).to_not have_key("X-Auth-User-ID")
    end

    it "uses Rack middleware for other paths" do
      response = app.get("/foo", lint: true)

      expect(response.headers).to have_key("X-Elapsed")
      expect(response.headers).to_not have_key("X-Auth-User-ID")
    end

    context "scoped" do
      it "uses Rack middleware" do
        response = app.get("/admin", lint: true)

        expect(response.headers).to have_key("X-Elapsed")
        expect(response.headers).to have_key("X-Auth-User-ID")
      end

      it "uses Rack middleware for other paths" do
        response = app.get("/admin/users", lint: true)

        expect(response.headers).to have_key("X-Elapsed")
        expect(response.headers).to have_key("X-Auth-User-ID")
      end
    end
  end
end
