RSpec.describe Hanami::API do
  describe "scope" do
    subject do
      Class.new(described_class) do
        scope "api" do
          scope "/v1" do
            root do
              "v1"
            end

            get "/users" do
              "v1 users"
            end
          end

          scope "/v2" do
            get "/users" do
              "v2 users"
            end
          end
        end
      end.new
    end

    it "defines scoped routes" do
      env = Rack::MockRequest.env_for("/api/v1")
      status, _, body = subject.call(env)

      expect(status).to eq(200)
      expect(body).to eq(["v1"])

      env = Rack::MockRequest.env_for("/api/v1/users")
      status, _, body = subject.call(env)

      expect(status).to eq(200)
      expect(body).to eq(["v1 users"])

      env = Rack::MockRequest.env_for("/api/v2/users")
      status, _, body = subject.call(env)

      expect(status).to eq(200)
      expect(body).to eq(["v2 users"])
    end
  end
end
