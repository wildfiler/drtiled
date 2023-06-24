module Tiled
  class MapObject
    class Polygon < MapObject
      attributes :id, :x, :y, :width, :height, :name, :type, :object_type, :points, :visible

      def initialize(map, attrs, children)
        super(map, attrs, children)

        points = parse_points(children)
        x_min, x_max = points.map(&:x).minmax
        y_min, y_max = points.map(&:y).minmax
        height = y_max - y_min + 2

        attributes.add(
          points: points,
          x: attrs['x'],
          y: map.pixelheight - attrs['y'].to_f - height,
          width: x_max - x_min + 2,
          height: height,
        )
      end
    end

    private

    def parse_points(children)
      # Input format for the points is: "0,0 64,-64 64,0"
      # This is turned into: [[0, 0], [64, 64], [64, 0]]
      # The Y-axis is flipped for consistency with DragonRuby's rendering.

      children.first[:attributes]['points'].split(' ').map do |point|
        point.split(',').map(&:to_f).tap { |coords| coords.y *= -1 }
      end
    end
  end
end
