module Tiled
  class UnknownAttribute < NoMethodError
    attr_reader :object, :name

    def initialize(object, name)
      @object = object
      @name = name
      super("unknown attribute '#{name}' for #{@object.class}.")
    end
  end
end
