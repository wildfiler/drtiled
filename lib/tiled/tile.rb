module Tiled
  class Tile
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :tileset, :path, :tile_w, :tile_h, :tile_x, :tile_y
    attributes :id, :type, :terrain, :probability

    def initialize(tileset)
      @tileset = tileset
    end

    # TODO: Add terrain and animation support
    def from_xml_hash(hash)
      attributes.add(hash[:attributes])
      if tileset.image
        @path = tileset.image.path
        @tile_x, @tile_y, @tile_w, @tile_h = tileset.id_to_xywh(id.to_i)
      else
        # Tileset doesn't have an image but is made of individual images; we can process those directly
        image_attributes = hash[:children].select do |item|
          item[:name] == "image"
        end.first
        img = Tiled::Image.new(tileset)
        img.from_xml_hash(image_attributes)
        @path = img.path
        @tile_x = 0
        @tile_y = 0
        @tile_w = img.width
        @tile_h = img.height
      end
      hash[:children].each do |child|
        case child[:name]
        when 'properties'
          properties.from_xml_hash(child[:children])
        end
      end
    end

    def init_empty(id)
      attributes.add({
        id: id,
      })
      @path = tileset.image.path unless tileset.image.nil?
      @tile_x, @tile_y, @tile_w, @tile_h = tileset.id_to_xywh(id)
    end

    # Object has id method and method_missing magic from WithAttribute for attributes like id doesnt work.
    def id
      attributes.id.to_i
    end

    def properties
      @properties ||= Properties.new(self)
    end
  end
end
