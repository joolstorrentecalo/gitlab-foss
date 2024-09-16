# Demonstrated Proof of Possession (DPoP) is a mechanism to tie a user's
# Personal Access Token (PAT) to one of their signing keys.
#
# A DPoP Token is a signed JSON Web Token, and this class implements
# the logic to ensure a provided DPoP Token is well-formed and
# cryptographically signed.
#
# In this class:
#   - well-formed is defined as being a syntatically correct JWT that is
#   using supported values (e.g. supported algorithms).
#   - valid is defined as being cryptographically signed with a user's
#   active signing key. A user may have many active signing key's; it
#   must match one.
#
# All checks MUST raise an error if they fail:
#  - JWT errors will use JWT error classes & message (don't catch & re-raise)
#  - DPoP specific errors will use a DPoP error class
module Gitlab
  module Auth
    class DpopToken
      SUPPORTED_JWS_ALGORITHMS = ['RS256']
      SUPPORTED_TYPES = ['dpop+jwt']
      SUPPORTED_KEY_TYPES = ['RSA']
      SUPPORTED_PROOF_KEY_ID_HASHING_ALGORITHMS = ['SHA256']
      KID_DELIMETER = ':'

      def self.dpop_enabled_for_user?(user)
        # Check the user has enabled DPoP
        # Return true / false
        return Feature.enabled?(:dpop_authentication, user) && user.dpop_enabled
      end

      def initialize(dpop_token)
        @dpop_token = dpop_token
        raise ArgumentError unless dpop_token.present

        @payload, @header = JWT.decode(
          dpop_token,
          nil,   # we do not pass a key here as we are not checking the signature
          false, # we are not verifying the signature or claims
          )
      rescue JWT::DecodeError => decode_error
        raise Gitlab::Auth::DpopValidationError, "Malformed JWT, unable to decode. #{decode_error.message}"
      end

      # well-formed DOES NOT equal valid.
      def unsafe_well_formed?
        well_formed_header?
      end

      def valid_for_user_and_pat?(user, plaintext)
        valid_for_user?(user)
        valid_access_token_hash_for?(plaintext)
      end

      # The methods below are public but (currently) only used by DpopToken
      # itself. It's easier to test

      # A user's public key is prefixed with its algorithm. This method
      # should return that algorithm, or raise if it can't.
      def algorithm_from_users_public_key(key)
        algorithm = key.split(" ").first

        if algorithm.nil? || algorithm.empty?
          raise Gitlab::Auth::DpopValidationError, "Unable to extract algorithm from the public key"
        end

        return algorithm
      end

      private
      attr_reader :dpop_token, :header, :payload

      # Check that the DPoP is signed with a SSH key belonging to the user
      def valid_for_user?(user)
        raise unless self.dpop_enabled_for_user?(user)
        raise unless unsafe_well_formed?

        user_public_key = signing_key_for_user!(user)

        algorithm = algorithm_for_dpop_validation(user_public_key)
        openssh_public_key = convert_public_key_to_openssh_key(user_public_key)

        # Decode the JSON token again, this time with the key,
        # the expected algorthm, verifying all the timestamps, etc
        # Overwrites the attrs, in case .decode returns a different result
        # when verify is true.
        @payload, @header = JWT.decode(
          dpop_token,
          openssh_public_key,
          true,
          {
            required_claims: %w[exp ath iat],
            algorithm: algorithm,
            verify_iat: true,
            # ...
          }
        )

        validate_public_key_in_jwk!(openssh_public_key, header)

        raise Gitlab::Auth::DpopValidationError, "Unable to decode JWT" if payload.nil? || header.nil?

      rescue JWT::ExpiredSignature
        raise Gitlab::Auth::DpopValidationError, "Signature expired"
      rescue JWT::InvalidIatError
        raise Gitlab::Auth::DpopValidationError, "Invalid IAT value"
      rescue JWT::MissingRequiredClaim => decode_error
        raise Gitlab::Auth::DpopValidationError, decode_error.message
      rescue StandardError => decode_error
        raise Gitlab::Auth::DpopValidationError, "Unable to decode JWT. #{decode_error.message}"
      end

      def kid_fingerprint
        # Get a fingerprint from the header. We already checked the
        # algorithm in well_formed_header?
        return header["kid"]&.delete_prefix("SHA256:")
      end

      def valid_kid?
        # Check the format of header[kid] (ALGORITHM DELIMITER b64(HASH))
        kid_parts = header["kid"].split(KID_DELIMETER)
        raise Gitlab::Auth::DpopValidationError, "Malformed fingerprint value in kid" unless kid_parts.size == 2

        # Check kid_algorithm is supported
        kid_algorithm = kid_parts[0]
        raise Gitlab::Auth::DpopValidationError, "Unsupported fingerprint algorithm in kid" unless kid_algorithm.casecmp?('SHA256')
      end

      # A DPoP Token has a header containing metadata
      def well_formed_header?
        # All comparisons should be case-sensitive, using secure comparison
        # See https://www.rfc-editor.org/rfc/rfc7515#section-4.1.1

        # Check header[typ] and header[kid]
        raise Gitlab::Auth::DpopValidationError, "Invalid typ value in JWT" unless header.casecmp?('dpop+jwt')
        raise Gitlab::Auth::DpopValidationError, "No kid in JWT, unable to fetch key" if header["kid"].nil?

        # Check header[alg] is one of SUPPORTED_JWS_ALGORITHMS.
        # Remove when support for ED25519 is added
        # This checks for 'alg' in the header and exits early
        unless algorithm.casecmp?('RS512')
          raise Gitlab::Auth::DpopValidationError,
                "Currently only RSA keys are supported"
        end

        valid_kid?
        valid_jwk_kty?(header)
      end

      def signing_key_for_user!(user)
        # Gets a signing key from the user based on the fingerprint.
        fingerprint = kid_fingerprint

        key = user.keys.signing.find_by_fingerprint_sha256(fingerprint)&.key
        raise Gitlab::Auth::DpopValidationError, "No matching key found" unless key

        # Validate the signing key uses a supported algorithm.
        algorithm = algorithm_from_users_public_key(key)

        return unless algorithm.casecmp?('ssh-rsa')
        raise Gitlab::Auth::DpopValidationError, "Currently only RSA keys are supported"

        return key
      end

      # Check that the DPoP contains a hash of the PAT being used.
      # Users can have multiple PATs, so we still need to check that
      # they created this DPoP for this particular PAT.
      def valid_access_token_hash_for?(plaintext)
        expected_hash = Base64.urlsafe_encode64(
          Digest::SHA256.digest(plaintext),
          padding: false
        )
        raise Gitlab::Auth::DpopValidationError, "Incorrect access token hash in JWT" unless secure_compare(payload['ath'], expected_hash)
      end

      def convert_public_key_to_openssh_key(key)
        SSHData::PublicKey.parse_openssh(key).openssl
      rescue SSHData::DecodeError => decode_error
        raise Gitlab::Auth::DpopValidationError, "Unable to parse public key. #{decode_error.message}"
      end

      # Fings the algorithm from the public key to decode the JWT in
      # valid_for_user?
      def algorithm_for_dpop_validation(key)
        SUPPORTED_ALGOS.each do |key_algorithm, jwt_algorithm|
          return jwt_algorithm if key.start_with?(key_algorithm)
        end

        nil
      end

      def valid_jwk_kty?(header)
        jwk = header["jwk"]
        raise Gitlab::Auth::DpopValidationError, "Failed to parse JWK" if jwk.nil?

        kty = jwk["kty"]
        raise Gitlab::Auth::DpopValidationError, "No key type in JWK" if kty.nil?
        raise Gitlab::Auth::DpopValidationError, "Unknown algorithm in JWK" unless kty == "RSA"
      end

      def validate_public_key_in_jwk!(openssh_public_key, header)
        jwk = header["jwk"]
        raise Gitlab::Auth::DpopValidationError, "Failed to parse JWK" if jwk.nil?

        return if openssh_public_key.to_s == OpenSSL::PKey.read(JWT::JWK::RSA.import(jwk).public_key.to_pem).to_s

        raise Gitlab::Auth::DpopValidationError, "Failed to parse JWK"
      end

    end
  end
end
