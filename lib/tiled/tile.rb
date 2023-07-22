module Tiled
  class Tile
    TRANSFORMATIONS_DIAGONAL = {
      [true, true] => [false, true, 90],
      [true, false] => [false, false, -90],
      [false, true] => [false, false, 90],
      [false, false] => [true, false, 90]
    }.freeze

    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader(
      :tileset, :path, :tile_w, :tile_h, :tile_x, :tile_y, :animation,
      :flip_horizontally, :flip_vertically, :angle
    )
    attributes :id, :type, :probability

    def initialize(tileset_or_tile, gid = nil)
      @flip_horizontally = false
      @flip_vertically = false
      @angle = 0

      if tileset_or_tile.is_a? Tileset
        @tileset = tileset_or_tile
      else
        copy_tile(tileset_or_tile)
        process_gid(gid)
      end
    end

    # TODO: Add terrain and animation support
    def from_xml_hash(hash)
      attributes.add(hash[:attributes])

      init_from_tileset

      hash[:children].each do |child|
        case child[:name]
        when 'animation'
          @animation = Animation.new(tileset)
          @animation.from_xml_hash(child)
        when 'properties'
          properties.from_xml_hash(child[:children])
        when 'image'
          img = parse_image(child)

          @path = img.path
          @tile_x = 0
          @tile_y = 0
          @tile_w = img.width
          @tile_h = img.height
        when 'objectgroup'
          object_layer.from_xml_hash(child)
        end
      end
    end

    def init_empty(id)
      attributes.add({
        id: id,
        probability: 1.0,
      })
      init_from_tileset
    end

    def properties
      @properties ||= Properties.new(self)
    end

    def animated?
      @animated ||= !animation.nil?
    end

    def gid
      @gid ||= tileset.id_to_gid(id)
    end

    def pixelheight
      tile_h
    end

    def pixelwidth
      tile_w
    end

    def object_layer
      @object_layer ||= ObjectLayer.new(self)
    end

    def collision_objects(origin_x = 0, origin_y = 0)
      object_layer.objects.map do |object|
        object.to_primitive(origin_x, origin_y)
      end
    end

    private

    def parse_image(child)
      Tiled::Image.new(tileset).tap do |img|
        img.from_xml_hash(child)
      end
    end

    def init_from_tileset
      @path = tileset.image&.path
      @tile_x, @tile_y, @tile_w, @tile_h = tileset.id_to_xywh(id.to_i)
    end

    def flip_diagonally!
      @flip_horizontally, @flip_vertically, @angle = TRANSFORMATIONS_DIAGONAL[[@flip_horizontally, @flip_vertically]]
    end

    def copy_tile(tile)
      @tileset = tile.tileset
      attributes.add(id: tile.id, type: tile.type, probability: tile.probability)
      @path = tile.path
      @animation = tile.animation
      @tile_x, @tile_y, @tile_w, @tile_h = tileset.id_to_xywh(id.to_i)
    end

    def process_gid(gid)
      return unless gid

      flags = Tiled::Gid.flags(gid)

      not_supported_rotation! if flags.rotated_hexagonal_120?

      @gid = gid
      @flip_horizontally = flags.flipped_horizontally?
      @flip_vertically = flags.flipped_vertically?
      @angle = 0

      flip_diagonally! if flags.flipped_diagonally?
    end

    def not_supported_rotation!
      raise UnsupportedFeature, "DRTiled doesn't support hexagonal rotations"
    end
  end
end
