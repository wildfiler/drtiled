# DRTiled

![GitHub release (latest by date)](https://img.shields.io/github/v/release/wildfiler/drtiled?label=version&style=plastic)

This is a library for loading Tiled map files in [DragonRuby Game Toolkit](https://dragonruby.org/toolkit/game).

It supports TMX format directly allowing skip exporting to json or csv files step.


## Demo

[![Map updating with DRTiled lib](https://img.youtube.com/vi/RrWJ3s3WA3s/0.jpg)](https://youtu.be/RrWJ3s3WA3s)

## Content

- [Installation](#installation)
- [Usage](#usage)
    * [Accessing layers](#accessing-layers)
    * [Working with tiles](#working-with-tiles)
    * [Loading tilesets from files](#loading-tilesets-from-files)
    * [Rendering sprite from tileset](#rendering-sprite-from-tileset)
- [Running samples](#running-samples)
- [Contributing](#contributing)
- [Credits](#credits)
- [License](#license)

## Installation

1. Create a `lib` directory inside the base directory of your DR game.
2. Copy `lib/tiled` directory to created `lib`.
3. Add `require 'lib/tiled/tiled.rb` to the top of your `app/main.rb` file.


## Usage

This is the simplest way to use library:

```ruby
require 'lib/tiled/tiled.rb'

def tick(args)
  if args.state.tick_count.zero?
    map = Tiled::Map.new("maps/map.tmx")
    map.load
    args.state.map = map
    args.outputs.static_sprites << map.layers.first.sprites
  end
end
```

The tilesets and spritesheets used in map should be placed inside your game dir, for example you should save map files inside map dir and spritesheets inside sprites dir.


### Accessing layers

```ruby
ground_layer = map.layers['ground'] # Get layer by name
collisions_layer = map.layers['collisions']
layer_5 = map.layers.at(5) # Get layer by index

map.layers.select(&:visible?) # Get visible layers
```

### Working with tiles

You can access individual tiles using `#tile_at(x, y)` method.

```ruby
collisions_layer = map.layers['collisions']
if collisions_layer.tile_at(new_x, new_y).properties.passable?
  player.move(new_x, new_y)
end
```

### Loading tilesets from files

Tilesets that referenced in map file are automatically loaded. But if you need to load separate tileset file to use it outside of a map, you can do it using `Tiled::Tileset.load` method. For example:

```ruby
require 'lib/tiled/tiled.rb'

def tick(args)
  if args.state.tick_count.zero?
    tileset = Tiled::Tileset.load('sprites/player.tsx')
    args.state.tileset = tileset

    player_icon_id = 0
    args.outputs.static_sprites << tileset.sprite_at(10, 10, player_icon_id)
    args.state.player = [100, 100]
  else
    args.outputs.sprites << tileset.sprite_at(args.state.player.x, args.state.player.y, 2)
  end
end
```

### Rendering sprite from tileset

No matter how tileset was loaded, you can use `sprite_at` method to render tile in desirable location by tile id:

```ruby
args.outputs.sprites << tileset.sprite_at(100, 200, 42)
args.outputs.sprites << map.tilesets.first.sprite_at(200, 300, 42)
```

### Using objects

Object layers can be found using `Map#layers` as well.

```ruby
object_layer = map.layers['object'] # Get it the same as any other layer

collision_layer = map.layers['collision']
collision_layer.objects.each do |hitbox|
  if player_primitive.intersect_rect?([hitbox.x, hitbox.y, hitbox.width, hitbox.height])
    # handle collision...
  end
end

object_layer.render(args) # Renders to args.outputs.primitives
collision_layer.render(args, :debug) # Renders to args.outputs.debug
```

`#type` will give you one of the following:

 * `:rectangle`: The object has `x`, `y`, `width`, and `height` attributes
 * `:ellipse`: Same attributes as rectangle
 * `:polygon`: Has `x`, `y`, and a `points` attribute containing an array of
               points relative to the [x, y] point
 * `:point`: Has `x` and `y` attributes
 * `:tile`: Has `gid`, `x`, `y`, `width`, and `height` attributes

## Running samples

```bash
# clone drtiled somewhere
./dragonruby /path/to/drtiled
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.


## Credits

- Thanks to [Pipoya](https://pipoya.itch.io) for beautiful arts and sample map used in samples!  
- [Kenney Simplified Platformer Pack](https://www.kenney.nl/assets/simplified-platformer-pack) used for loose tiles map sample

## License
[MIT](https://choosealicense.com/licenses/mit/)
