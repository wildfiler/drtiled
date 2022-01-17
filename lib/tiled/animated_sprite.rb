module Tiled
  class AnimatedSprite < Tiled::Sprite
    # Animated Sprite class for easy rendering of maps. You can pass instance of this class to `args.outputs` array.
    # Used in Tiled::Layer#sprites.

    attr_accessor :animation

    # @return [Tiled::AnimatedSprite] return sprite object from `Tiled::Tile` object.
    def self.from_tiled(tile, x:, y:, w: nil, h: nil)
      new(
        x: x.to_i,
        y: y.to_i,
        w: tile.tile_w.to_i,
        h: tile.tile_h.to_i,
        tile_w: tile.tile_w.to_i,
        tile_h: tile.tile_h.to_i,
        animation: tile.animation,
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
