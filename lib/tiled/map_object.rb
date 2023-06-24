module Tiled
  class MapObject
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :map

    attributes :id, :x, :y, :width, :height, :name, :type, :object_type, :visible

    OBJECT_CLASSES = {
      polygon: Tiled::MapObject::Polygon,
      polyline: Tiled::MapObject::Polyline,
      text: Tiled::MapObject::Text,
      tile: Tiled::MapObject::Tile,
    }.freeze

    def self.from_hash(map, attrs, children)
      klass = OBJECT_CLASSES.fetch(detect_type(attrs, children), self)
      klass.new(map, attrs, children)
    end

    def self.detect_type(attrs, children)
      if children.any?
        children.first[:name].to_sym
      elsif attrs['gid']
        :tile
      else
        :rectangle
      end
    end

    def initialize(map, attrs, children)
      @map = map
      if (props_index = children.find_index { |child| child[:name] == 'properties' })
        properties.from_xml_hash(children.delete_at(props_index)[:children])
      end

      attributes.add(
        id: attrs['id'].to_i,
        name: attrs['name'],
        type: attrs['type'],
        visible: (attrs['visible'] != '0'),
        x: attrs['x'].to_f,
        y: map.pixelheight - attrs['y'].to_f - attrs['height'].to_f,
        width: attrs['width'].to_f,
        height: attrs['height'].to_f,
        object_type: self.class.detect_type(attrs, children),
      )
    end

    [:width, :height].each do |name|
      define_method name do
        if attributes.respond_to? name
          attributes.send(name)
        end || 0
      end
    end

    def properties
      @properties ||= Properties.new(map)
    end

    # @return [Boolean] whether or not the object is visible
    def visible?
      visible
    end

    def tile
      return unless object_type == :tile

      @tile ||= map.find_tile(gid)
    end

    def to_primitive(origin_x, origin_y)
      case object_type
      when :rectangle
        {
          primitive_marker: :border,
          x: origin_x + x,
          y: origin_y + y,
          w: width,
          h: height,
        }
      else
        raise UnsupportedFeature, "Not supported collision object type '#{object_type}'!"
      end
    end
  end
end
