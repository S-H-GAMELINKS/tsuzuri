module ActivityPub
  module HttpSignature
    ALGORITHM = "rsa-sha256"
    CLOCK_SKEW = 300 # seconds
    DIGEST_ALGORITHM = "SHA-256"
  end
end
