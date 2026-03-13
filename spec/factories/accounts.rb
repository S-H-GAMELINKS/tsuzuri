FactoryBot.define do
  factory :account do
    sequence(:email) { |n| "user#{n}@example.com" }
    password_hash { BCrypt::Password.create("password123") }
    status { "verified" }
    username { "testuser" }
    display_name { "Test User" }
    summary { "A test blog" }
    private_key_pem { OpenSSL::PKey::RSA.generate(2048).to_pem }
    public_key_pem { OpenSSL::PKey::RSA.new(private_key_pem).public_key.to_pem }
    activity_pub_url { "#{Tsuzuri.base_url}/users/#{username}" }
  end
end
