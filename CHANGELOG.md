# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.1] - 2023-09-18

### Fixed

- Add properties to Tiled::ImageLayer (#61)

## [0.5.0] - 2023-07-22

### Added

- Add support of image layers (#54)
- Add Tiled::Tileset#animated_sprite_at (#55)
- Add wangsets support (#60)

### Changes

- Support for transient RT's (DR 4.11+), minor label! updates (#56)
- Convert backgroundcolor of map to Tiled::Color (#58)

### Fixed

- Remove caching of map data in `Tiled::Map` (#57)
- In `lib/tiled.rb` change require order for sync require in new DR (#59)

## [0.4.0] - 2023-06-25

### Added

- Add support of custom property types (#51)
- Add support of text and polyline objects (#53)

### Fixed

- Fix error when loading map objects with height or width < 1.0 (#46)
- Fix maps and tilesets file existing check (#47)
- Fix NoMethodError in #cache_isoellipse (#48)
- Fix `Layer#collision_objects` method (#49)

## [0.3.0] - 2023-06-03

### Added

- Errors handling on wrong path to files, or incorrect tmx/tsx files (#37)
- File properties support (#38)
- `ObjectRef` for properties with `object` type to lazy reference objects on the map (#38)
- Added properties section to README.md (#38)
- `MapObject#tile` for objects with `tile` type (#39)
- Add `ObjectLayer#find_by_name` to find objects by `name` attributes (#40)
- Add offset attribute to tileset (#42)
- Add visible attribute to objects (#43)
- Add offsets to layer sprites and collisions (#44)
- Isometric map support (#45)

### Changed

- `TiledObject` renamed to `MapObject` (#34)
- Update link to tiledriver lib (#41)

### Fixed

- Typos in README.md (#36)

## [0.2.0] - 2023-05-07

### Added

- Support for 'Collection of Images' tilesets. (#7)
- Support for tile data chunks. (#8)
- Support for right-up render order. (#10)
- Tileset.sprite_at to allow drawing of sprites directly from the tileset. (#12)
- Object layer support. (#15)
- Rendering of object layers.
- Add animations support. (#25)
- Add support for orthogonal transformations for tiles. (#31)
- Add collisions objects to tile. (#32)

### Changed

A lot of changes in README.md.

### Fixed

- Convert attributes to the correct types when initializing objects. (#22)
- Fix TSX relative image paths & reorganize sample assets. (#9)

[Unreleased]: https://github.com/wildfiler/drtiled/compare/v0.5.1...master
[0.5.1]: https://github.com/wildfiler/drtiled/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/wildfiler/drtiled/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/wildfiler/drtiled/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/wildfiler/drtiled/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/wildfiler/drtiled/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/wildfiler/drtiled/releases/tag/v0.1.0
