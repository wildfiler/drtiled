module Tiled
  class Attributes
    include Tiled::Serializable

    def initialize(hash)
      @attributes = hash
      hash.each do |key, value|
        instance_variable_set(:"@#{key}", value)
        define_singleton_method(key) { instance_variable_get(:"@#{key}") }
      end
    end

    def serialize
      @attributes.dup
    end
  end
end
