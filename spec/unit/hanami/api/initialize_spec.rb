# frozen_string_literal: true

RSpec.describe Hanami::API do
  describe "#initialize" do
    subject do
      Class.new(described_class) do
        get "/" do
          "hello world"
        end
      end.new
    end

    it "returns a frozen instance of #{described_class}" do
      expect(subject).to be_kind_of(described_class)
      expect(subject).to be_frozen
    end
  end
end
