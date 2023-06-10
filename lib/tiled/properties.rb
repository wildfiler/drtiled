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
    def add(name, type = 'string', property_type, value)
      name = normalize_name(name)

      instance_variable_set("@#{name}", value)
      instance_variable_set("@#{name}_type", type)
      instance_variable_set("@#{name}_property_type", property_type) if property_type
      define_singleton_method(name) { instance_variable_get(:"@#{name}") }
      define_singleton_method("#{name}_type") { instance_variable_get(:"@#{name}_type") }
      define_singleton_method("#{name}_propery_type") { instance_variable_get(:"@#{name}_propery_type") }
      define_singleton_method("#{name}?") { !!instance_variable_get(:"@#{name}") } if type == 'bool'

      self
    end

    # Initialize properties with data from xml hash
    # @param hash [Hash] hash loaded from xml file of map.
    # @return [Tiled::Properties] self
    def from_xml_hash(hash)
      hash.each do |prop|
        next unless prop[:name] == 'property'

        attributes = prop[:attributes]
        type = attributes['type'] || 'string'
        property_type = attributes['propertytype']
        value = convert_value(prop[:children], attributes['value'], type)

        add(attributes['name'], type, property_type, value)
      end

      self
    end

    # Finds a property by name. For custom properties you can pass nested properties name separated with '.'.
    # @example
    #   tile.properties['light_color'] # => #ffffc2ff (Tiled::Color instance)
    #   tile.properties['sound'] # => #<Tiled::Properties file="sounds/fireplace.mp3", file_type="file", gain=2.0, gain_type="float">
    #   tile.properties['sound.file'] # => "sounds/fireplace.mp3"
    #   tile.properties['sound.gaind'] # => 2.0
    #   prop.visible? # => true
    # @return [Numeric, Boolean, String] if property type string, float, int of boolean.
    # @return [String] if property is a file type
    # @return [Tiled::Color] if property is a color type
    # @return [Tiled::ObjectRef] if property is an object type
    # @return [Tiled::Properties] if property is a custom property type (class)
    # @return [nil] if property not found
    def [](name)
      cached_values[name] ||= if name.include?('.')
        name.split('.').reduce(self) do |value, property_name|
          break if value.nil? || !value.is_a?(Tiled::Properties)
          value[property_name]
        end
      else
        get_property_value(name)
      end
    end

    private

    def get_property_value(name)
      name = normalize_name(name)

      instance_variable_get(:"@#{name}") if respond_to?(name)
    end

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
        ObjectRef.new(raw_value.to_i, @map)
      when 'file'
        Utils.convert_relative_path(@map.path, raw_value)
      when 'string'
        if raw_value
          raw_value
        else
          children.map do |child|
            next unless child[:type] == :content
            child[:data]
          end.join('\n')
        end
      when 'class'
        nested_properties = children.first[:children]
        Tiled::Properties.new(@map).tap do |class_property|
          class_property.from_xml_hash(nested_properties)
        end
      else
        raw_value
      end
    end

    def normalize_name(name)
      name.downcase.gsub(' ', '_')
    end

    def cached_values
      @cached_values ||= {}
    end

    def exclude_from_serialize
      super + %w[cached_values]
    end
  end
end
