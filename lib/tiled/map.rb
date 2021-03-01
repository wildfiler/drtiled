module Tiled

  class Map
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :map, :path, :sprite_class
    attributes :id, :tiledversion, :orientation, :renderorder, :compressionlevel, :width, :height,
      :tilewidth, :tileheight, :hexsidelength, :staggeraxis, :staggerindex, :backgroundcolor, :nextlayerid,
      :nextobjectid, :infinite


    def initialize(path, sprite_class = Sprite)
      @path = path
      @sprite_class = sprite_class
    end

    def load
      xml = $gtk.parse_xml_file(@path)
      @map = xml[:children].first
      attributes.add(@map[:attributes])
      map[:children].each do |child|
        case child[:name]
        when 'layer'
          layer = Layer.new(self)
          layer.from_xml_hash(child)
          layers.add layer
        when 'properties'
          properties.from_xml_hash(child[:children])
        when 'tileset'
          tileset = Tileset.new(self)
          tileset.from_xml_hash(child)
          tilesets << tileset
        end
      end
    end

    def layers
      @layers ||= Layers.new
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
      @tiles_cache[gid] ||= begin
        tileset = tilesets.detect do |tileset|
          tileset.firstgid <= gid && tileset.firstgid + tileset.attributes.tilecount.to_i - 1 >= gid
        end
        tileset.find(gid) if tileset
      end
    end

    def exclude_from_serialize
      super + %w[tiles_cache tilesets layers]
    end
  end
end
