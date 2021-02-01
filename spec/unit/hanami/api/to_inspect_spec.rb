# frozen_string_literal: true

RSpec.describe Hanami::API do
  describe "#to_inspect" do
    context "without Rack middleware" do
      subject do
        Class.new(described_class) do
          root { "Hello, World!" }
        end.new
      end

      it "inspects defined routes" do
        expected = [
          "GET     /                             (block)                       as :root"
        ]

        actual = subject.to_inspect
        expected.each do |route|
          expect(actual).to include(route)
        end
      end
    end

    context "with Rack middleware" do
      subject do
        m = middleware

        Class.new(described_class) do
          use m
          root { "Hello, World!" }
        end.new
      end

      let(:middleware) do
        Class.new do
          def initialize(app)
            @app = app
          end

          def call(env)
          end
        end
      end

      it "inspects defined routes" do
        expected = [
          "GET     /                             (block)                       as :root"
        ]

        actual = subject.to_inspect
        expected.each do |route|
          expect(actual).to include(route)
        end
      end
    end
  end
end
