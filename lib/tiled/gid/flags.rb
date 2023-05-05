module Tiled
  module Gid
    class Flags
      def initialize(gid)
        @flipped_horizontally = gid & FLIPPED_HORIZONTALLY_FLAG > 0
        @flipped_vertically = gid & FLIPPED_VERTICALLY_FLAG > 0
        @flipped_diagonally = gid & FLIPPED_DIAGONALLY_FLAG > 0
        @rotated_hexagonal_120 = gid & ROTATED_HEXAGONAL_120_FLAG > 0
      end

      def flipped_horizontally?
        @flipped_horizontally
      end

      def flipped_vertically?
        @flipped_vertically
      end

      def flipped_diagonally?
        @flipped_diagonally
      end

      def rotated_heaxagonal_60?
        @flipped_diagonally
      end

      def rotated_hexagonal_120?
        @rotated_hexagonal_120
      end

      def inspect
        flags = [
          flipped_horizontally? ? 'H' : '_',
          flipped_vertically? ? 'V' : '_',
          flipped_diagonally? ? 'D' : '_',
          rotated_hexagonal_120? ? 'R' : '_'
        ].join
        "#<Tiled::Gid::Flags #{flags}>"
      end

      def to_s
        inspect
      end
    end
  end
end
