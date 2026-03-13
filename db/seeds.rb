require "openssl"
require "dotenv"

Dotenv.load(".env") 

return if Account.exists?

# Generate RSA key pair
key = OpenSSL::PKey::RSA.generate(2048)

username = ENV["TSUZURI_USERNAME"]
base_url = ENV.fetch("TSUZURI_BASE_URL", "http://localhost:3000")
activity_pub_url = username ? "#{base_url}/users/#{username}" : "#{base_url}/users/pending"

account = Account.create!(
  email: ENV.fetch("TSUZURI_EMAIL", "admin@example.com"),
  password_hash: BCrypt::Password.create(ENV.fetch("TSUZURI_PASSWORD", "password")),
  status: "verified",
  username: username,
  display_name: username || "Tsuzuri User",
  summary: "A Tsuzuri blog",
  private_key_pem: key.to_pem,
  public_key_pem: key.public_key.to_pem,
  activity_pub_url: activity_pub_url
)

puts "Created account: #{account.email} (username: #{account.username || 'pending setup'})"
