module Tiled
  class LayerData
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :layer, :tiles
    attributes :encoding, :compression

    def initialize(layer)
      @layer = layer
    end

    # TODO: Add tile and chunk support
    def from_xml_hash(hash)
      attributes.add(hash[:attributes])
      unsupported_encoding if encoding != 'csv'
      hash[:children].each do |child|
        if child[:type] == :content
          @tiles = case encoding
          when 'csv'
            parse_csv(child[:data])
          end
        end
      end
    end

    def exclude_from_serialize
      super + %w[layer tiles]
    end

    private

    def parse_csv(csv)
      csv.lines.map do |line|
        line.strip.split(',').map(&:to_i)
      end
    end

    def unsupported_encoding
      raise UnsupportedEncoding, "Layer #{layer.name} has unsupported encoding: #{encoding}"
    end
  end
end
