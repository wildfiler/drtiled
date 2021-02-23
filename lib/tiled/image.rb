module Tiled
  class Image
    include Tiled::Serializable

    attr_reader :tileset, :attributes, :path, :w, :h

    def initialize(tileset)
      @tileset = tileset
    end

    def from_xml_hash(hash)
      @attributes = Attributes.new(hash[:attributes])
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
