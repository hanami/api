# frozen_string_literal: true

RSpec.describe Hanami::API do
  describe ".helpers" do
    let(:app) { Rack::MockRequest.new(api) }

    let(:api) do
      unless defined?(CommonHelpers)
        module CommonHelpers
          private

          def unauthorized
            halt(401)
          end
        end
      end

      Class.new(described_class) do
        helpers do
          def method_that_should_be_mixed_in_the_other_api_instance
          end
        end
      end

      Class.new(described_class) do
        helpers do
          def redirect_to_root
            redirect "/"
          end
        end

        helpers(CommonHelpers)

        root do
          "hello world"
        end

        get "/legacy" do
          redirect_to_root
        end

        get "/unauthorized" do
          unauthorized
        end

        get "/no_method" do
          method_that_should_be_mixed_in_the_other_api_instance
        end
      end.new
    end

    it "uses method defined in inline .helpers block" do
      response = app.get("/legacy", lint: true)

      expect(response.status).to  eq(301)
      expect(response.headers).to eq("Content-Length" => "17", "Location" => "/")
      expect(response.body).to    eq("Moved Permanently")
    end

    it "uses method defined in included module" do
      response = app.get("/unauthorized", lint: true)

      expect(response.status).to  eq(401)
      expect(response.headers).to eq("Content-Length" => "12")
      expect(response.body).to    eq("Unauthorized")
    end

    it "doesn't mix with methods defined in other API apps" do
      expect { app.get("/no_method", lint: true) }.to raise_error(NameError, /method_that_should_be_mixed_in_the_other_api_instance/)
    end
  end
end
