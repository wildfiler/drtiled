module Tiled
  class ObjectLayer
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :map, :objects
    attributes :id, :color, :visible, :offset, :parallax

    def initialize(map)
      @map = map
      @objects = []
    end

    # Initialize layer with data from xml hash
    # @param hash [Hash] hash loaded from xml file of map.
    # @return [Tiled::ObjectLayer] self
    def from_xml_hash(hash)
      raw_attributes = hash[:attributes]
      raw_attributes['visible'] = raw_attributes['visible'] != '0'
      raw_attributes['color'] = Color.from_tiled_rgba(raw_attributes['color'])
      raw_attributes['offset'] = [raw_attributes.delete('offsetx').to_f,
                                 -raw_attributes.delete('offsety').to_f]
      raw_attributes['parallax'] = [raw_attributes.delete('parallaxx')&.to_f || 1.0,
                                    raw_attributes.delete('parallaxy')&.to_f || 1.0]

      attributes.add(raw_attributes)

      hash[:children].each do |child|
        case child[:name]
        when 'properties'
          properties.from_xml_hash(child[:children])
        when 'object'
          @objects << TiledObject.new(map, child[:attributes], child[:children])
        end
      end

      self
    end

    def [](id)
      objects.find { |o| o.id == id }
    end

    def properties
      @properties ||= Properties.new(self)
    end

    # @return [Boolean] whether or not the layer is visible
    def visible?
      visible
    end

    def sprites
      []
    end

    def animated_sprites
      []
    end

    # Renders the objects to the `outputs_layer`.
    # @param args [GTK::Args] `args` from `tick` method
    # @param target [Symbol] the output target, either :primitives or :debug
    def render(args, target=:primitives)
      return unless visible?

      outputs_layer = target.is_a?(Symbol) ? args.outputs.send(target) : target

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
            r: 255, g: 255, b: 255
          }
        end

        args.state.tiled_circle_initialized = true
      end

      objects.each do |object|
        case object.object_type
        when :tile
          outputs_layer << Sprite.from_tiled(map.find_tile(object.gid),
                                             x: object.x, y: object.y,
                                             w: object.width, h: object.height)
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
            **color.to_h, a: color.a * 0.7
          }
        when :polygon
          target = :"polygon#{object.id}"

          # The points on the polygon can go below zero, but we can't render to pixel < 0
          # on a render target. We'll need these to calculate some offsets
          min_x = object.points.map(&:x).min
          min_y = object.points.map(&:y).min

          args.state.polygon_cached ||= {}
          unless args.state.polygon_cached[target]
            # Calculate the starting point of the polygon
            offset = [object.points[0].x * 2 - min_x + 1, object.points[0].y * 2 - min_y + 1]

            # Similar to the circle, this is drawn as a bunch of horizontal lines
            object.height.to_i.times do |y|
              # We need to get the intersections where a horizontal line
              # across the screen crosses the edges of the polygon
              intersections = []

              y += min_y

              object.points.each_with_index do |point, index|
                next_point = object.points[(index + 1) % object.points.length]

                # We're iterating over each line of the polygon. This if statement
                # will hit on each line that intersects the line that we're drawing
                if (point.y <= y && next_point.y > y) || (next_point.y <= y && point.y > y)
                  if point.y == next_point.y
                    # The edge is horizontal, so the intersection is just the
                    # X-coordinate of the point
                    intersections << offset.x + point.x
                  else
                    # Find the X-coordinate where the edge intersects the
                    # row using the equation of the line
                    intersections << offset.x +
                      ((y - point.y) * (next_point.x - point.x) /
                       (next_point.y - point.y)) + point.x
                  end
                end
              end

              # Y-coordinate on the sprite that this line is being drawn
              sprite_y = offset.y + y

              # `intersections` contains every X coordinate where the line that we're drawing
              # crosses the border of the shape we need to draw. In cases like a triangle, there
              # will only be 2 intersections and we can just draw the line between them. But for
              # more complex shapes where there e.g. a bunch of vertical spikes, we will have an
              # (always evenly sized) array that we will need to sort and then iterate over
              # 2 at a time, drawing lines between each slice of 2.
              intersections.sort! if intersections.size > 2

              i = 0
              while i < intersections.length - 1 do
                args.render_target(target).lines << {
                  x: intersections[i], y: sprite_y,
                  x2: intersections[i + 1], y2: sprite_y,
                  **color.to_h, a: color.a * 0.7
                }
                i += 2
              end
            end

            # Draw the outline connecting each point
            object.points.each_with_index do |point, index|
              next_point = object.points[(index + 1) % object.points.length]

              args.render_target(target).lines << {
                x: offset.x + point.x, y: offset.y + point.y,
                x2: offset.x + next_point.x, y2: offset.y + next_point.y,
                **color.to_h
              }
            end

            args.state.polygon_cached[target] = true
          end

          outputs_layer << {
            x: object.x - (object.points[0].x - min_x) - 1,
            y: object.y - (object.points[0].y - min_y) + object.height - 1,
            w: object.width, h: object.height,
            path: target,
            source_x: 0, source_y: 0,
            source_w: object.width, source_h: object.height,
            **color.to_h
          }
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
  end
end
