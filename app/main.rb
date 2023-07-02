require 'lib/tiled/tiled.rb'

MAPS = [
  "maps/pipo_map.tmx",
  "maps/isometric.tmx",
  "maps/fishercat_map.tmx",
  "maps/forest_map.tmx",
  "maps/loose_tiles_map.tmx",
  "maps/chunks_map.tmx",
  "maps/right_up_map.tmx",
  "maps/transformations_map.tmx",
]

DR_TRANSIENT_API_VERSION = 4.11

def tick(args)
  args.state.current_map_index ||= 0
  args.state.loaded_maps ||= {}
  args.state.show_objects ||= false
  args.state.map_rendered ||= false
  args.state.offset.y ||= 0

  if args.state.loaded_maps.empty?
    args.state.transient_flag = $gtk.version.to_f >= DR_TRANSIENT_API_VERSION

    args.outputs.primitives << {
      x: 25,
      y: 720 - 25,
      text: "Loading maps, please wait..",
      size_enum: 4,
    }.label!

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

    ratio = [1280 / map.pixelwidth, 720 / map.pixelheight].min

    map_width = map.pixelwidth * ratio
    map_height = map.pixelheight * ratio

    args.outputs.sprites << map.layers.map do |layer|
      next if layer.is_a?(Tiled::ObjectLayer) && !args.state.show_objects
      render_targets = [
        {
          x: (1280 - map_width) / 2 + layer.offset.x, y: layer.offset.y * ratio - args.state.offset.y,
          w: map_width, h: map_height,
          path: :"map_layer_#{layer.id}",
        }
      ]
      unless layer.animated_sprites.empty?
        render_targets << {
          x: (1280 - map_width) / 2 + layer.offset.x, y: layer.offset.y * ratio - args.state.offset.y,
          w: map_width, h: map_height,
          path: :"map_layer_#{layer.id}_animated",
        }
      end
      render_targets
    end

    show_prompts(args, map)

    vertical_offset_max = map.layers.map { |layer| layer.offset.y }.max
    if args.inputs.keyboard.up
      args.state.offset.y = (args.state.offset.y + 1).clamp(0, vertical_offset_max)
    end

    if args.inputs.keyboard.down
      args.state.offset.y = (args.state.offset.y - 1).clamp(0, vertical_offset_max)
    end
  end

  if args.inputs.keyboard.key_down.right
    args.state.current_map_index += 1
    args.state.current_map_index = 0 if args.state.current_map_index > MAPS.length - 1
    args.state.map_rendered = false
    args.state.offset.y = 0
  end

  if args.inputs.keyboard.key_down.left
    args.state.current_map_index -= 1
    args.state.current_map_index = MAPS.length - 1 if args.state.current_map_index < 0
    args.state.map_rendered = false
    args.state.offset.y = 0
  end

  if args.inputs.keyboard.key_down.o
    args.state.show_objects = !args.state.show_objects
    args.state.map_rendered = false
  end

  args.outputs.labels << {
    x: 10.from_left,
    y: 25.from_bottom,
    text: "#{args.gtk.current_framerate.to_i} fps"
  }.label!
end

def render_target_for(args, map, path)
  target = args.render_target(path)
  target = target.transient! if args.state.transient_flag
  target.clear_before_render = true
  target.width = map.pixelwidth
  target.height = map.pixelheight

  target
end

def show_prompts(args, map)
  args.outputs.debug << {
    x: 25,
    y: 0.from_top,
    text: "Currently viewing map: #{MAPS[args.state.current_map_index]}",
    size_enum: 4
  }.label!

  args.outputs.debug << {
    x: 25,
    y: 25.from_top,
    text: "(press left/right arrow key to swap)"
  }.label!

  unless map.object_groups.empty?
    args.outputs.debug << {
      x: 25,
      y: 75.from_top,
      text: "(press 'o' to show objects layer)"
    }.label!
  end

  unless map.layers.map { |layer| layer.offset.y }.all? { |offset_y| offset_y.zero? }
    args.outputs.debug << {
      x: 25,
      y: 50.from_top,
      text: "(press up/down arrow key to scroll)"
    }.label!
  end
end
