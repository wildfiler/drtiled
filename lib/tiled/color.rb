module Tiled
  class Color
    def initialize(r = 0, g = 0, b = 0, a = 0)
      @color = [r, g, b, a]
    end

    def r
      @color[0]
    end

    def g
      @color[1]
    end

    def b
      @color[2]
    end

    def a
      @color[3]
    end

    # Tiled color format is #AARRGGBB
    def self.from_tiled_rgba(string)
      a = Integer(string[1,2], 16)
      r = Integer(string[3,2], 16)
      g = Integer(string[5,2], 16)
      b = Integer(string[7,2], 16)
      new(r, g, b, a)
    end

    def serialize
      {
        r: r,
        g: g,
        b: b,
        a: a,
      }
    end

    def inspect
      "#<#{self.class.name} #{to_s} >"
    end

    def to_s
      "##{@color.map{|v| v.to_s(16)}.join}"
    end

    def to_a
      @color
    end

    def to_h
      serialize
    end
  end
end
