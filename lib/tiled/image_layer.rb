module Tiled
  class ImageLayer

    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :map, :image

    attributes :id, :name, :x, :y, :width, :height, :opacity, :visible, :tintcolor, :offset, :parallax, :repeatx, :repeaty

    def initialize(map)
      @map = map
    end

    def from_xml_hash(hash)
      raw_attributes = hash[:attributes]
      raw_attributes['visible'] = raw_attributes['visible'] != '0'
      raw_attributes['offset'] = [raw_attributes.delete('offsetx').to_f,
                                  -raw_attributes.delete('offsety').to_f]
      raw_attributes['parallax'] = [raw_attributes.delete('parallaxx')&.to_f || 1.0,
                                    raw_attributes.delete('parallaxy')&.to_f || 1.0]

      attributes.add(raw_attributes)

      hash[:children].each do |child|
        case child[:name]
        when 'properties'
          properties.from_xml_hash(child[:children])
        when 'image'
          @image = Tiled::Image.new(map)
          image.from_xml_hash(child)
        end
      end

      self
    end

    def visible?
      visible
    end

    def animated_sprites
      []
    end

    def sprites
      return [sprite] unless repeatx || repeaty

      y_times.times.flat_map do |y_index|
        x_times.times.map do |x_index|
          sprite(x_index, y_index)
        end
      end
    end

    def collision_objects
      []
    end

    private

    def sprite(x_index = 0, y_index = 0)
      {
        x: x_index * image.w + offset.x,
        y: map.pixelheight - (y_index + 1) * image.h + offset.y,
        w: image.w,
        h: image.h,
        path: image.path
      }
    end

    def x_times
      return 1 unless repeatx

      (map.pixelwidth / image.w).ceil.to_i + 1
    end

    def y_times
      return 1 unless repeaty

      (map.pixelheight / image.h).ceil.to_i
    end
  end
end