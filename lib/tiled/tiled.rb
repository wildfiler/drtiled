require 'lib/tiled/with_attributes.rb'

require 'lib/tiled/attribute_assignment.rb'
require 'lib/tiled/attributes.rb'
require 'lib/tiled/color.rb'
require 'lib/tiled/image.rb'
require 'lib/tiled/layer.rb'
require 'lib/tiled/layers.rb'
require 'lib/tiled/layer_data.rb'
require 'lib/tiled/map.rb'
require 'lib/tiled/properties.rb'
require 'lib/tiled/serializable.rb'
require 'lib/tiled/sprite.rb'
require 'lib/tiled/tile.rb'
require 'lib/tiled/tileset.rb'
require 'lib/tiled/unknown_attribute.rb'
require 'lib/tiled/utils.rb'

module Tiled
  VERSION = '0.1.0'

  module AttributeAssignment; end
  module Serializable;end
  module Utils; end
  module WithAttributes; end

  class Attributes; end
  class Color; end
  class Image; end
  class Layer; end
  class Layers; end
  class LayerData; end
  class Map; end
  class Properties; end
  class Sprite; end
  class Tile; end
  class Tileset; end

  class UnknownAttribute < NoMethodError; end
  class Error < StandardError; end
  class UnsupportedEncoding < Error; end
end
