module Tiled
  class Layer
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :map, :data
    attributes :id, :name, :x, :y, :width, :height, :opacity, :visible, :tintcolor, :offsetx, :offsety

    def initialize(map)
      @map = map
    end

    # Initialize layer with data from xml hash
    # @param hash [Hash] hash loaded from xml file of map.
    # @return [Tiled::Layer] self
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

      self
    end

    # Get tiles of layer
    # @return [Array<Array<Tiled::Tile, nil>>] 2d array of layer tiles, `nil` for empty places.
    def tiles
      @tiles ||= data.tiles.map do |row|
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
      return unless visible?
      return @sprites if @sprites

      sprite_class = map.sprite_class
      width = map.attributes.tilewidth.to_i
      height = map.attributes.tileheight.to_i
      map_height = map.attributes.height.to_i - 1

      @sprites = tiles.flat_map.with_index do |row, y|
        row.map.with_index do |tile, x|
          next unless tile
          sprite_class.from_tiled(x * width, (map_height - y) * height, tile)
        end.compact
      end
    end

    def properties
      @properties ||= Properties.new(self)
    end

    # Return `attributes.visible` converted to boolean
    # @return [Boolean]
    def visible?
      visible != '0'
    end

    def exclude_from_serialize
      super + %w[tiles sprites]
    end
  end
end
