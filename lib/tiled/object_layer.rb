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
          offset = [object.x + object.points[0].x, object.y + object.points[0].y]

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
