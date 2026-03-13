namespace :tsuzuri do
  desc "Generate RSA key pair for ActivityPub HTTP Signatures"
  task generate_keys: :environment do
    require "openssl"

    key_dir = Rails.root.join("config/keys")
    FileUtils.mkdir_p(key_dir)

    key = OpenSSL::PKey::RSA.generate(2048)

    private_path = key_dir.join("private.pem")
    public_path = key_dir.join("public.pem")

    File.write(private_path, key.to_pem)
    File.write(public_path, key.public_key.to_pem)

    puts "Generated RSA key pair:"
    puts "  Private: #{private_path}"
    puts "  Public:  #{public_path}"
  end
end
