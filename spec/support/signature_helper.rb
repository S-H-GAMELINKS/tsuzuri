module SignatureHelper
  def sign_request(method:, url:, body: nil, private_key:, key_id:)
    signer = ActivityPub::Signer.new(private_key: private_key, key_id: key_id)
    signer.sign_request(method: method, url: url, body: body)
  end
end

RSpec.configure do |config|
  config.include SignatureHelper
end
