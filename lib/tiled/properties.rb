module Tiled
  class Properties
    #  Class for storing custom properties of Tiled map elements.

    include Tiled::Serializable

    def initialize(map)
      @map = map
    end

    # Creates method for accessing new property by name. For boolean type adds `?` method
    #
    # @example
    #   prop = Tiled::Properties.new(map)
    #   prop.add(:visible, 'bool', 'true')
    #   prop.visible? # => true
    #
    # @param name [String, Symbol] name of new property
    # @param type [String, nil] type of property, `string` by default
    # @param value [Integer, Float, Boolean, String] value of added property
    # @return [Tiled::Properties] self
    def add(name, type = 'string', value)
      instance_variable_set("@#{name}", value)
      instance_variable_set("@#{name}_type", type)
      define_singleton_method(name) { instance_variable_get(:"@#{name}") }
      define_singleton_method("#{name}_type") { instance_variable_get(:"@#{name}_type") }
      define_singleton_method("#{name}?") { !!instance_variable_get(:"@#{name}") } if type == 'bool'

      self
    end

    # Initialize properties with data from xml hash
    # @param hash [Hash] hash loaded from xml file of map.
    # @return [Tiled::Property] self
    def from_xml_hash(hash)
      hash.each do |prop|
        next unless prop[:name] == 'property'

        attributes = prop[:attributes]
        type = attributes['type'] || 'string'
        value = convert_value(prop[:children], attributes['value'], type)

        add(attributes['name'], type, value)
      end

      self
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
