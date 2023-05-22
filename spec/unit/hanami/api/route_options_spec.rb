RSpec.describe Hanami::API do
  describe "route options" do
    subject do
      Class.new(described_class) do
        get "/to",     to: ->(*) { [200, {"Content-Length" => "2"}, ["TO"]] }
        get "/as",     to: ->(*) { [200, {"Content-Length" => "2"}, ["AS"]] }, as: :named_route
        get "/co/:id", to: ->(*) { [200, {"Content-Length" => "11"}, ["CONSTRAINTS"]] }, id: /\d+/
        get "/blk" do
          "BLOCK"
        end
      end.new
    end

    it "accepts to:" do
      env = Rack::MockRequest.env_for("/to")
      status, headers, body = subject.call(env)

      expect(status).to eq(200)
      expect(headers).to eq("Content-Length" => "2")
      expect(body).to eq(["TO"])
    end

    it "accepts as:" do
      env = Rack::MockRequest.env_for("/as")
      status, headers, body = subject.call(env)

      expect(status).to eq(200)
      expect(headers).to eq("Content-Length" => "2")
      expect(body).to eq(["AS"])

      expect(subject.path(:named_route)).to eq("/as")
    end

    it "accepts **constraints" do
      env = Rack::MockRequest.env_for("/co/23")
      status, headers, body = subject.call(env)

      expect(status).to eq(200)
      expect(headers).to eq("Content-Length" => "11")
      expect(body).to eq(["CONSTRAINTS"])

      env = Rack::MockRequest.env_for("/co/xyz")
      status, = subject.call(env)

      expect(status).to eq(404)
    end

    it "accepts &blk" do
      env = Rack::MockRequest.env_for("/blk")
      status, _, body = subject.call(env)

      expect(status).to eq(200)
      expect(body).to eq(["BLOCK"])
    end
  end
end
