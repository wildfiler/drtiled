module Tiled
  class TiledObject
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :map
    attributes :id, :gid, :x, :y, :width, :height, :object_type, :points

    def initialize(map, attrs, children)
      @map = map
      attributes.add(id: attrs['id'], gid: attrs['gid']&.to_i)

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
      attributes.add('y' => (map.height * map.tileheight) -
                            (attrs['y'].to_f + (object_type == :tile ? 0 : height)))
      attributes.add('x' => attrs['x'])
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
