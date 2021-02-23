module Tiled
  class Sprite
    include Tiled::Serializable
    include Tiled::AttributeAssignment

    attr_sprite

    def initialize(**attributes)
      update(attributes)
    end

    def self.from_tiled(x, y, tile)
      new(
        path: tile.path,
        x: x,
        y: y,
        w: tile.tile_w,
        h: tile.tile_h,
        tile_x: tile.tile_x,
        tile_y: tile.tile_y,
        tile_w: tile.tile_w,
        tile_h: tile.tile_h,
      )
    end
  end
end
