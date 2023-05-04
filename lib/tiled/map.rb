module Tiled
  FLIPPED_HORIZONTALLY_FLAG  = 0x80000000
  FLIPPED_VERTICALLY_FLAG    = 0x40000000
  FLIPPED_DIAGONALLY_FLAG    = 0x20000000
  ROTATED_HEXAGONAL_120_FLAG = 0x10000000

  class Map
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :map, :path, :sprite_class, :animated_sprite_class
    attributes :id, :tiledversion, :orientation, :renderorder, :compressionlevel, :width, :height,
      :tilewidth, :tileheight, :hexsidelength, :staggeraxis, :staggerindex, :backgroundcolor, :nextlayerid,
      :nextobjectid, :infinite

    def initialize(path, sprite_class = Sprite, animated_sprite_class = AnimatedSprite)
      @path = path
      @sprite_class = sprite_class
      @animated_sprite_class = animated_sprite_class
    end

    def load
      xml = $gtk.parse_xml_file(@path)
      @map = xml[:children].first
      attributes.add(@map[:attributes])

      custom_properties = nil

      map[:children].each do |child|
        case child[:name]
        when 'layer'
          layer = Layer.new(self)
          layer.from_xml_hash(child)
          layers.add layer
        when 'objectgroup'
          objectlayer = ObjectLayer.new(self)
          objectlayer.from_xml_hash(child)
          layers.add objectlayer
          object_groups.add objectlayer
        when 'properties'
          custom_properties = child[:children]
        when 'tileset'
          tileset = Tileset.new(self)
          tileset.from_xml_hash(child)
          tilesets << tileset
        end
      end

      # This is done last so that it can parse the object properties
      properties.from_xml_hash(custom_properties) if custom_properties
    end

    def layers
      @layers ||= Layers.new
    end

    def object_groups
      @object_groups ||= Layers.new
    end

    def tilesets
      @tilesets ||= []
    end

    def properties
      @properties ||= Properties.new(self)
    end

    def find_tile(gid)
      return if gid.zero?

      @tiles_cache ||= {}
      return @tiles_cache[gid] if @tiles_cache[gid]

      # The highest 4 bits of the GID are flags indicating the tile's orientation:
      flip_horizontally = (gid & FLIPPED_HORIZONTALLY_FLAG) > 0
      flip_vertically = (gid & FLIPPED_VERTICALLY_FLAG) > 0
      flip_diagonally = (gid & FLIPPED_DIAGONALLY_FLAG) > 0

      # Clear the flags
      cleared_gid = gid & ~(
        FLIPPED_HORIZONTALLY_FLAG |
        FLIPPED_VERTICALLY_FLAG |
        FLIPPED_DIAGONALLY_FLAG |
        ROTATED_HEXAGONAL_120_FLAG
      )

      return if cleared_gid.zero?

      # Using the original GID as the key for the cache
      @tiles_cache[gid] = begin
        tileset = tilesets.detect do |tileset|
          tileset.firstgid <= cleared_gid &&
            tileset.firstgid + tileset.attributes.tilecount.to_i - 1 >= cleared_gid
        end

        if cleared_gid == gid
          # No flip flags, we can just cache a reference
          tileset&.find(cleared_gid)
        else
          # It's flipped; dup it, apply the reflections and cache that
          tileset&.find(cleared_gid).dup.tap do |tile|
            tile.flip! :horizontally if flip_horizontally
            tile.flip! :vertically if flip_vertically
            tile.flip! :diagonally if flip_diagonally
          end
        end
      end
    end

    def exclude_from_serialize
      super + %w[tiles_cache tilesets layers]
    end
  end
end
