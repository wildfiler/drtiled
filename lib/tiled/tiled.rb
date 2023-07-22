module Tiled
  VERSION = '0.4.0'

  module AttributeAssignment; end
  module Serializable;end
  module Utils; end
  module WithAttributes; end
  module Gid
    class Flags; end
  end

  class Attributes; end
  class Color; end
  class Image; end
  class ImageLayer; end
  class Layer; end
  class Layers; end
  class LayerData; end
  class Map; end
  class MapObject
    class Polygon < MapObject; end
    class Polyline < Polygon; end
    class Text < MapObject; end
    class Tile < MapObject; end
  end
  class Properties; end
  class Sprite; end
  class AnimatedSprite < Tiled::Sprite; end
  class Tile;
    class Animation; end
    class Frame; end
  end
  class Tileset; end
  class ObjectLayer; end
  class ObjectRef; end
  class WangColor; end
  class WangSet; end
  class WangTile; end

  class UnknownAttribute < NoMethodError; end
  class Error < StandardError; end
  class UnsupportedEncoding < Error; end
  class UnsupportedRenderOrder < Error; end
  class UnsupportedFeature < Error; end
  class ParseError < Error; end
  class MapNotFound < Error; end
  class TilesetNotFound < Error; end
end

require 'lib/tiled/with_attributes.rb'

require 'lib/tiled/animated_sprite.rb'
require 'lib/tiled/attribute_assignment.rb'
require 'lib/tiled/attributes.rb'
require 'lib/tiled/color.rb'
require 'lib/tiled/gid.rb'
require 'lib/tiled/gid/flags.rb'
require 'lib/tiled/image.rb'
require 'lib/tiled/image_layer.rb'
require 'lib/tiled/layer.rb'
require 'lib/tiled/layers.rb'
require 'lib/tiled/layer_data.rb'
require 'lib/tiled/map.rb'
require 'lib/tiled/map_object.rb'
require 'lib/tiled/map_object/polygon.rb'
require 'lib/tiled/map_object/polyline.rb'
require 'lib/tiled/map_object/text.rb'
require 'lib/tiled/map_object/tile.rb'
require 'lib/tiled/object_layer.rb'
require 'lib/tiled/object_ref.rb'
require 'lib/tiled/properties.rb'
require 'lib/tiled/serializable.rb'
require 'lib/tiled/sprite.rb'
require 'lib/tiled/tile.rb'
require 'lib/tiled/tile/animation.rb'
require 'lib/tiled/tile/frame.rb'
require 'lib/tiled/tileset.rb'
require 'lib/tiled/unknown_attribute.rb'
require 'lib/tiled/utils.rb'
require 'lib/tiled/wang_color.rb'
require 'lib/tiled/wang_set.rb'
require 'lib/tiled/wang_tile.rb'
