module Gitter
  module API
    # Base model that other +Gitter::API+ models inherit from
    #
    # See:
    #
    # - +Gitter::API::Message+
    # - +Gitter::API::Room+
    # - +Gitter::API::User+
    #
    class Base
      # Configured client that fetched the record
      #
      # Used for subsequent calls (instance methods)
      #
      attr_reader :client

      # All models should call this in their overrides, and configure their
      # specific model attributes in the override from the +@data+ that was passed
      # in.
      #
      # Note: +@data+ is set, but is not a formal accessor.  Currently just
      # available for debugging if needed.
      #
      def initialize client, data # :nodoc:
        @client = client
        @data   = data
      end

      # Helper method for fetching the API prefix from the client
      #
      def api_prefix
        client.api_prefix
      end
    end
  end
end
