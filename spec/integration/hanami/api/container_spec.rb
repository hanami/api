# frozen_string_literal: true

require "hanami/api/container"

RSpec.describe Hanami::API do
  describe "Container" do
    let(:app) { Rack::MockRequest.new(api) }

    let(:api) do
      unless defined?(Upcase)
        class Upcase
          def call(string)
            string.to_s.upcase
          end
        end
      end

      Class.new(described_class) do
        extend Hanami::API::Container

        register "upcase" do
          Upcase.new
        end

        helpers do
          def up(string)
            upcase.call(string)
          end
        end

        root do
          upcase.call("hello")
        end

        get "/up" do
          up("world")
        end
      end.new
    end

    it "has access to registered component" do
      response = app.get("/", lint: true)

      expect(response.status).to  eq(200)
      expect(response.headers).to eq({"Content-Length" => "5"})
      expect(response.body).to    eq("HELLO")
    end

    it "makes registered component accessible from headers" do
      response = app.get("/up", lint: true)

      expect(response.status).to  eq(200)
      expect(response.headers).to eq({"Content-Length" => "5"})
      expect(response.body).to    eq("WORLD")
    end
  end
end
