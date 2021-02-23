require 'lib/tiled/tiled.rb'

def tick(args)
  if args.state.tick_count == 0
    args.state.map = Tiled::Map.new("maps/map1.tmx")
    args.state.map.load
    args.outputs.static_sprites << args.state.map.layers.first.sprites
  end
end
