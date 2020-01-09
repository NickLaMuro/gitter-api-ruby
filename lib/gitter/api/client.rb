require "json"

require 'gitter/api/util/net_http_client'

require 'gitter/api/config'
require 'gitter/api/collectable'

# models
require 'gitter/api/base'
require 'gitter/api/user'
require 'gitter/api/room'
require 'gitter/api/message'

module Gitter
  module API
    # The +Gitter::API::Client+ is the main http component, and is in charge of auth
    # and configuration of the base endpoint of the gitter API that is being
    # connected to and interacted with.
    #
    # == Usage
    #
    # === Client Setup
    #
    # In most cases, only a token is needed for the client instance:
    #
    #   client = Gitter::API::Client.new :token => "1a2b3c4d5e6f7a8b9c0d"
    #
    # === Example Queries
    #
    # Fetching the configured user:
    #
    #   client.user
    #   #=> #<Gitter::API::User:0x00007ff49b293c01 ... >
    #
    # Fetch rooms/private chats for the configured user:
    #
    #   client.rooms
    #   client.user.rooms # same as client.rooms, but is not memoized
    #   #=> #<Gitter::API::Room::Collection:0x00007ff49b293c02 ... >
    #
    # API Collections are Enumerable:
    #
    #   client.rooms.map(&:uri)
    #   #=> ["gitterHQ/sandbox", "gitterHQ/api"]
    #
    # See individual model classes for more examples
    #
    #
    # == Additional methods
    #
    # +Gitter::API::User+ and +Gitter::API::Room+ each provide methods that are
    # included in the client as base methods.  Refer to those classes for more
    # info.
    #
    class Client

      include Net::HTTP::RestClientModule

      include User::ClientMethods
      include Room::ClientMethods

      # See Gitter::API::Config#api_uri
      attr_reader :api_uri

      # See Gitter::API::Config#api_prefix
      attr_reader :api_prefix

      # Client User API token
      attr_reader :auth_token

      # See Gitter::API::Config#ssl_verify
      attr_reader :ssl_verify

      # Set for +Net::HTTP::RestClientModule+
      #
      alias uri api_uri # :nodoc:

      # Initialize a new +Gitter::API::Client+
      #
      # Aside from :token, all other options will be defaulted to what is
      # configured in +Gitter::API::Config+
      #
      # See +Gitter::API::Config+ for defaults.
      #
      # ==== Options
      #
      # (symbol keys only)
      #
      # [*:token* (String)]       (required) Auth token for the API client user
      #
      # [*:api_prefix* (String)]  Path prefix for all API routes
      # [*:api_uri* (URI)]        Endpoint URI of the configured gitter API
      # [*:ssl_verify* (Boolean)] Indicates if net/http should verify ssl certs
      #
      def initialize options = {}
        @api_prefix = options[:api_prefix] || Config.api_prefix
        @api_uri    = options[:api_uri]    || Config.api_uri
        @auth_token = options[:token]
        @ssl_verify = options.key? :ssl_verify ? options[:ssl_verify] : Config.ssl_verify
      end

      private

      # Override of the default in Net::HTTP::RestClientModule
      #
      def response_builder response
        JSON.parse response.body
      end

      # Override of the default in Net::HTTP::RestClientModule
      #
      def default_headers
        @headers ||= {
          "Accept"        => "application/json",
          "Content-Type"  => "application/json",
          "Authorization" => "Bearer #{auth_token}"
        }
      end
    end
  end
end
