RSpec.describe Hanami::API do
  describe "#initialize" do
    let(:klass) do
      Class.new(described_class) do
        get "/" do
          "hello world"
        end
      end
    end

    subject { klass.new }

    it "returns a frozen instance of #{described_class}" do
      expect(subject).to be_kind_of(described_class)
      expect(subject).to be_frozen
    end

    # See https://github.com/hanami/api/issues/15
    it "can be initialized multiple times" do
      expect(klass.new).to be_kind_of(described_class)
      expect(klass.new).to be_kind_of(described_class)
    end
  end
end
