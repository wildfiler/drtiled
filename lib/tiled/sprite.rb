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
    def self.from_tiled(tile, x:, y:, w: nil, h: nil)
      new(
        path: tile.path,
        x: x,
        y: y,
        w: w || tile.tile_w,
        h: h || tile.tile_h,
        tile_x: tile.tile_x,
        tile_y: tile.tile_y,
        tile_w: tile.tile_w,
        tile_h: tile.tile_h,
      )
    end
  end
end
