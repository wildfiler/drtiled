module Tiled
  class MapObject
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :map

    attributes :id, :gid, :x, :y, :width, :height, :name, :type, :object_type, :points, :visible

    def initialize(map, attrs, children)
      @map = map
      attributes.add(
        id: attrs['id'],
        gid: attrs['gid']&.to_i,
        name: attrs['name'],
        type: attrs['type'],
      )

      if (props_index = children.find_index { |child| child[:name] == 'properties' })
        properties.from_xml_hash(children.delete_at(props_index)[:children])
      end

      attributes.add(object_type: detect_type(attrs, children))

      if object_type == :polygon
        attributes.add(
          # Input format for the points is: "0,0 64,-64 64,0"
          # This is turned into: [[0, 0], [64, 64], [64, 0]]
          # The Y-axis is flipped for consistency with DragonRuby's rendering.
          points: children.first[:attributes]['points'].split(' ').map do |pt|
            pt.split(',').map(&:to_f).tap { |coords| coords.y *= -1 }
          end
        )

        x_values = points.map(&:x)
        y_values = points.map(&:y)

        attributes.add({
          width: x_values.max - x_values.min + 2,
          height: y_values.max - y_values.min + 2
        })
      else
        %w[width height].each { |attr| attributes.add(attr => attrs[attr]) }
      end

      # Flip Y-axis
      attributes.add(
        'y' => map.pixelheight - (attrs['y'].to_f + (object_type == :tile ? 0 : height)),
        'x' => attrs['x']
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

    private

    def detect_type(attrs, children)
      if children.any?
        children.first[:name].to_sym
      elsif attrs['gid']
        :tile
      else
        :rectangle
      end
    end
  end
end
