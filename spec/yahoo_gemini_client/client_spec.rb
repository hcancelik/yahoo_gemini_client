require 'spec_helper'

module YahooGeminiClient
  describe Client do
    let(:consumer_key) { ENV["YAHOO_GEMINI_TEST_CONSUMER_KEY"] }
    let(:consumer_secret) { ENV["YAHOO_GEMINI_TEST_CONSUMER_SECRET"] }
    let(:refresh_token) { ENV["YAHOO_GEMINI_TEST_REFRESH_TOKEN"] }
    let(:expires_at) { Time.now + 200 }

    let(:client) do
      described_class.new(
        consumer_key: consumer_key,
        consumer_secret: consumer_secret,
      )
    end

    context "initialization" do
      it "initializes with consumer credentials" do
        expect(consumer_key).not_to be_empty
        expect(consumer_secret).not_to be_empty

        expect(client.consumer_key).to eq(consumer_key)
        expect(client.consumer_secret).to eq(consumer_secret)
      end

      let(:client) do
        described_class.new(
          consumer_key: consumer_key,
          consumer_secret: consumer_secret,
          refresh_token: refresh_token,
        )
      end

      it "initializes the oauth2 token" do
        expect(refresh_token).not_to be_empty
        expect(client.token.refresh_token).to eq refresh_token
      end
    end

    describe "#user_agent" do
      it "defaults YahooGeminiClientRubyGem/version" do
        expect(subject.user_agent).to eq("YahooGeminiClientRubyGem/#{YahooGeminiClient::VERSION}")
      end
    end

    describe "#authorization_url" do
      subject(:authorization_url) do
        described_class.new(
          consumer_key: "consumer_key",
          consumer_secret: "consumer_secret",
        ).authorization_url
      end

      it "returns Authorization URL to authorize API access" do
        require 'uri'
        parsed_url = ::URI.parse(authorization_url)
        expect(authorization_url).to match("https://api.login.yahoo.com/oauth2/request_auth")
        expect(parsed_url.host).to eq("api.login.yahoo.com")
        expect(parsed_url.path).to eq("/oauth2/request_auth")
        expect(parsed_url.query).to eq("client_id=consumer_key&language=en-us&redirect_uri=oob&response_type=code")
      end
    end

    describe "#get_token", :vcr =>  { :record => :once } do
      let(:client) do
        described_class.new(
          consumer_key: ENV["YAHOO_GEMINI_TEST_CONSUMER_KEY"],
          consumer_secret: ENV["YAHOO_GEMINI_TEST_CONSUMER_SECRET"],
        )
      end
      let(:authorization_code) { ENV["YAHOO_GEMINI_TEST_AUTHORIZATION_CODE"] }

    end

    context "#advertisers" do
      specify do
        expect(Advertisers).to receive(:new).with(client: client)
        client.advertisers
      end
    end

    context "#campaigns" do
      specify do
        expect(Campaigns).to receive(:new).with(client: client)
        client.campaigns
      end
    end

    context "#custom_reprt" do
      specify do
        expect(CustomReport).to receive(:new).with(client: client)
        client.custom_report
      end
    end
  end
end

