# frozen_string_literal: true

RSpec.describe "Hanami::API::VERSION" do
  it "returns version" do
    expect(Hanami::API::VERSION).to eq("0.3.0")
  end
end
