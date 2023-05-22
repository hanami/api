RSpec.describe Hanami::API do
  describe "redirect" do
    subject do
      Class.new(described_class) do
        get "/" do
          "home"
        end

        redirect("/dashboard", to: "/")
        redirect("/temporary", to: "/", code: 302)
        redirect("/as",        to: "/", as: :named)
      end.new
    end

    it "redirects to destination" do
      env = Rack::MockRequest.env_for("/dashboard")
      status, headers, body = subject.call(env)

      expect(status).to eq(301)
      expect(headers).to eq("Location" => "/")
      expect(body).to eq(["Moved Permanently"])
    end

    it "accepts a custom HTTP code" do
      env = Rack::MockRequest.env_for("/temporary")
      status, headers, body = subject.call(env)

      expect(status).to eq(302)
      expect(headers).to eq("Location" => "/")
      expect(body).to eq(["Found"])
    end

    it "accepts as:" do
      expect(subject.path(:named)).to eq("/as")
    end
  end
end
