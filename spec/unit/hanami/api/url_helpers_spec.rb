# frozen_string_literal: true

require "uri"

RSpec.describe Hanami::API do
  describe "URL helpers" do
    subject do
      Class.new(described_class) do
        get "/vinyls/:id", as: :vinyl do
          "hello world"
        end
      end.new
    end

    it "generates relative path" do
      expect(subject.path(:vinyl, id: 23)).to eq("/vinyls/23")
    end

    it "generates absolute path" do
      expect(subject.url(:vinyl, id: 23)).to eq(URI("http://localhost/vinyls/23"))
    end
  end
end
