module Tiled

  class WangSet
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :tileset

    attributes :name, :type, :tile

    def initialize(tileset)
      @tileset = tileset
    end

    def from_xml_hash(hash)
      tile_id = hash[:attributes].delete('tile')&.to_i
      attributes.add(
        tile: tileset.tiles[tile_id],
        **hash[:attributes]
      )

      hash[:children].each do |child|
        case child[:name]
        when 'wangcolor'
          colors << WangColor.new(self).tap do |wangcolor|
            wangcolor.from_xml_hash(child)
          end
        when 'wangtile'
          wangtile = WangTile.new(self)
          wangtile.from_xml_hash(child)
          tiles[wangtile.tile.id] = wangtile
        end
      end
    end

    def colors
      @colors ||= []
    end

    def tiles
      @tiles ||= {}
    end

    def exclude_from_serialize
      super + %w[colors tiles]
    end
  end
end
