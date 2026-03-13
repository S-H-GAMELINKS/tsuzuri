FactoryBot.define do
  factory :remote_actor do
    sequence(:actor_uri) { |n| "https://remote#{n}.example/users/actor#{n}" }
    sequence(:inbox_url) { |n| "https://remote#{n}.example/users/actor#{n}/inbox" }
    shared_inbox_url { nil }
    preferred_username { "remote_user" }
    display_name { "Remote User" }
    domain { URI.parse(actor_uri).host }
    public_key_pem { OpenSSL::PKey::RSA.generate(2048).public_key.to_pem }
    public_key_id { "#{actor_uri}#main-key" }
  end
end
