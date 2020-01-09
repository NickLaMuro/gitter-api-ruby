module Gitter
  module API
    # A singleton class for holding on to default values for the
    # Gitter::API::Client for the given session.
    #
    # When making changes here, it will affect every Gitter::API::Client that
    # is configured going forward, unless the values are changed on client
    # instanciation via the config hash.
    #
    # == Tunable attributes
    #
    # - +api_prefix+
    # - +api_url+
    # - +ssl_verify+
    #
    #
    class Config
      # API prefix for production https://api.gitter.im ("/v1")
      DEFAULT_API_PREFIX = "/v1"

      # Default API URL ("https://api.gitter.im")
      DEFAULT_API_URL    = "https://api.gitter.im"

      class << self
        # Path prefix for API routes
        #
        # Generally in development (localhost), "/api/v1" should be used instead
        # of the default ("/v1")
        attr_accessor :api_prefix

        # Endpoint URL for the Gitter API
        attr_accessor :api_url

        # Whether or not to verify SSL certs (default is +true+)
        #
        # Set to +false+ when using +localhost+ (development) since a local
        # server most likely will not have valid https certs
        attr_accessor :ssl_verify

        # :doc:
        # The prefix for the API endpoints (default: +/v1+)
        #
        # In development using a local gitter instance, it should be +/api/v1+,
        # but in production it is just +/v1+
        def api_prefix
          @api_url || DEFAULT_API_PREFIX
        end

        # :doc:
        # Endpoint URL for the Gitter API (default: "https://api.gitter.im")
        #
        # For local instances of +gitter-webapp+, the URL can then be set to
        # +http://localhost:5000+.
        #
        def api_url
          @api_url || DEFAULT_API_URL
        end

        # :doc:
        # Reset the reference for @api_url
        #
        # Also clears the cache for +@api_uri+
        #
        def api_url= url
          @api_url = url
          @api_uri = nil # clear @api_uri cache when @api_url is set
        end

        # :doc:
        # URI object cache of the api_url
        #
        def api_uri
          @api_uri ||= URI(api_url)
        end

        # :doc:
        # If the base endpoint should verify SSL cert (default: true)
        #
        def ssl_verify
          @ssl_verify || true
        end
      end
    end
  end
end
