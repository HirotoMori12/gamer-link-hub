require "ed25519"

module Discord
  class SignatureVerifier
    def initialize(public_key: ENV["DISCORD_PUBLIC_KEY"])
      @public_key = public_key
    end

    def verify(signature:, timestamp:, body:)
      return false if @public_key.blank? || signature.blank? || timestamp.blank?

      verify_key = Ed25519::VerifyKey.new([@public_key].pack("H*"))
      message = timestamp + body
      verify_key.verify([signature].pack("H*"), message)
    rescue Ed25519::VerifyError, ArgumentError => e
      Rails.logger.error "Signature verification failed: #{e.message}"
      false
    end
  end
end
