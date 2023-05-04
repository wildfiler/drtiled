module Tiled
  class AnimatedSprite < Tiled::Sprite
    # Animated Sprite class for easy rendering of maps. You can pass instance of this class to `args.outputs` array.
    # Used in Tiled::Layer#sprites.

    attr_accessor :animation

    # @return [Tiled::AnimatedSprite] return sprite object from `Tiled::Tile` object.
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
        animation: tile.animation,
        flip_horizontally: tile.flip_horizontally?,
        flip_vertically: tile.flip_vertically?,
        angle: tile.angle
      )
    end

    def path
      current_tile.path
    end

    def tile_x
      current_tile.tile_x
    end

    def tile_y
      current_tile.tile_y
    end

    private

    def current_tile
      animation.tileset.tiles[current_tileid]
    end

    def current_tileid
      current_frame = 0.frame_index(animation.total_frames, animation.step, true)
      animation.tiles_ids[current_frame]
    end
  end
end
