module Tiled
  class Tileset
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :map, :image, :tiles_cache
    attributes :firstgid, :source, :name, :tilewidth, :tileheight, :spacing, :margin, :tilecount,
      :columns, :objectalignment

    def initialize(map)
      @map = map
    end

    # TODO: Add terraintypes, grid, tileoffset, wangsets
    def from_xml_hash(hash)
      attributes.add(hash[:attributes])

      if source && !source.empty?
        path = Utils.relative_to_absolute(File.join(File.dirname(map.path), source))
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
      super + %w[tiles_cache tiles]
    end
  end
end
