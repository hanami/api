RSpec.describe Hanami::API do
  describe "Streamed Response" do
    let(:app) do
      Rack::Lint.new(
        Rack::Chunked.new(api)
      )
    end

    let(:api) do
      Class.new(described_class) do
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
      end.new
    end

    it "returns streamed response (text, enumerator)" do
      response = streamed_request("/stream/data")

      expect(response.status).to be(200)
      expect(response.headers.key?("Content-Length")).to be(false)
      expect(response.headers).to eq({"Transfer-Encoding" => "chunked"})
      expect(response.body).to eq("1\r\na\r\n1\r\nb\r\n1\r\nc\r\n0\r\n\r\n")
    end

    it "returns streamed response (text, to_enum)" do
      response = streamed_request("/stream/to_enum")

      expect(response.status).to be(200)
      expect(response.headers.key?("Content-Length")).to be(false)
      expect(response.headers).to eq({"Transfer-Encoding" => "chunked"})
      expect(response.body).to eq("1\r\na\r\n1\r\nb\r\n1\r\nc\r\n0\r\n\r\n")
    end

    it "returns streamed response (json)" do
      response = streamed_request("/stream/json")

      expect(response.status).to be(200)
      expect(response.headers.key?("Content-Length")).to be(false)
      expect(response.headers).to eq({"Content-Type" => "application/json", "Transfer-Encoding" => "chunked"})
      expect(response.body).to eq("1\r\n[\r\n3\r\n\"a\"\r\n1\r\n,\r\n3\r\n\"b\"\r\n1\r\n,\r\n3\r\n\"c\"\r\n1\r\n]\r\n0\r\n\r\n")
    end
  end

  private

  def streamed_request(path)
    # Only HTTP/1.1 allows streamed responses
    env = Rack::MockRequest.env_for(path, "SERVER_PROTOCOL" => "HTTP/1.1", "REQUEST_METHOD" => "GET")
    Rack::MockResponse.new(*app.call(env))
  end
end
