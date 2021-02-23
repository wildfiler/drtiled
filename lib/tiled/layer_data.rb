module Tiled
  class LayerData
    include Tiled::Serializable

    attr_reader :attributes, :layer, :tiles

    def initialize(layer)
      @layer = layer
    end

    # TODO: Add tile and chunk support
    def from_xml_hash(hash)
      @attributes = Attributes.new(hash[:attributes])
      unsupported_encoding if attributes.encoding != 'csv'
      hash[:children].each do |child|
        if child[:type] == :content
          @tiles = case attributes.encoding
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
      raise UnsupportedEncoding, "Layer #{layer.name} has unsupported encoding: #{attributes.encoding}"
    end
  end
end
