module Tiled
  class Tileset
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :map, :path, :image, :tiles_cache
    attributes :firstgid, :source, :name, :tilewidth, :tileheight, :spacing, :margin, :tilecount,
      :columns, :objectalignment

    def initialize(map, path = nil, sprite_class = nil)
      @map = map
      @path = path
      @sprite_class = sprite_class || map&.sprite_class
    end

    def self.load(filename, sprite_class = Sprite)
      raise TilesetNotFound, "Unable to locate tileset file: '#{filename}'." unless File.exists?(filename)

      xml = $gtk.parse_xml_file(filename)

      raise ParseError, "Unable to parse tileset file: #{filename}." unless xml

      hash = xml[:children].first

      new(nil, filename, sprite_class).tap do |new_tileset|
        new_tileset.from_xml_hash(hash)
      end
    end

    # TODO: Add terraintypes, grid, tileoffset, wangsets
    def from_xml_hash(hash)
      attributes.add(hash[:attributes])

      if source && !source.empty?
        hash = load_external_xml(source)
        attributes.add(hash[:attributes])
      end

      @tiles = Array.new(tilecount)

      hash[:children].each do |child|
        case child[:name]
        when 'properties'
          properties.from_xml_hash(child[:children])
        when 'image'
          @image = Image.new(self)
          image.from_xml_hash(child)
        when 'tile'
          tile = Tile.new(self)
          tile.from_xml_hash(child)
          tiles[tile.id] = tile
        end
      end

      tilecount.times do |id|
        tiles[id] ||= begin
          Tile.new(self).tap do |tile|
            tile.init_empty(id)
          end
        end
      end
    end

    def properties
      @properties ||= Properties.new(self)
    end

    def tiles
      @tiles ||= []
    end

    def transformed_tiles
      @transformed_tiles ||= {}
    end

    def contain?(gid)
      tile_id = gid_to_id(gid)

      tile_id >= 0 && tile_id < tilecount
    end

    def find(gid)
      tile = tiles[gid_to_id(gid)]

      if Tiled::Gid.flags?(gid) && tile
        transformed_tiles[gid] ||= Tile.new(tile, gid)
      else
        tile
      end
    end

    # Return id in tileset from gid of map. Flags are ignored.
    def gid_to_id(gid)
      Tiled::Gid.without_flags(gid) - firstgid
    end

    # Return gid in map for tile id.
    def id_to_gid(tile_id)
      firstgid + tile_id
    end

    # Method to render a tile directly from tileset, by ID.
    #
    # @example
    #   args.outputs.sprites << args.state.map.tilesets[0].sprite_at(100, 100, 53)
    #   args.outputs.sprites << args.state.tileset.sprite_at(50, 50, 23)
    #
    # @return <Tiled::Sprite> sprite object.
    def sprite_at(x, y, id)
      @sprite_class.from_tiled(tiles[id], x: x, y: y)
    end

    [:tilewidth, :tileheight, :columns, :spacing, :margin, :firstgid, :tilecount].each do |name|
      define_method name do
        if attributes.respond_to? name
          attributes.send(name)
        end || 0
      end
    end

    def id_to_xywh(id)
      if columns.zero?
        y = 0
        x = 0
      else
        y, x = id.divmod(columns)
      end

      [
        x * tilewidth + spacing + 2 * margin,
        y * tileheight + spacing + 2 * margin,
        tilewidth,
        tileheight,
      ]
    end

    def load_external_xml(relative_path)
      @path = Utils.relative_to_absolute(File.join(File.dirname(map.path), relative_path))

      raise TilesetNotFound, "Unable to locate external tileset file: '#{relative_path}'" unless File.exists?(path)

      xml = $gtk.parse_xml_file(path)

      raise ParseError, "Unable to parse tileset file: #{relative_path}." unless xml

      xml[:children].first
    end

    def exclude_from_serialize
      super + %w[tiles_cache transformed_tiles tiles]
    end
  end
end
