module Tiled
  class Attributes
    include Tiled::Serializable

    def initialize(hash)
      hash.each do |key, value|
        instance_variable_set(:"@#{key}", value)
        define_singleton_method(key) { instance_variable_get(:"@#{key}") }
      end
    end

    def add(hash)
      hash.each do |key, value|
        instance_variable_set(:"@#{key}", value)
        define_singleton_method(key) { instance_variable_get(:"@#{key}") } unless respond_to? key
      end
    end
  end
end
