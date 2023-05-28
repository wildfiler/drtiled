module Tiled
  class ObjectRef
    def initialize(gid, map)
      @gid = gid
      @map = map
    end

    def object
      @object ||= @map.layers.find do |layer|
        if layer.is_a?(ObjectLayer)
          object = layer[@gid]
          break object if object
        end
      end
    end
  end
end
