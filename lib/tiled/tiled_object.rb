module Tiled
  class TiledObject
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :map
    attributes :id, :x, :y, :width, :height, :shape, :points

    def initialize(map, attrs, children)
      @map = map
      attributes.add(id: attrs['id'], shape: children.any? ? children.first[:name].to_sym : :rectangle)

      if shape == :polygon
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
        %w[width height].each { |attr| attributes.add(attr => attrs[attr].to_f) }
      end

      # Flip Y-axis
      attributes.add('y' => (map.height.to_f * map.tileheight.to_f) - (attrs['y'].to_f + height))
      attributes.add('x' => attrs['x'].to_f)
    end
  end
end
