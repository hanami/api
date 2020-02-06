# frozen_string_literal: true

RSpec.describe Hanami::API do
  describe "scope" do
    subject do
      Class.new(described_class) do
        scope "/v1" do
          get "/users" do
            "v1 users"
          end
        end

        scope "/v2" do
          get "/users" do
            "v2 users"
          end
        end
      end.new
    end

    it "defines scoped routes" do
      env = Rack::MockRequest.env_for("/v1/users")
      status, _, body = subject.call(env)

      expect(status).to eq(200)
      expect(body).to eq(["v1 users"])

      env = Rack::MockRequest.env_for("/v2/users")
      status, _, body = subject.call(env)

      expect(status).to eq(200)
      expect(body).to eq(["v2 users"])
    end
  end
end
