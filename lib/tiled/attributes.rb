module Tiled
  class Attributes
    include Tiled::Serializable

    def initialize(hash)
      add hash
    end

    def add(hash)
      hash.each do |key, value|
        instance_variable_set(:"@#{key}", convert_type(value))

        instance_eval(<<-CODE)
          undef :#{key} if respond_to? :#{key}
          def #{key}
            @#{key}
          end
        CODE
      end
    end

    private

    # If `obj` is a String containing a valid Integer or Float, it will be
    # converted to one of those types; otherwise, it well be left alone.
    def convert_type(obj)
      if obj.is_a?(String)
        decimal_split = obj.split('.')
        as_int = obj.to_i

        if decimal_split.size == 2 && decimal_split.all? { |s| check_int s }
          obj.to_f
        elsif as_int.to_s == obj
          as_int
        end
      end || obj
    end

    # @return [Boolean] whether or not `str` is a valid Integer
    def check_int(str)
      # Allow leading zeros by removing them from the string before comparison
      chars = str.chars
      chars.shift while chars.first == '0'
      str.to_i.to_s == chars.join
    end
  end
end
