module Tiled
  module Serializable
    def inspect
      detail = serialize.sort_by(&:first).map do |(key, value)|
        " #{key}=#{value.inspect}"
      end.join(',')
      ['#<', self.class.name, detail, '>'].join
    end

    def to_s
      inspect
    end

    def serialize
      filtered = instance_variables.reject do |var|
        str = var.to_s.gsub('@', '')
        exclude_from_serialize.include? str
      end

      filtered.map do |var|
        str = var.to_s.gsub('@', '')
        [str.to_sym, instance_variable_get(var)]
      end.to_h
    end

    def exclude_from_serialize
      %w[args map hash tileset] # Too much spam or recursion
    end
  end
end
