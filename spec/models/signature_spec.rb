require "rails_helper"

RSpec.describe "HTTP Signature", type: :model do
  let(:key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:key_id) { "https://example.com/users/test#main-key" }

  describe ActivityPub::Signer do
    it "generates valid signature headers for GET" do
      signer = ActivityPub::Signer.new(private_key: key, key_id: key_id)
      headers = signer.sign_request(method: "GET", url: "https://remote.example/users/alice")
      expect(headers["Signature"]).to be_present
      expect(headers["Date"]).to be_present
      expect(headers["Host"]).to eq("remote.example")
    end

    it "includes Digest for POST" do
      signer = ActivityPub::Signer.new(private_key: key, key_id: key_id)
      headers = signer.sign_request(method: "POST", url: "https://remote.example/inbox", body: '{"type":"Follow"}')
      expect(headers["Digest"]).to start_with("SHA-256=")
      expect(headers["Signature"]).to include("digest")
    end
  end

  describe ActivityPub::SignatureHeader do
    it "builds and parses signature header" do
      header = ActivityPub::SignatureHeader.build(
        key_id: key_id,
        algorithm: "rsa-sha256",
        headers: "(request-target) host date",
        signature: "abc123"
      )

      parsed = ActivityPub::SignatureHeader.parse(header)
      expect(parsed[:key_id]).to eq(key_id)
      expect(parsed[:algorithm]).to eq("rsa-sha256")
      expect(parsed[:signature]).to eq("abc123")
    end
  end
end
