module Tsuzuri
  mattr_accessor :base_url, :domain, :source_url

  self.base_url = ENV.fetch("TSUZURI_BASE_URL", "http://localhost:3000")
  self.domain = ENV.fetch("TSUZURI_DOMAIN", "localhost")
  self.source_url = ENV.fetch("TSUZURI_SOURCE_URL", "https://github.com/S-H-GAMELINKS/tsuzuri")

  def self.account
    Account.first
  end

  def self.username
    account&.username
  end
end
