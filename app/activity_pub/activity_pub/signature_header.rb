module ActivityPub
  class SignatureHeader
    def self.build(key_id:, algorithm:, headers:, signature:)
      %(keyId="#{key_id}",algorithm="#{algorithm}",headers="#{headers}",signature="#{signature}")
    end

    def self.parse(header)
      return nil unless header

      params = {}
      header.scan(/(\w+)="([^"]*)"/) do |key, value|
        params[key] = value
      end

      return nil if params.empty?

      {
        key_id: params["keyId"],
        algorithm: params["algorithm"],
        headers: params["headers"],
        signature: params["signature"]
      }
    end
  end
end
