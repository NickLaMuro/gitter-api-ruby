module Gitter
  module API
    # Model representation of the +/room/:room_id/*+ REST endpoints in the
    # gitter API
    #
    class Room < Base
      include Collectable

      # Room id
      attr_reader :id

      # Room name
      attr_reader :name

      # Room topic
      attr_reader :topic

      # Indicates if the room is a one on one chat
      attr_reader :one_on_one

      # Indicates if the room is configured with notifications for the user
      attr_reader :lurk

      # Indicates if the room is public
      attr_reader :public

      # Number of unread mentions for this room
      attr_reader :mentions

      # Number of users in the room
      attr_reader :user_count

      # Number of unread messages for this room
      attr_reader :unread_items

      # Array of tags for the room
      attr_reader :tags

      # Room URI on gitter
      attr_reader :uri

      # Room url
      attr_reader :url

      # Used by Collectable
      alias room_id id # :nodoc:

      # Find a room given a URI
      #
      # See Gitter::API::Room::ClientMethods#find_room
      #
      # ==== Parameters
      #
      # [*uri* (String)] Room URI on Gitter
      #
      # ==== Example
      #
      #   client.find "gitterhq/sandbox"
      #   #=> <#Gitter::API::Room name="gitterhq/sandbox" ...>
      #
      # :return: Gitter::API::Room
      #
      def self.find uri
        Client.find_room uri
      end

      # *INTERNAL* *METHOD*
      #
      # Initialize a new Gitter::API::Room
      #
      # Use Gitter::API::Room::ClientMethods (found of Gitter::API::Client) to
      # initialize and make use of the instance methods.
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
      # [*id* (String)]            Room id
      # [*name* (String)]          Room name
      # [*topic* (String)]         Room topic
      # [*one_on_one* (Boolean)]   Indicates if one on one chat
      # [*lurk* (Boolean)]         Indicates if notifications disabled
      # [*public* (Boolean)]       Indicates if public room
      # [*unread_items* (Integer)] Number of unread messages
      # [*mentions* (Integer)]     Number of unread mentions
      # [*user_count* (Integer)]   Number of users in the room
      # [*tags* (Array<String>)]   Tags that define the room
      # [*uri* (String)]           Room URI on Gitter
      # [*url* (String)]           Path to the room on gitter
      #
      def initialize client, data
        super

        @id           = data["id"]
        @name         = data["name"]
        @topic        = data["topic"]
        @one_on_one   = data["oneOnOne"]
        @lurk         = data["lurk"]
        @public       = data["public"]
        @mentions     = data["mentions"]
        @user_count   = data["userCount"]
        @unread_items = data["unreadItems"]
        @tags         = data["tags"]
        @uri          = data["uri"]
        @url          = data["url"]
      end

      # List users of a room
      #
      # ==== Options
      #
      # [*:search* (String)]  Filter based on search query
      # [*:limit* (Integer)]  Limit number of records returned
      # [*:skip* (Integer)]   Return users after skiping N records
      #
      # :return: Gitter::API::User::Collection
      #
      def users options = {}
        query = {
          "skip"     => options[:skip],
          "limit"    => options[:limit],
          "q"        => options[:search]
        }

        data = client.get "/#{api_prefix}/rooms/#{id}/users", query

        User::Collection.new self, data
      end

      # List recent messages of a room
      #
      # ==== Options
      #
      # [*:search* (String)]  Filter based on search query
      # [*:before* (String)]  Limit messages to before a date
      # [*:after* (String)]   Limit messages to after a date
      # [*:around* (String)]  Limit messages to around a date
      # [*:limit* (Integer)]  Limit number of records returned
      # [*:skip* (Integer)]   Return users after skiping N records
      #
      # Returns a collection of most recent messages, with the oldest of that
      # collection being first in the returned list.
      #
      # :return: Gitter::API::User::Collection
      #
      def messages options = {}
        query = {
          "skip"     => options[:skip],
          "beforeId" => options[:before],
          "afterId"  => options[:after],
          "aroundId" => options[:around],
          "limit"    => options[:limit],
          "q"        => options[:search]
        }

        data = client.get "/v1/rooms/#{id}/chatMessages", query

        Message::Collection.new self, data
      end

      # Join the current room
      #
      # :return: Gitter::API::Room
      #
      def join
        payload = { "id" => id }.to_json
        data    = client.post "#{api_prefix}/user/#{client.user.id}/rooms", payload

        self
      end

      # Send a message to the current room
      #
      # ==== Parameters
      #
      # [*message* (String)] Message to send to the room
      #
      # Messages should be in plain text/mardown format, and will be converted
      # to html on the server side.
      #
      # :return: Gitter::API::Message
      #
      def send_message message
        payload = { "text" => message }.to_json
        data    = client.post "#{api_prefix}/rooms/#{id}/chatMessages", payload

        Message.new client, id, data
      end

      # Unread messages in the room for the current user
      #
      # :return: Gitter::API::Message::Collection
      #
      def unread_messages
        data = client.get "#{api_prefix}/user/#{client.user.id}/rooms/#{id}/unreadItems"

        Message::Collection.new self, data
      end

      # +Gitter::API::Room+ based methods that are available on any
      # +Gitter::API::Client+ instance
      #
      module ClientMethods
        # Memoized version of User#rooms for the api client user
        #
        # ==== Parameters
        #
        # [*refresh* (Boolean)] set to true refresh memoization
        #
        # :return: Gitter::API::Room::Collection
        #
        def rooms refresh = false
          return @rooms unless @rooms.nil? || refresh

          @rooms = user.rooms
        end

        # Find a room based off of uri
        #
        # ==== Parameters
        #
        # [*uri* (String)] Room URI on Gitter
        #
        # ==== Example
        #
        #   client.join_room "gitterhq/sandbox"
        #   #=> <#Gitter::API::Room name="gitterhq/sandbox" ...>
        #
        # :return: Gitter::API::Room
        #
        def find_room uri
          payload =  { "uri" => uri }.to_json
          data    = self.post "#{api_prefix}/rooms", payload

          Room.new(self, data)
        end

        # Join a room from the top level client using the api user
        #
        # ==== Parameters
        #
        # [*uri* (String)] Room URI on Gitter
        #
        # ==== Example
        #
        #   client.join_room "gitterhq/sandbox"
        #   #=> <#Gitter::API::Room name="gitterhq/sandbox" ...>
        #
        # :return: Gitter::API::Room
        #
        def join_room uri
          has_room = rooms.detect { |room| room.uri == uri }

          return has_room if has_room

          @rooms = nil # clear rooms cache
          self.class.find_room(uri).join
        end
      end
    end
  end
end
