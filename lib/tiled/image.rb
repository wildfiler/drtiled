module Tiled
  class Image
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :tileset, :path, :w, :h

    attributes :source, :trans, :width, :height

    def initialize(tileset)
      @tileset = tileset
    end

    def from_xml_hash(hash)
      attributes.add(hash[:attributes])
      @path = Utils.relative_to_absolute(File.join(File.dirname(map.path), attributes.source))
      @h = attributes.height
      @w = attributes.width
    end

    def map
      tileset.map
    end

    def exclude_from_serialize
      super + %w[tileset]
    end
  end
end
