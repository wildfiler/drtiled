module Tiled
  class Tile
    class Frame
      include Tiled::Serializable
      include Tiled::WithAttributes

      attr_reader :tileset
      attributes :tileid, :duration

      def initialize(tileset)
        @tileset = tileset
      end

      def from_xml_hash(hash)
        attributes.add(hash[:attributes].transform_values(&:to_i))
      end

      def duration_in_frames
        @duration_in_frames ||= (duration * 3 / 50).ceil
      end
    end
  end
end
