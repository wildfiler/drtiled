require 'lib/tiled/tiled.rb'

MAPS = [
  "maps/pipo_map.tmx",
  "maps/fishercat_map.tmx",
  "maps/forest_map.tmx",
  "maps/loose_tiles_map.tmx",
  "maps/chunks_map.tmx",
  "maps/right_up_map.tmx",
  "maps/transformations_map.tmx",
]

def tick(args)
  args.state.current_map_index ||= 0
  args.state.loaded_maps ||= {}
  args.state.show_objects ||= false
  args.state.map_rendered ||= false

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
    unless args.state.map_rendered
      map.layers.each do |layer|
        target = render_target_for(args, map, :"map_layer_#{layer.id}")

        if layer.is_a?(Tiled::ObjectLayer)
          layer.render(args, target.primitives)
        else
          target.sprites << layer.sprites
        end
      end

      args.state.map_rendered = true
    end

    map.layers.each do |layer|
      next if layer.animated_sprites.empty?

      target = render_target_for(args, map, :"map_layer_#{layer.id}_animated")
      target.sprites << layer.animated_sprites
    end

    args.outputs.sprites << map.layers.map do |layer|
      next if layer.is_a?(Tiled::ObjectLayer) && !args.state.show_objects

      render_targets = [{ x: 280, y: 0, w: 720, h: 720, path: :"map_layer_#{layer.id}"}]
      render_targets << { x: 280, y: 0, w: 720, h: 720, path: :"map_layer_#{layer.id}_animated"} unless layer.animated_sprites.empty?
      render_targets
    end

    show_prompts(args, map)
  end

  if args.inputs.keyboard.key_down.right
    args.state.current_map_index += 1
    args.state.current_map_index = 0 if args.state.current_map_index > MAPS.length - 1
    args.state.map_rendered = false
  end

  if args.inputs.keyboard.key_down.left
    args.state.current_map_index -= 1
    args.state.current_map_index = MAPS.length - 1 if args.state.current_map_index < 0
    args.state.map_rendered = false
  end

  if args.inputs.keyboard.key_down.o
    args.state.show_objects = !args.state.show_objects
    args.state.map_rendered = false
  end

  args.outputs.labels << {
    x: 10.from_left,
    y: 25.from_bottom,
    text: "#{args.gtk.current_framerate.to_i} fps"
  }.label
end

def render_target_for(args, map, path)
  attributes = map.attributes
  target = args.render_target(path)
  target.clear_before_render = true
  target.width = attributes.width * attributes.tilewidth
  target.height = attributes.height * attributes.tileheight

  target
end

def show_prompts(args, map)
  args.outputs.debug << {
    x: 25,
    y: 0.from_top,
    text: "Currently viewing map: #{MAPS[args.state.current_map_index]}",
    size_enum: 4
  }.label

  args.outputs.debug << {
    x: 25,
    y: 25.from_top,
    text: "(press left/right arrow key to swap)"
  }.label

  unless map.object_groups.empty?
    args.outputs.debug << {
      x: 25,
      y: 720 - 75,
      text: "(press 'o' to show objects layer)"
    }.label
  end
end
