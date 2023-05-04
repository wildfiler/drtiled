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
      xml = $gtk.parse_xml_file(filename)
      hash = xml[:children].first

      new(nil, filename, sprite_class).tap do |new_tileset|
        new_tileset.from_xml_hash(hash)
      end
    end

    # TODO: Add terraintypes, grid, tileoffset, wangsets
    def from_xml_hash(hash)
      attributes.add(hash[:attributes])

      if source && !source.empty?
        @path = Utils.relative_to_absolute(File.join(File.dirname(map.path), source))
        hash = $gtk.parse_xml_file(path)[:children].first
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
          begin
          tile = Tile.new(self)
          tile.from_xml_hash(child)
          tiles[tile.id] = tile
          rescue StandardError => e
            puts self
            puts tile
            puts "id: #{tile.id}"
            puts "attributes.id: #{tile.attributes.id}"
            raise e
          end
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

    def find(cleared_gid)
      id = cleared_gid - firstgid
      tiles[id]
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

    def exclude_from_serialize
      super + %w[tiles_cache tiles]
    end
  end
end
