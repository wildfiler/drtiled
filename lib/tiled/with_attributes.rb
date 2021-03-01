module Tiled

  # This module add attributes method to class, and delegates methods to attributes object.
  #
  # @example
  #   class Player
  #     include Tiled::WithAttributes
  #
  #     def initialize(attr)
  #       attributes.add(attr)
  #     end
  #   end
  #
  #   player = Player.new(name: 'John', age: 35)
  #   player.name # => 'John'
  #
  # *Object* class has _id_ method and method_missing magic from *WithAttribute* for attributes like _id_ doesn't work.
  module WithAttributes
    def attributes
      @attributes ||= Attributes.new(attributes_default_hash)
    end

    def attributes_names
      self.class.attributes_names
    end

    def attributes_default_hash
      attributes_names.zip(Array(attributes_names.length)).to_h
    end

    # This module delegates methods to attributes instance, if attributes respond to such method.
    # @return Value
    def method_missing(name, *args)
      if attributes.respond_to?(name)
        attributes.send(name, *args)
      else
        super
      end
    end

    def respond_to_missing?(name, *)
      attributes.respond_to?(name) || super
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def attributes(*names)
        @attributes_names = names
      end

      def attributes_names
        @attributes_names ||= {}
      end
    end
  end
end
