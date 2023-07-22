module Tiled
  class WangTile
    include Tiled::Serializable
    include Tiled::WithAttributes

    COLORS_ORDER = %i[top top_right right bottom_right bottom bottom_left left top_left].freeze

    attr_reader :wangset, :tile, :wangid4, *COLORS_ORDER

    attributes :tileid, :wangid

    def initialize(wangset)
      @wangset = wangset
    end

    def from_xml_hash(hash)
      raw_attributes = hash[:attributes]
      tile_id = raw_attributes.delete('tileid')&.to_i
      wangid = raw_attributes.delete('wangid')&.split(',')&.map do |id|
        next if id == '0'

        id.to_i - 1
      end

      attributes.add(
        tileid: tile_id,
        wangid: wangid,
      )

      @tile = wangset.tileset.tiles[tile_id]
      @wangcolors = Array.new(8)
      @wangid4 = wangid.select.with_index { |_, index| index.even? }

      wangid.each.with_index do |id, index|
        next unless id

        color = wangset.colors[id]
        @wangcolors[index] = color
        instance_variable_set("@#{COLORS_ORDER[index]}", color)
      end
    end

    def exclude_from_serialize
      super + %w[wangset tile wangcolors] + COLORS_ORDER.map(&:to_s)
    end
  end
end
