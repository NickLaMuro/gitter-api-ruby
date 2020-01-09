module Gitter
  module API
    # Model representation of the +/user/*+ REST endpoints in the gitter API
    #
    class User < Base
      include Collectable

      # ID (from the API)
      attr_reader :id

      # Name of the user
      attr_reader :display_name

      # Username (minus the '@')
      attr_reader :username

      # The relative path the the user's page in the gitter webapp
      attr_reader :url

      # *INTERNAL* *METHOD*
      #
      # Initialize a new +Gitter::API::User+
      #
      # <tt>Gitter::API::Client#user</tt> will return on of these objects, as
      # well as some methods on +Gitter::API::Room+ and when instanciating a
      # +Gitter::API::Message+, so favor instanciating that way.
      #
      # ==== Parameters
      #
      # [*client* (Gitter::API::Client)] Configured client object
      # [*data* (Hash)]                  Initialization data
      #
      # ==== Options
      #
      # (string keys only)
      #
      # [*id* (String)]           User id
      # [*display_name* (String)] Gitter/GitHub user real name
      # [*username* (String)]     Gitter/GitHub username (without '@')
      # [*url* (String)]          Path to the user on Gitter
      #
      def initialize client, data
        super

        @id           = data["id"] || data["userId"]
        @display_name = data["displayName"]
        @username     = data["username"] || data["screenName"]
        @url          = data["url"]
      end

      # Fetch the all of the room records for a given user
      #
      # Includes one on one conversations, since those are considered "rooms"
      # as well (based on their schema)
      #
      # Returns a Gitter::API::Room::Collection
      def rooms
        data = client.get "#{api_prefix}/rooms"

        Room::Collection.new self, data
      end

      # +Gitter::API::User+ based methods that are available on any
      # +Gitter::API::Client+ instance
      module ClientMethods
        # Fetch the configured user
        #
        # Returns a Gitter::API::User instance
        def user refresh = false
          return @user unless @user.nil? || refresh

          data  = get "#{api_prefix}/user/me"
          @user = User.new self, data
        end
      end
    end
  end
end
