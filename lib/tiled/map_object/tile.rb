module Tiled
  class MapObject
    class Tile < MapObject
      attributes :id, :gid, :x, :y, :width, :height, :name, :type, :object_type, :visible

      def initialize(map, attrs, children)
        super(map, attrs, children)

        attributes.add(
          gid: attrs['gid']&.to_i,
          y: map.pixelheight - attrs['y'].to_f,
        )
      end
    end
  end
end
