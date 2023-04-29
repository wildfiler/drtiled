require 'lib/tiled/tiled.rb'

MAPS = [
  "maps/pipo_map.tmx",
  "maps/fishercat_map.tmx",
  "maps/forest_map.tmx",
  "maps/loose_tiles_map.tmx",
  "maps/chunks_map.tmx",
  "maps/right_up_map.tmx",
]

def tick(args)
  args.state.current_map_index ||= 0
  args.state.loaded_maps ||= {}
  args.state.show_objects ||= false

  if args.state.loaded_maps.empty?
    args.outputs.primitives << {
      x: 25,
      y: 720 - 25,
      text: "Loading maps, please wait..",
      size_enum: 4,
    }.label

    if args.state.tick_count > 1  # 1 so that loading message gets drawn on tick 0
      MAPS.each do |map_path|
        map = Tiled::Map.new(map_path)
        map.load
        args.state.loaded_maps[map_path] = map
      end
    end
  end

  if map = args.state.loaded_maps[MAPS[args.state.current_map_index]]
    target = args.render_target(:map)
    attributes = map.attributes
    target.width = attributes.width.to_i * attributes.tilewidth.to_i
    target.height = attributes.height.to_i * attributes.tileheight.to_i
    target.sprites << map.layers.map(&:sprites)

    if args.state.show_objects && map.layers['objects_test']
      map.layers['objects_test'].render_debug(args, target.debug)
    end

    args.outputs.primitives << {
      x: 25,
      y: 720 - 25,
      text: "Currently viewing map: #{MAPS[args.state.current_map_index]}",
      size_enum: 4
    }.label

    args.outputs.primitives << {
      x: 25,
      y: 720 - 50,
      text: "(press left/right arrow key to swap)"
    }.label

    if map.layers['objects_test']
      args.outputs.primitives << {
        x: 25,
        y: 720 - 75,
        text: "(press 'o' to show objects layer)"
      }.label
    end

    args.outputs.sprites << [(1280 - 720)/2, 0, 720, 720, :map]
  end

  if args.inputs.keyboard.key_down.right
    args.state.current_map_index += 1
    args.state.current_map_index = 0 if args.state.current_map_index > MAPS.length - 1
  end
  if args.inputs.keyboard.key_down.left
    args.state.current_map_index -= 1
    args.state.current_map_index = MAPS.length - 1 if args.state.current_map_index < 0
  end
  if args.inputs.keyboard.key_down.o
    args.state.show_objects = !args.state.show_objects
  end
end
