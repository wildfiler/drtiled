module Tiled
  class Layers
    # Collection for layers storage. Just an array with indexing by name.

    include Enumerable

    def initialize
      @layers = []
    end

    # Access layer by its name
    # @param name [String] name of layer
    # @return [Tiled::Layer, nil] Layer or nil if layer with this name doesn't exists.
    def [](name)
      @layers_indexes ||= {}
      @layers_indexes[name] ||= @layers.detect { |layer| layer.name == name}
    end

    # Access layer by its index
    # @param index [Integer] layer index
    # @return [Tiled::Layer, nil]
    def at(index)
      @layers[index]
    end

    # Add layer
    # @param layer [Tiled::Layer] add layer to collection
    # @return [Tiled::Layers] self
    def add(layer)
      @layers << layer
      self
    end

    def last
      @layers.last
    end

    # Delegate each to internal array to implement Enumerable interface.
    def each(&block)
      @layers.each(&block)
    end
  end
end
