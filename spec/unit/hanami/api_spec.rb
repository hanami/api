# frozen_string_literal: true

RSpec.describe Hanami::API do
  subject do
    Class.new(described_class) do
      get "/" do
        "hello world"
      end
    end.new
  end

  let(:app) { Rack::MockRequest.new(subject) }

  it "accepts a request" do
    response = app.get("/", lint: true)

    expect(response.body).to eq("hello world")
  end
end
