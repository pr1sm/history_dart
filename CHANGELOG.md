# Change Log
All notable changes to this project will be documented here.

This project adheres to [Semantic Versioning](http://semver.org/).

## [v1.0.2] - 2019-9-6

### Added
- `pedantic` package as a dev dependency
- recommended analysis options

### Changed
- Updated code to fix analysis lints
  - no functionality is affected

## [v1.0.1] - 2019-9-5

### Changed
- Upgrade dev dependency ranges to prevent build failures
  - mockito (`^3.0.0` -> `^4.0.0`)
  - dartdoc (`^0.20.0` -> `>= 0.24.0 <1.0.0`)
- Fix Analyzer Errors
- Fix missing `await` in README

## [v1.0.0] - 2018-10-19

### Added
- Support for Dart 2!
- Tooling using `build_runner`

### Changed
- Updated examples to work with Dart 2

### Removed
- Support for Dart 1.x

## [v0.2.1] - 2018-7-18

### Changed
- `quiver` dependency loosened 

## [v0.2.0] - 2018-7-15

### Added
- Added Changelog

### Changed
- `Location` how supports a dynamic `state` when using non-default constructor
- `BrowserHistory` how uses `window.confirm` by default when no custom confirmation is passed

## [v0.1.0] - 2018-7-14

### Added
- Initial Release
