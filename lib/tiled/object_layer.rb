module Tiled
  class ObjectLayer
    ELLIPSE_RADIUS = 300
    ELLIPSE_DIAMETER = ELLIPSE_RADIUS * 2

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
          @objects << MapObject.new(map, child[:attributes], child[:children])
        end
      end

      self
    end

    def [](id)
      objects.find { |o| o.id == id }
    end

    def find_by_name(name)
      objects.find { |object| object.name == name }
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

    def collision_objects
      []
    end

    # Renders the objects to the `outputs_layer`.
    # Deprecated: This method will be removed, sooner or later. Beware becoming dependent on it.
    # @param args [GTK::Args] `args` from `tick` method
    # @param target [Symbol] the output target, either :primitives or :debug
    def render(args, target=:primitives)
      return unless visible?

      cache_ellipse(args)
      outputs_layer = target.is_a?(Symbol) ? args.outputs.send(target) : target

      if map.orientation == 'isometric'
        render_isometric(args, outputs_layer)
      else
        render_orthogonal(args, outputs_layer)
      end
    end

    def render_orthogonal(args, outputs_layer)
      objects.each do |object|
        next unless object.visible?

        case object.object_type
        when :tile
          outputs_layer << Sprite.from_tiled(
            map.find_tile(object.gid),
            x: object.x, y: object.y,
            w: object.width, h: object.height
          )
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
            path: :drtiled_ellipse,
            source_x: 0, source_y: 0,
            source_w: ELLIPSE_DIAMETER, source_h: ELLIPSE_DIAMETER,
            **color.to_h, a: color.a * 0.7
          }
        when :polygon
          target = :"drtiled_polygon#{object.id}"

          points = object.points
          min_x = points.map(&:x).min
          min_y = points.map(&:y).min

          cache_polygon(args, points, target)

          outputs_layer << {
            x: object.x - (points[0].x - min_x) - 1,
            y: object.y - (points[0].y - min_y) + object.height - 1,
            w: object.width, h: object.height,
            path: target,
            source_x: 0, source_y: 0,
            source_w: object.width, source_h: object.height,
            **color.to_h
          }
        when :point
          size = 10
          outputs_layer << {
            x: object.x - size.half, y: object.y - size.half,
            w: size, h: size,
            path: :drtiled_ellipse,
            source_x: 0, source_y: 0,
            source_w: ELLIPSE_DIAMETER, source_h: ELLIPSE_DIAMETER,
            **color.to_h
          }
        end
      end
    end

    def render_isometric(args, outputs_layer)
      objects.each do |object|
        next unless object.visible?

        object_x, object_y = iso_coords(object.x, object.y)

        case object.object_type
        when :tile
          outputs_layer << map.sprite_class.from_tiled(
            map.find_tile(object.gid),
            x: object_x - object.width.half, y: object_y + (map.pixelheight - object.height) / 2,
            w: object.width, h: object.height
          )
        when :rectangle
          points = [
            [0, 0],
            iso_coords(object.width, 0),
            iso_coords(object.width, object.height),
            iso_coords(0, object.height),
          ]

          render_target = :"rectangle#{object.id}"
          cache_polygon(args, points, render_target)

          min_x, max_x = points.map(&:x).minmax
          min_y, max_y = points.map(&:y).minmax
          width = max_x - min_x
          height = max_y - min_y

          anchor_y = object_y + (map.pixelheight + object.height) / 2 - height

          outputs_layer << {
            x: object_x,
            y: anchor_y,
            w: width + 2,
            h: height + 2,
            path: render_target,
            source_x: 0, source_y: 0,
            source_w: width + 2,
            source_h: height + 2,
            **color.to_h
          }
        when :ellipse
          target = :"drtiled_ellipse#{object.id}"
          points = [
            [0,0],
            iso_coords(0, -object.width),
            iso_coords(object.height, -object.width),
            iso_coords(object.height, 0),
          ]

          min_x, max_x = points.map(&:x).minmax
          min_y, max_y = points.map(&:y).minmax
          width = max_x - min_x
          height = max_y - min_y

          cache_isoellipse(args, target, object, points)

          anchor_x = object_x + object.height
          anchor_y = object_y + (object.height + map.pixelheight) / 2

          outputs_layer.sprites << {
            x: anchor_x - max_x, y: anchor_y - height,
            w: width, h: height,
            path: target,
            source_x: 0, source_y: 0,
            source_w: width, source_h: height,
            **color.to_h, a: color.a * 0.7,
          }
        when :polygon
          points = object.points.map { |point| iso_coords(point.x, point.y) }

          target = :"drtiled_polygon#{object.id}"
          cache_polygon(args, points, target)

          min_x, max_x = points.map(&:x).minmax
          min_y, max_y = points.map(&:y).minmax
          width = max_x - min_x
          height = max_y - min_y

          anchor_x = object_x + object.height + min_x
          anchor_y = object_y + (object.height + map.pixelheight) / 2 + min_y

          outputs_layer << {
            x: anchor_x,
            y: anchor_y,
            w: width + 2, h: height + 2,
            path: target,
            source_x: 0, source_y: 0,
            source_w: width + 2, source_h: height + 2,
            **color.to_h
          }
        when :point
          size = 10
          outputs_layer << {
            x: object_x - (size / 2.0), y: object_y + (map.pixelheight - size) / 2,
            w: size, h: size,
            path: :drtiled_ellipse,
            source_x: 0, source_y: 0,
            source_w: ELLIPSE_DIAMETER, source_h: ELLIPSE_DIAMETER,
            **color.to_h
          }
        end
      end
    end

    private

    def cache_ellipse(args)
      return true if args.state.tiled_circle_initialized

      # Resolution of circle
      radius = 300
      diameter = 2 * radius

      # Draw a circle by iterating over the diameter and drawing a bunch
      # of lines that get wider as they reach the center
      diameter.times do |i|
        height = i - radius
        length = Math::sqrt(radius * radius - height * height)
        args.render_target(:drtiled_ellipse).lines << {
          x: i, y: radius - length, x2: i, y2: radius + length,
          r: 255, g: 255, b: 255
        }
      end

      args.state.tiled_circle_initialized = true
    end

    def cache_isoellipse(args, target, object, points)
      min_x, max_x = points.map(&:x).minmax
      min_y, max_y = points.map(&:y).minmax
      width = max_x - min_x
      height = max_y - min_y

      diameter_y = object.height
      diameter_x = object.width

      radius_y = diameter_y.half
      radius_x = diameter_x.half
      radius_x2 = radius_x * radius_x
      radius_y2 = radius_y * radius_y
      radius2_ratio = radius_x2 / radius_y2
      diff = object.height - object.width

      rt = args.render_target(target)
      rt.width = width
      rt.height = height

      lines = diameter_y.times.map do |y|
        length = Math.sqrt(radius2_ratio * (radius_y2 - (radius_y - y) * (radius_y - y)))
        p1 = iso_coords(-length, y)
        p2 = iso_coords(+length, y)

        {
          x: p1.x + radius_x, y: p1.y + radius_y / 2 - diff / 4,
          x2: p2.x + radius_x, y2: p2.y + radius_y / 2 - diff / 4,
          r: 255, g: 255, b: 255
        }
      end

      rt.lines << lines
      return height, max_x, width
    end

    def cache_polygon(args, points, target)
      args.state.polygon_cached ||= {}
      return if args.state.polygon_cached[target]

      min_x = points.map(&:x).min
      min_y, max_y = points.map(&:y).minmax

      height = max_y - min_y + 2

      # Calculate the starting point of the polygon
      offset = [points[0].x * 2 - min_x + 1, points[0].y * 2 - min_y + 1]

      # Similar to the circle, this is drawn as a bunch of horizontal lines
      height.to_i.times do |y|
        # We need to get the intersections where a horizontal line
        # across the screen crosses the edges of the polygon
        intersections = []

        y += min_y

        points.each_with_index do |point, index|
          next_point = points[(index + 1) % points.length]

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
            **color.to_h, a: color.a * 0.7,
            g: 255,
          }
          i += 2
        end
      end

      # Draw the outline connecting each point
      points.each_with_index do |point, index|
        next_point = points[(index + 1) % points.length]

        args.render_target(target).lines << {
          x: offset.x + point.x, y: offset.y + point.y,
          x2: offset.x + next_point.x, y2: offset.y + next_point.y,
          **color.to_h
        }
      end

      # args.render_target(target).background_color = [0, 0, 255, 200]
      args.state.polygon_cached[target] = true
    end

    def iso_coords(x, y)
      [
        (x + y),
        (y - x) / 2
      ]
    end
  end
end
