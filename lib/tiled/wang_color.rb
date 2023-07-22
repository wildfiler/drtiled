module Tiled
  class WangColor
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :wangset

    attributes :name, :color, :tile, :probability

    def initialize(wangset)
      @wangset = wangset
    end

    def from_xml_hash(hash)
      raw_attributes = hash[:attributes]
      tile_id = raw_attributes.delete('tile')&.to_i
      color = Color.from_tiled_rgba(raw_attributes.delete('color'))
      probability = raw_attributes.delete('probability')&.to_f

      attributes.add(
        tile: wangset.tileset.find(tile_id),
        color: color,
        probability: probability,
        **raw_attributes
      )
    end

    def exclude_from_serialize
      super + %w[wangset]
    end
  end
end
