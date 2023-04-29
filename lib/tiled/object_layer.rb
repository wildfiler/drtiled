module Tiled
  class ObjectLayer
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :map, :objects
    attributes :id, :color, :r, :g, :b, :visible

    def initialize(map)
      @map = map
      @objects = []
    end

    # Initialize layer with data from xml hash
    # @param hash [Hash] hash loaded from xml file of map.
    # @return [Tiled::ObjectLayer] self
    def from_xml_hash(hash)
      raw_attributes = hash[:attributes]
      raw_attributes['color'] = Color.from_tiled_rgba(raw_attributes['color'])

      attributes.add(raw_attributes)

      @objects = hash[:children].map do |child|
        TiledObject.new(map, child[:attributes], child[:children])
      end

      self
    end

    def sprites
      []
    end

    # Renders the objects to the `outputs_layer`.
    # @param args `args` from `tick` method
    # @param output_layer one of `args.outputs`, works with `primitives` and `debug`
    def render_debug(args, outputs_layer)
      return unless visible?

      # Resolution of circle
      radius = 300
      diameter = 2 * radius

      unless args.state.tiled_circle_initialized
        # Draw a circle by iterating over the diameter and drawing a bunch
        # of lines that get wider as they reach the center
        diameter.times do |i|
          height = i - radius
          length = Math::sqrt(radius * radius - height * height)
          args.render_target(:ellipse).lines << {
            x: i, y: radius - length, x2: i, y2: radius + length,
            **color.to_h
          }
        end

        args.state.tiled_circle_initialized = true
      end

      objects.each do |object|
        case object.shape
        when :rectangle
          border = {
            primitive_marker: :border,
            x: object.x, y: object.y,
            w: object.width, h: object.height,
            **color.to_h
          }
          solid = border.merge(primitive_marker: :solid, a: color.a * 0.7)

          outputs_layer << [border, solid]
        when :ellipse
          outputs_layer << {
            x: object.x, y: object.y,
            w: object.width, h: object.height,
            path: :ellipse,
            source_x: 0, source_y: 0,
            source_w: diameter, source_h: diameter,
            a: 255
          }
        when :polygon
          # Get the starting point of the polygon
          x_offset = object.x + object.points[0].x - 1
          y_offset = object.y + object.points[0].y

          # Find the top and bottom of the polygon
          y_values = object.points.map { |p| p.y.to_i }
          min_y, max_y = y_values.min, y_values.max

          # Similar to the circle, this is drawn as a bunch of horizontal lines
          (max_y - min_y).times do |y|
            # We need to get the intersections where a horizontal line
            # across the screen crosses the edges of the polygon
            intersections = []

            y += min_y

            object.points.each_with_index do |point, index|
              next_point = object.points[(index + 1) % object.points.length]

              # We're iterating over each point to find the lines where the
              # "scan line" that we're drawing intersects. This will only hit
              # twice, once on each side
              if (point.y <= y && next_point.y > y) || (next_point.y <= y && point.y > y)
                if point.y == next_point.y
                  # The edge is horizontal, so the intersection is just the
                  # X-coordinate of the point
                  intersections << x_offset + point.x
                else
                  # Find the X-coordinate where the edge intersects the
                  # row using the equation of the line
                  intersections << x_offset +
                    ((y - point.y) * (next_point.x - point.x) /
                     (next_point.y - point.y)) + point.x
                end
              end
            end

            screen_y = y_offset + y

            outputs_layer << {
              x: intersections[0], y: screen_y,
              x2: intersections[1], y2: screen_y,
              **color.to_h,
              a: (color.a * 0.7).to_i
            }
          end

          # Draw the outline connecting each point
          object.points.each_with_index do |point, index|
            next_point = object.points[(index + 1) % object.points.length]

            outputs_layer << {
              x: x_offset + point.x, y: y_offset + point.y,
              x2: x_offset + next_point.x, y2: y_offset + next_point.y,
              **color.to_h
            }
          end
        when :point
          size = 10
          outputs_layer << {
            x: object.x - (size / 2.0), y: object.y - (size / 2.0),
            w: size, h: size,
            path: :ellipse,
            source_x: 0, source_y: 0,
            source_w: diameter, source_h: diameter,
            **color.to_h
          }
        end
      end
    end

    # @return [Boolean] whether or not the layer is visible
    def visible?
      visible != 0
    end
  end
end
