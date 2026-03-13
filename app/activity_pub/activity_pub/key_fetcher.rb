require "net/http"
require "json"

module ActivityPub
  class KeyFetcher
    def self.fetch(key_id)
      new(key_id).fetch
    end

    def initialize(key_id)
      @key_id = key_id
      @actor_uri = key_id.split("#").first
    end

    def fetch
      # Check cache first
      remote_actor = RemoteActor.find_by(public_key_id: @key_id)
      return remote_actor if remote_actor&.public_key_pem.present?

      remote_actor = RemoteActor.find_by(actor_uri: @actor_uri)
      return remote_actor if remote_actor&.public_key_pem.present?

      # Fetch from remote
      fetch_remote_actor
    end

    private

    def fetch_remote_actor
      uri = URI.parse(@actor_uri)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        request["Accept"] = "application/activity+json"
        http.request(request)
      end

      return nil unless response.is_a?(Net::HTTPSuccess)

      json = JSON.parse(response.body)
      return nil unless json["publicKey"]

      domain = uri.host
      shared_inbox = json.dig("endpoints", "sharedInbox")

      remote_actor = RemoteActor.find_or_initialize_by(actor_uri: @actor_uri)
      remote_actor.update!(
        inbox_url: json["inbox"],
        shared_inbox_url: shared_inbox,
        preferred_username: json["preferredUsername"],
        display_name: json["name"],
        public_key_pem: json["publicKey"]["publicKeyPem"],
        public_key_id: json["publicKey"]["id"],
        domain: domain
      )

      # Track known server
      KnownServer.find_or_create_by!(domain: domain).tap do |server|
        server.update!(shared_inbox_url: shared_inbox, last_seen_at: Time.current)
      end

      remote_actor
    rescue StandardError
      nil
    end
  end
end
