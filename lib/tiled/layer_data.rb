module Tiled
  class LayerData
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :layer, :tiles
    attributes :encoding, :compression

    def initialize(layer)
      @layer = layer
      @tiles = []
    end

    # TODO: Add tile support
    def from_xml_hash(hash)
      attributes.add(hash[:attributes])

      process_node(hash, 0, 0)
    end

    def exclude_from_serialize
      super + %w[layer tiles]
    end

    private

    def process_node(node, chunk_x, chunk_y)
      if node[:type] == :element
        if node[:name] == 'chunk'
          chunk_x = node[:attributes]['x'].to_i
          chunk_y = node[:attributes]['y'].to_i
        end
        node[:children].each do |child_node|
          process_node(
            child_node,
            chunk_x,
            chunk_y,
          )
        end
      elsif node[:type] == :content
        parse_chunk(node[:data]).each_with_index do |row_data, row_y|
          row_y += chunk_y
          tiles[row_y] ||= []
          tiles[row_y].insert(chunk_x, *row_data)
        end
      end
    end

    def parse_chunk(data)
      case encoding
      when 'csv'
        data.lines.map do |line|
          line.strip.split(',').map(&:to_i)
        end
      else
        raise_unsupported_encoding!
      end
    end

    def raise_unsupported_encoding!
      raise UnsupportedEncoding, "Layer #{layer.name} has unsupported encoding: #{encoding}"
    end
  end
end
