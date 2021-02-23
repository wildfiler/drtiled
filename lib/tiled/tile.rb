module Tiled
  class Tile
    include Tiled::Serializable
    attr_reader :tileset, :attributes, :path, :tile_w, :tile_h, :tile_x, :tile_y, :id

    def initialize(tileset)
      @tileset = tileset
    end

    # TODO: Add terrain and animation support
    def from_xml_hash(hash)
      @attributes = Attributes.new(hash[:attributes])
      @path = tileset.image.path
      @id = attributes.id.to_i
      @tile_x, @tile_y, @tile_w, @tile_h = tileset.id_to_xywh(id)
      hash[:children].each do |child|
        case child[:name]
        when 'properties'
          properties.from_xml_hash(child[:children])
        end
      end
    end

    def init_empty(id)
      @attributes = Attributes.new({
        id: id,
      })
      @path = tileset.image.path
      @id = id
      @tile_x, @tile_y, @tile_w, @tile_h = tileset.id_to_xywh(id)
    end

    def properties
      @properties ||= Properties.new(self)
    end
  end
end
