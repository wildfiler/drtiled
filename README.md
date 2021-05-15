# DRTiled

![GitHub release (latest by date)](https://img.shields.io/github/v/release/wildfiler/drtiled?label=version&style=plastic)

This is a library for loading Tiled map files in [DragonRuby Game Toolkit](https://dragonruby.org/toolkit/game).

It supports TMX format directly allowing skip exporting to json or csv files step.


## Demo

[![Map updating with DRTiled lib](https://img.youtube.com/vi/RrWJ3s3WA3s/0.jpg)](https://youtu.be/RrWJ3s3WA3s)


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

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.


## Credits

Thanks to [Pipoya](https://pipoya.itch.io) for beautiful arts and sample map used in samples!  

## License
[MIT](https://choosealicense.com/licenses/mit/)
