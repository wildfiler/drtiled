require 'lib/tiled/tiled.rb'

def tick(args)
  if args.state.tick_count.zero?
    map = Tiled::Map.new("maps/pipo_map/samplemap.tmx")
    map.load
    args.state.map = map
    target = args.render_target(:map)
    attributes = map.attributes
    target.width = attributes.width.to_i * attributes.tilewidth.to_i
    target.height = attributes.height.to_i * attributes.tileheight.to_i
    target.sprites << map.layers.map(&:sprites)
  end

  args.outputs.sprites << [(1280 - 720)/2, 0, 720, 720, :map]
end
