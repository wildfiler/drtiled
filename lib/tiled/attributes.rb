module Tiled
  class Attributes
    include Tiled::Serializable

    def initialize(hash)
      hash.each do |key, value|
        instance_variable_set(:"@#{key}", value)

        instance_eval(<<-CODE)
          undef :#{key} if respond_to? :#{key}
          def #{key}
            @#{key}
          end
        CODE
      end
    end

    def add(hash)
      hash.each do |key, value|
        instance_variable_set(:"@#{key}", value)
        instance_eval(<<-CODE)
          undef :#{key} if respond_to? :#{key}
          def #{key}
            @#{key}
          end
        CODE
      end
    end
  end
end
