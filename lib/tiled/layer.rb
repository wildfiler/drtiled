module Tiled
  class Layer
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :map, :tiles, :data
    attributes :id, :name, :x, :y, :width, :height, :opacity, :visible, :tintcolor, :offsetx, :offsety

    def initialize(map)
      @map = map
    end

    def from_xml_hash(hash)
      attributes.add(hash[:attributes])

      hash[:children].each do |child|
        case child[:name]
        when 'properties'
          properties.from_xml_hash(child[:children])
        when 'data'
          @data = LayerData.new(self)
          @data.from_xml_hash(child)
        end
      end
    end

    def tiles
      @tiles ||= data.tiles.map do |row|
        row.map do |gid|
          map.find_tile(gid)
        end
      end
    end

    def sprites
      @sprites ||= begin
        return unless visible?

        sprite_class = map.sprite_class
        width = map.attributes.tilewidth.to_i
        height = map.attributes.tileheight.to_i
        map_height = map.attributes.height.to_i - 1
        tiles.flat_map.with_index do |row, y|
          row.map.with_index do |tile, x|
            next unless tile
            sprite_class.from_tiled(x * width, (map_height - y) * height, tile)
          end.compact
        end
      end
    end

    def properties
      @properties ||= Properties.new(self)
    end

    def visible?
      visible != '0'
    end

    def exclude_from_serialize
      super + %w[tiles sprites]
    end
  end
end
