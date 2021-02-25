# frozen_string_literal: true

RSpec.describe Hanami::API do
  describe "Block" do
    let(:app) { Rack::MockRequest.new(api) }

    let(:api) do
      Class.new(described_class) do
        root do
          "hello world"
        end

        get "/home", as: :home do
          "home"
        end

        scope "returning" do
          get "/string" do
            "body string"
          end

          get "/status" do
            200
          end

          get "/array" do
            [201, "Created"]
          end

          get "/serialized" do
            [418, {"X-Tea" => "White butterfly"}, "I'm a teapot"]
          end
        end

        scope "values" do
          get "/status" do
            status 201
          end

          get "/status_and_body" do
            status 201
            body "It was created"
          end

          get "/body_and_status" do
            body "It was created"
            status 201
          end

          get "/headers" do
            headers["X-Token"] = "abc"

            "OK"
          end

          get "/headers_and_body" do
            headers["X-Token"] = "def"

            "Cloud"
          end
        end

        scope "halting" do
          get "/code" do
            halt 401
          end

          get "/body" do
            halt 401, "You shall not pass"
          end

          get "/unreachable" do
            halt 401

            raise "boom"
          end
        end

        scope "json" do
          get "/response" do
            json [{id: 23}]
          end

          get "/mime" do
            json [{id: 15}], "application/vnd.api+json"
          end
        end

        scope "redirect" do
          get "/legacy" do
            redirect "/home"
          end

          get "/code" do
            redirect "/home", 302
          end

          get "/back" do
            redirect back
          end
        end

        scope "params" do
        end

        scope "request" do
        end

        scope "response" do
        end

        scope "url_helpers" do
          get "/path" do
            redirect path(:home)
          end

          get "/url" do
            redirect url(:home)
          end
        end

        scope "helpers" do
        end
      end.new
    end

    context "returning values" do
      it "sets body from returning string" do
        response = app.get("/returning/string", lint: true)

        expect(response.status).to  eq(200)
        expect(response.headers).to eq("Content-Length" => "11")
        expect(response.body).to    eq("body string")
      end

      it "sets body from returning status" do
        response = app.get("/returning/status", lint: true)

        expect(response.status).to  eq(200)
        expect(response.headers).to eq("Content-Length" => "2")
        expect(response.body).to    eq("OK")
      end

      it "sets body and code from returning array" do
        response = app.get("/returning/array", lint: true)

        expect(response.status).to  eq(201)
        expect(response.headers).to eq("Content-Length" => "7")
        expect(response.body).to    eq("Created")
      end

      it "sets body and code from returning serialized Rack response" do
        response = app.get("/returning/serialized", lint: true)

        expect(response.status).to  eq(418)
        expect(response.headers).to eq("Content-Length" => "12", "X-Tea" => "White butterfly")
        expect(response.body).to    eq("I'm a teapot")
      end
    end

    context "values" do
      it "sets status" do
        response = app.get("/values/status", lint: true)

        expect(response.status).to  eq(201)
        expect(response.headers).to eq("Content-Length" => "7")
        expect(response.body).to    eq("Created")
      end

      it "sets status and body" do
        response = app.get("/values/status_and_body", lint: true)

        expect(response.status).to  eq(201)
        expect(response.headers).to eq("Content-Length" => "14")
        expect(response.body).to    eq("It was created")
      end

      it "sets body and status" do
        response = app.get("/values/body_and_status", lint: true)

        expect(response.status).to  eq(201)
        expect(response.headers).to eq("Content-Length" => "14")
        expect(response.body).to    eq("It was created")
      end

      it "sets headers" do
        response = app.get("/values/headers", lint: true)

        expect(response.status).to  eq(200)
        expect(response.headers).to eq("Content-Length" => "2", "X-Token" => "abc")
        expect(response.body).to    eq("OK")
      end

      it "sets headers and body" do
        response = app.get("/values/headers_and_body", lint: true)

        expect(response.status).to  eq(200)
        expect(response.headers).to eq("Content-Length" => "5", "X-Token" => "def")
        expect(response.body).to    eq("Cloud")
      end
    end

    context "halting" do
      it "sets status and body from HTTP code" do
        response = app.get("/halting/code", lint: true)

        expect(response.status).to  eq(401)
        expect(response.headers).to eq("Content-Length" => "12")
        expect(response.body).to    eq("Unauthorized")
      end

      it "sets status and body from HTTP code and custom body" do
        response = app.get("/halting/body", lint: true)

        expect(response.status).to  eq(401)
        expect(response.headers).to eq("Content-Length" => "18")
        expect(response.body).to    eq("You shall not pass")
      end

      it "sets intterupts block execution" do
        response = app.get("/halting/unreachable", lint: true)

        expect(response.status).to  eq(401)
        expect(response.headers).to eq("Content-Length" => "12")
        expect(response.body).to    eq("Unauthorized")
      end
    end

    context "json" do
      it "sets body and HTTP header" do
        response = app.get("/json/response", lint: true)

        expect(response.status).to  eq(200)
        expect(response.headers).to eq("Content-Length" => "11", "Content-Type" => "application/json")
        expect(response.body).to    eq(%([{"id":23}]))
      end

      it "sets body and HTTP header from given MIME type" do
        response = app.get("/json/mime", lint: true)

        expect(response.status).to  eq(200)
        expect(response.headers).to eq("Content-Length" => "11", "Content-Type" => "application/vnd.api+json")
        expect(response.body).to    eq(%([{"id":15}]))
      end
    end

    context "redirect" do
      it "sets status and HTTP header" do
        response = app.get("/redirect/legacy", lint: true)

        expect(response.status).to  eq(301)
        expect(response.headers).to eq("Content-Length" => "17", "Location" => "/home")
        expect(response.body).to    eq("Moved Permanently")
      end

      it "sets status and HTTP header from given HTTP code" do
        response = app.get("/redirect/code", lint: true)

        expect(response.status).to  eq(302)
        expect(response.headers).to eq("Content-Length" => "5", "Location" => "/home")
        expect(response.body).to    eq("Found")
      end

      it "sets status and HTTP header from back" do
        response = app.get("/redirect/back", lint: true)

        expect(response.status).to  eq(301)
        expect(response.headers).to eq("Content-Length" => "17", "Location" => "/")
        expect(response.body).to    eq("Moved Permanently")

        response = app.get("/redirect/back", "HTTP_REFERER" => "/foo", lint: true)

        expect(response.status).to  eq(301)
        expect(response.headers).to eq("Content-Length" => "17", "Location" => "/foo")
        expect(response.body).to    eq("Moved Permanently")
      end
    end

    context "url helpers" do
      it "uses path" do
        response = app.get("/url_helpers/path", lint: true)

        expect(response.status).to  eq(301)
        expect(response.headers).to eq("Content-Length" => "17", "Location" => "/home")
        expect(response.body).to    eq("Moved Permanently")
      end

      it "uses url" do
        response = app.get("/url_helpers/url", lint: true)

        expect(response.status).to eq(301)
        expect(response.headers).to eq("Content-Length" => "17", "Location" => "http://localhost/home")
        expect(response.body).to eq("Moved Permanently")
      end
    end
  end
end
