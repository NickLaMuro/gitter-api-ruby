module Gitter
  module API
    # Model representation of the +/room/:room_id/chatMessages*+ REST endpoints
    # in the gitter API
    #
    class Message < Base
      include Collectable

      # See Gitter::API::Collectable
      #
      def self.collectable_args parent, item_data # :nodoc:
        room_id = parent.respond_to? :room_id ? parent.room_id : nil

        [parent.client, room_id, item_data]
      end

      # Message id (from gitter)
      attr_reader :id

      # +Gitter::API::User+ that sent the message
      attr_reader :user

      # Original message in plain-text/markdown
      attr_reader :text

      # HTML formatted message (formatted on the API server)
      attr_reader :html

      # Indicates if the message has been read by the client user
      attr_reader :unread

      # Number of users that have read the message
      attr_reader :read_by

      # ISO formatted date of when the message originally sent
      attr_reader :created_at

      # ISO formatted data of when the message was edited last (if it has been)
      attr_reader :updated_at

      # List of +Gitter::API::User+ mentioned in the message
      attr_reader :mentions

      # List of github issues referened in the message
      attr_reader :issues

      # List of URLs present in the message
      attr_reader :urls

      # *INTERNAL* *METHOD*
      #
      # Initialize a new +Gitter::API::Message+
      #
      # Used by +Gitter::API::Room+ when fetching messages, so favor using that
      # instead.
      #
      # ==== Parameters
      #
      # *Note:*  messages in the Gitter schema don't have a `room_id`, so that
      # is passed in as an additional arg here.
      #
      # [*client* (Gitter::API::Client)] Configured client object
      # [*room_id* (String)]             Room ID message came from
      # [*data* (Hash)]                  Initialization data
      #
      # ==== Options
      #
      # (string keys only)
      #
      # [*id* (String)]            Message id
      # [*user* (String)]          +Gitter::API::User+ that sent the message
      # [*text* (String)]          Original message in plain-text/markdown
      # [*html* (String)]          HTML formatted message
      # [*unread* (Boolean)]       Indicates if current user has read the message
      # [*read_by* (Integer)]      Number of users that have read the message
      # [*created_at* (Date)]      ISO formatted date of the message
      # [*updated_at* (Date)]      ISO formatted date of the message if edited
      # [*mentions* (Array<User>)] +Gitter::API::User+(s) mentioned in message
      # [*issues* (Array<String>)] List of #Issues referenced in the message
      # [*urls* (Array<String>)]   List of URLs present in message
      #
      def initialize client, room_id, data
        super client, data

        @room_id    = room_id

        @id         = data["id"]
        @user       = User.new client, data["fromUser"]
        @text       = data["text"]
        @html       = data["html"]
        @unread     = data["unread"]

        @read_by    = data["readBy"]
        @created_at = data["sent"]
        @updated_at = data["editedAt"]

        @mentions   = data["mentions"].map { |user| User.new client, user }
        @issues     = data["issues"]
        @urls       = data["urls"]
      end

      # Edit/update a Message's text
      #
      # The html will be reformated on the server, and returned as part of the
      # +data+ when returned.
      #
      # A new instance of Gitter::API::Message is the turn value
      #
      # :return: Gitter::API::Message
      #
      # ==== Parameters
      #
      # [*text* (String)] New text to update the message record to
      #
      def update text
        payload = { "text" => message }.to_json
        data    = client.post "#{api_prefix}/rooms/#{room_id}/chatMessages/#{id}", payload

        new client, room_id, data
      end

      # Mark the message as read for the client user
      #
      # :return: true
      #
      def mark_as_read
        payload = { "chat" => [id] }.to_json
        path    = "/#{api_prefix}/user/#{client.user.id}/rooms/#{room_id}/unreadItems"

        client.post path, payload

        true
      end
    end
  end
end
