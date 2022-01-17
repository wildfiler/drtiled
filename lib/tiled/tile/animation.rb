module Tiled
  class Tile
    class Animation
      include Tiled::Serializable

      attr_reader :xml, :tileset, :step, :tiles_ids, :total_frames

      def initialize(tileset)
        @tileset = tileset
      end

      def from_xml_hash(hash)
        hash[:children].each do |child|
          case child[:name]
          when 'frame'
            frame = Frame.new(tileset)
            frame.from_xml_hash(child)
            frames << frame
          end
        end

        # min_duration = frames.map(&:duration).min
        # min_duration_in_frames = (min_duration * 3 / 50).ceil # Convert ms to frames
        durations_in_frames = frames.map(&:duration_in_frames)
        @step = durations_in_frames.reduce { |gcd, n| gcd.nil? ? n : Utils.gcd(gcd, n) }
        @tiles_ids = frames.flat_map { |frame| Array.new(frame.duration_in_frames / step) { frame.tileid } }
        @total_frames = @tiles_ids.length
      end

      def frames
        @frames ||= []
      end

      def current_tile
        tiles_ids[0.frame_index(total_frames, step, true)]
      end
    end
  end
end
