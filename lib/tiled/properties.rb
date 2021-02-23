module Tiled
  class Properties
    include Tiled::Serializable

    def initialize(map)
      @map = map
    end

    def add(name, type, value)
      instance_variable_set("@#{name}", value)
      instance_variable_set("@#{name}_type", type)
      define_singleton_method(name) { instance_variable_get(:"@#{name}") }
      define_singleton_method("@#{name}_type") { instance_variable_get(:"@#{name}_type") }
    end

    def from_xml_hash(hash)
      hash.each do |prop|
        next unless prop[:name] == 'property'

        attributes = prop[:attributes]
        type = attributes['type'] || 'string'
        value = convert_value(prop[:children], attributes['value'], type)

        add(attributes['name'], type, value)
      end
    end

    private

    def convert_value(children, raw_value, type)
      case type
      when 'int'
        raw_value.to_i
      when 'float'
        raw_value.to_f
      when 'bool'
        raw_value == 'true'
      when 'color'
        Color.from_tiled_rgba(raw_value)
      when 'object'
        raw_value.to_i
      when 'string'
        if raw_value
          raw_value
        else
          children.map do |child|
            next unless child[:type] == :content
            child[:data]
          end.join('\n')
        end
      else
        raw_value
      end
    end
  end
end
