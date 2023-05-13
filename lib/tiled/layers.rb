module Tiled
  # Collection for layers storage. Just an array with indexing by name.
  class Layers < Array
    # Access layer by its name
    # @param name [String] name of layer
    # @return [Tiled::Layer, nil] Layer or nil if layer with this name doesn't exists.
    def [](name)
      if [String, Symbol].any? { |cls| name.is_a? cls }
        detect { |layer| layer.name == name.to_s }
      else
        super(name)
      end
    end

    alias add <<
  end
end
