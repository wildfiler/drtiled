module Tiled
  module Gid
    FLIPPED_HORIZONTALLY_FLAG = 0x80000000
    FLIPPED_VERTICALLY_FLAG = 0x40000000
    FLIPPED_DIAGONALLY_FLAG = 0x20000000
    ROTATED_HEXAGONAL_120_FLAG = 0x10000000

    FLAGS_MASK = 0xF0000000
    MASK = 0x0FFFFFFF

    def flags?(gid)
      only_flags(gid).positive?
    end
    module_function :flags?

    def flags(gid)
      (@flags ||= {})[only_flags(gid)] ||= Flags.new(gid)
    end
    module_function :flags

    def without_flags(gid)
      gid & MASK
    end
    module_function :without_flags

    def only_flags(gid)
      gid & FLAGS_MASK
    end
    module_function :only_flags
  end
end
