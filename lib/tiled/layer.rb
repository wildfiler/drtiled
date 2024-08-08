module Tiled
  class Layer
    include Tiled::Serializable
    include Tiled::WithAttributes

    RIGHT_DOWN = 'right-down'.freeze
    RIGHT_UP = 'right-up'.freeze

    attr_reader :map, :data
    attributes :id, :name, :x, :y, :width, :height, :opacity, :visible, :tintcolor, :offset, :parallax

    def initialize(map)
      @map = map
    end

    # Initialize layer with data from xml hash
    # @param hash [Hash] hash loaded from xml file of map.
    # @return [Tiled::Layer] self
    def from_xml_hash(hash)
      raw_attributes = hash[:attributes]
      raw_attributes['visible'] = raw_attributes['visible'] != '0'
      raw_attributes['offset'] = [raw_attributes.delete('offsetx').to_f,
                                 -raw_attributes.delete('offsety').to_f]
      raw_attributes['parallax'] = [raw_attributes.delete('parallaxx')&.to_f || 1.0,
                                    raw_attributes.delete('parallaxy')&.to_f || 1.0]

      attributes.add(raw_attributes)

      hash[:children].each do |child|
        case child[:name]
        when 'properties'
          properties.from_xml_hash(child[:children])
        when 'data'
          @data = LayerData.new(self)
          @data.from_xml_hash(child)
        end
      end

      self
    end

    # Get tiles of layer
    # @return [Array<Array<Tiled::Tile, nil>>] 2d array of layer tiles, `nil` for empty places.
    def tiles
      @tiles ||= tile_rows_from_data.map do |row|
        row.map do |gid|
          map.find_tile(gid)
        end
      end
    end

    # Get tile by x, y coordinates
    # @return [Tiled::Tile, nil] tile at x, y coordinate on this layer or `nil`
    def tile_at(x, y)
      tiles[y][x]
    end

    # Method to get array of visible and renderable sprites from layer.
    #
    # By default for sprites used Tiled::Sprite class, but you can override this by passing `sprite_class` argument
    # to Map.new method.
    #
    # @example
    #   args.outputs.sprites << args.state.map.layer['ground'].sprites
    #
    # @return [Array<Tiled::Sprite>] array of sprite objects.
    # @return [Map#sprite_class] array of objects of custom class.
    def sprites
      return [] unless visible?

      @sprites ||= case map.orientation
      when 'isometric'
        []
      else
        prepare_sprites(sprite_class: map.sprite_class, animated: false)
      end
    end

    def animated_sprites
      return [] unless visible?

      @animated_sprites ||= case map.orientation
      when 'isometric'
        isometric_sprites
      else
        prepare_sprites(sprite_class: map.animated_sprite_class, animated: true)
      end
    end

    def isometric_sprites
      return [] if map.orientation != 'isometric'

      height = map.attributes.tileheight
      width = map.attributes.tilewidth
      half_width = width / 2
      half_height = height / 2

      offset_x = map.width * half_width - half_width
      offset_y = map.height * height - height

      tiles.map_2d do |x, y, tile|
        next unless tile

        corrected_x = offset_x - (x - y) * half_width + tile.tileset.offset.x
        corrected_y = offset_y - (x + y) * half_height + tile.tileset.offset.y

        if tile.animated?
          map.animated_sprite_class.from_tiled(tile, x: corrected_x, y: corrected_y)
        else
          map.sprite_class.from_tiled(tile, x: corrected_x, y: corrected_y)
        end
      end.compact
    end

    def collision_objects
      @collision_objects ||= tiles.map_2d do |y, x, tile|
        next unless tile

        point = tile_to_screen(tile, x, y)
        tile.collision_objects(point.x, point.y)
      end.flatten.compact
    end

    def properties
      @properties ||= Properties.new(self)
    end

    # @return [Boolean] whether or not the layer is visible
    def visible?
      visible
    end

    def exclude_from_serialize
      super + %w[tiles sprites]
    end

    private

    # Tiled always defaults to "right-down" renderorder
    # when not provided and for non-orthogonal maps
    def render_order
      map.renderorder || RIGHT_DOWN
    end

    def tile_rows_from_data
      case render_order
      when RIGHT_DOWN
        data.tiles
      when RIGHT_UP
        data.tiles.reverse
      else
        raise_unsupported_render_order!
      end
    end

    def raise_unsupported_render_order!
      raise UnsupportedRenderOrder, "Map for Layer #{name} has unsupported renderorder: #{render_order}"
    end

    def xy_by_render_order(x, y)
      ordered_y = case render_order
                  when RIGHT_DOWN
                    (map.attributes.height - (y + 1))
                  when RIGHT_UP
                    y
                  else
                    raise_unsupported_render_order!
                  end

      { x: x, y: ordered_y }
    end

    def prepare_sprites(sprite_class:, animated:)
      tiles.map_2d do |y, x, tile|
        next unless tile
        next if tile.animated? != animated

        point = tile_to_screen(tile, x, y)
        sprite_class.from_tiled(tile, x: point.x, y: point.y)
      end.compact
    end

    def tile_to_screen(tile, x, y)
      tile_offset = tile.tileset.attributes.offset
      ordered_point = xy_by_render_order(x, y)
      {
        x: ordered_point.x * map.tilewidth + tile_offset.x,
        y: ordered_point.y * map.tileheight + tile_offset.y
      }
    end
  end
end
