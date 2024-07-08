# frozen_string_literal: true

RSpec.describe Hanami::API::Middleware::Stack do
  describe "#to_hash" do
    it "serializes to Hash" do
      subject = described_class.new("/")
      subject.use("/", "elapsed time")
      subject.use("/admin", "admin auth")
      subject.use("/api", "rate limiter", 4000)
      subject.use("/api/v1", "api v1 auth", "secret-token")
      subject.use("/api/v1", "api v1 deprecation", Date.today)
      subject.use("/api/v2", "api v2 auth")
      subject.use("/:locale", "set locale")
      subject.use("/:locale/it", "analytics", :it)

      actual = subject.to_hash
      expected = {
        "/" => [["elapsed time", [], {}, nil]],
        "/admin" => [["elapsed time", [], {}, nil], ["admin auth", [], {}, nil]],
        "/api" => [["elapsed time", [], {}, nil], ["rate limiter", [4000], {}, nil]],
        "/api/v1" => [["elapsed time", [], {}, nil], ["rate limiter", [4000], {}, nil], ["api v1 auth", ["secret-token"], {}, nil], ["api v1 deprecation", [Date.today], {}, nil]],
        "/api/v2" => [["elapsed time", [], {}, nil], ["rate limiter", [4000], {}, nil], ["api v2 auth", [], {}, nil]],
        "/:locale" => [["elapsed time", [], {}, nil], ["set locale", [], {}, nil]],
        "/:locale/it" => [["elapsed time", [], {}, nil], ["set locale", [], {}, nil], ["analytics", [:it], {}, nil]]
      }

      expect(actual).to eq(expected)
    end
  end
end
