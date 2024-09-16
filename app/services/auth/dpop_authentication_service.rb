module Auth
  class DpopAuthenticationService < BaseService

    def initialize(current_user, personal_access_token_plaintext, request)
      # Raise errors if these are missing
      # Raise an error unless DpopToken.enabled_for_user?(current_user)
      # Raise if the PAT does not belong to the user or is inactive
      # Extract the raw DPoP token from the request header, and check there's only one header
      @user = current_user
      @request = request
      @personal_access_token_plaintext = personal_access_token_plaintext

      @dpop_token = extract_dpop_from_request(request)
    end

    def execute!
      # Create a DpopToken
      # Call unsafe_well_formed?. It will raise if there's an error.
      # Call valid_for_user_and_pat?(user, pat). It will raise if there's an error.

      dpop_token = DpopToken.new(@dpop_token)
      dpop_token.unsafe_well_formed?
      dpop_token.valid_for_user_and_pat?(@user, @personal_access_token_plaintext)

      true
    end

    private
    attr_reader :dpop_token

    def extract_dpop_from_request(request)
      # get the header value
      # raise if multiple, otherwise return it
      dpop_header_value = current_request.headers['dpop'].presence
      raise Gitlab::Auth::DpopValidationError, "No DPoP header in request" unless dpop_header_value

      return dpop_header_value if validate_header_count(dpop_header_value)

      raise Gitlab::Auth::DpopValidationError, "Only 1 DPoP header is allowed in request"
    end

    def validate_header_count(dpop_header_value)
      dpop_header_value.split(",").count == 1 && dpop_header_value.split(" ").count == 1
    end
  end
end
