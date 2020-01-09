module Gitter
  module API
    # = Gitter::API::Collectable
    #
    # This is a support module for Gitter::API models that allows for defining
    # a subclass based on the included class that is a Enumberable collection
    # of base class, in a similar vein to how ActiveRecord::Relation is used to
    # represent a collection of ActiveRecord objects.
    #
    # Allows for initializing on a shared interface where only the +parent+ and
    # +data+ blob (array of hash data objects for the given base record) need
    # to be passed in.
    #
    # For models that have different initialization argument schema (e.g.
    # Gitter::API::Message), this collectable_args can be defined on the
    # included class that will override the args passed to +.new+ when
    # instanciating each record in the collection.
    #
    # == Example Usage
    #
    # For Gitter::API::User, this is pretty straight forward:
    #
    #   class Gitter::API::User
    #     include Collectable
    #   end
    #
    # But for Gitter::API::Message, since +room_id+ needs to be supplied for
    # that class, it has `collectable_args` defined to support that when
    # instanciating the collection.
    #
    #   class Gitter::API::Message
    #     include Collectable
    #
    #     def self.collectable_args parent, item_data # :nodoc:
    #       room_id = parent.respond_to? :room_id ? parent.room_id : nil
    #       [parent.client, room_id, item_data]
    #     end
    #   end
    #
    # So when each message is created it will receive +client+, +room_id+, and
    # +data+ as arguments for each object instanciated instead of the default
    # +client+ and +data+ only.
    #
    module Collectable # :nodoc: all

      # Defines the following on the newly created sub class
      #
      # - .base_class
      # - .initialize (new)
      # - #collectable_args (used in initialize)
      # - #each
      # - #last
      # - #parent (used in collectable_args)
      #
      def self.included base_class
        collection_class = Class.new
        collection_class.send :include, Enumerable
        collection_class.instance_variable_set :@base_class, base_class

        collection_class.module_eval <<-CLASS
          def self.base_class
            @base_class
          end

          def initialize parent, data
            @parent = parent
            @items  = data.map do |item_data|
                        self.class.base_class.new *(collectable_args item_data)
                      end
          end

          def collectable_args item_data
            if self.class.base_class.respond_to? :collectable_args
              self.class.base_class.collectable_args parent, item_data
            else
              [parent.client, item_data]
            end
          end

          def each
            @items.each { |item| yield item }
          end

          def last
            @items.last
          end

          def parent
            @parent
          end
        CLASS

        base_class.const_set :Collection, collection_class
      end
    end
  end
end
