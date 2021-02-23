module Tiled
  class Tileset
    include Tiled::Serializable
    attr_reader :map, :attributes, :image, :tiles_cache, :hash

    def initialize(map)
      @map = map
    end

    # TODO: Add terraintypes, grid, tileoffset, wangsets
    def from_xml_hash(hash)
      @hash = hash
      @attributes = Attributes.new(hash[:attributes])

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

    def find(gid)
      id = gid - firstgid
      tiles[id]
    end

    [:tilewidth, :tileheight, :columns, :spacing, :margin, :firstgid, :tilecount].each do |name|
      define_method name do
        if attributes.respond_to? name
          attributes.send(name).to_i
        else
          0
        end
      end
    end

    def id_to_xywh(id)
      y, x = id.divmod(columns)

      [
        x * tilewidth + spacing + 2 * margin,
        y * tileheight + spacing + 2 * margin,
        tilewidth,
        tileheight,
      ]
    end

    def exclude_from_serialize
      super + %w[tiles_cache]
    end
  end
end
