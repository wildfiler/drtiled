module Tiled
  class Sprite
    # Sprite class for easy rendering of maps. You can pass instance of this class to `args.outputs` array.
    # Used in Tiled::Layer#sprites.

    include Tiled::Serializable
    include Tiled::AttributeAssignment

    attr_sprite

    def initialize(**attributes)
      update(attributes)
    end

    # :nodoc:
    def primitive_marker
      :sprite
    end

    # @return [Tiled::Sprite] return sprite object from `Tiled::Tile` object.
    def self.from_tiled(x, y, tile)
      new(
        path: tile.path,
        x: x.to_i,
        y: y.to_i,
        w: tile.tile_w.to_i,
        h: tile.tile_h.to_i,
        tile_x: tile.tile_x.to_i,
        tile_y: tile.tile_y.to_i,
        tile_w: tile.tile_w.to_i,
        tile_h: tile.tile_h.to_i,
      )
    end
  end
end
