module Tiled
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
      raise MapNotFound, "Unable to locate map file: '#{path}'" unless $gtk.stat_file(path)

      xml = $gtk.parse_xml_file(path)

      raise ParseError, "Unable to parse map file: #{path}." unless xml

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

    def collision_objects
      @collision_objects ||= layers.flat_map(&:collision_objects)
    end

    def tilesets
      @tilesets ||= []
    end

    def properties
      @properties ||= Properties.new(self)
    end

    def find_tile(gid)
      return if gid.zero?
      return tiles_cache[gid] if tiles_cache.key?(gid)

      cache_tile(gid)
    end

    def exclude_from_serialize
      super + %w[tiles_cache tilesets layers]
    end

    def pixelwidth
      width * tilewidth
    end

    def pixelheight
      return height * tileheight
    end

    #gets the first object layer with the passed name of `layer_name`
    #then looks in that layer for the first object that has the name `object_name`
    #then returns that object
    def object_by_name(layer_name, object_name)
      
      named_layer = @object_groups.reject do | layer |
        layer.name != layer_name
      end.first

      raise ObjectLayerNotFound, "The object layer \"#{layer_name}\" was not found in map \"#{@path}\"" if named_layer.nil?
      
      the_object = named_layer.objects.reject do | object |
        object.name != object_name
      end

      raise ObjectNameNotFound, "The object named \"#{object_name}\" was not found in object layer \"#{layer_name}\"" if the_object.empty?

      #if we get multiple objects with the name passed, only return the first item.
      the_object.first
    end

    
    private

    def cache_tile(gid)
      tileset = tilesets.detect { |tileset| tileset.contain?(gid) }
      tile = tileset&.find(gid)
      tiles_cache[gid] = tile
    end

    def tiles_cache
      @tiles_cache ||= {}
    end
  end
end
