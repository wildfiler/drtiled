module Tiled
  class Color
    def initialize(r = 0, g = 0, b = 0, a = 255)
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
      return new unless string

      string = string[1..-1] if string.start_with?('#')
      if string.length == 4
        a = Integer(string[0, 2], 16)
        r = Integer(string[2, 2], 16)
        g = Integer(string[4, 2], 16)
        b = Integer(string[6, 2], 16)
      else
        a = 255
        r = Integer(string[0, 2], 16)
        g = Integer(string[2, 2], 16)
        b = Integer(string[4, 2], 16)
      end

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
      "##{@color.map{|v| sprintf("%02x", v)}.join}"
    end

    def to_a
      @color
    end

    def to_h
      serialize
    end
  end
end
