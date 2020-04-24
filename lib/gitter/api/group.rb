module Gitter
  module API
    # Model representation of the +/group/*+ REST endpoints in the gitter API
    #
    class Group < Base
      include Collectable

      # Base avatar URL
      attr_reader :avatar_url

      # "backedBy" is a security descriptor. Describes the backing object we
      # get permissions from.

      # Security descriptor type [null|'ONE_TO_ONE'|'GH_REPO'|'GH_ORG'|'GH_USER']
      attr_reader :backed_by_type

      # Represents how we find the backing object given the type
      attr_reader :backed_by_linked_path

      # ID (from the API)
      attr_reader :id

      # Name of the group
      attr_reader :name

      # The relative path the the user's page in the gitter webapp
      attr_reader :uri

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

        @avatar_url            = data["avatarUrl"]
        @backed_by_type        = data["backedBy"] && data["backedBy"]["type"]
        @backed_by_linked_path = data["backedBy"] && data["backedBy"]["type"]
        @id                    = data["id"]
        @name                  = data["name"]
        @uri                   = data["uri"]
      end

      # Fetch the all of the room records for a given group
      #
      # Returns a Gitter::API::Room::Collection
      def rooms
        data = client.get "#{api_prefix}/groups/#{id}/rooms"

        Room::Collection.new self, data
      end

      # +Gitter::API::Group+ based methods that are available on any
      # +Gitter::API::Client+ instance
      module ClientMethods
        # Fetch all groups for the configured user
        #
        # Returns a Gitter::API::Group::Collection instance
        def groups refresh = false
          return @groups unless @groups.nil? || refresh

          data    = get "#{api_prefix}/groups"
          @groups = Group::Collection.new self.user, data
        end
      end
    end
  end
end
