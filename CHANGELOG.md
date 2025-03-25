# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
-

### Changed
-

### Fixed
-

### Removed
- 

## [0.1.0-beta.5] - 2025-03-25

### Fixed
- Resolved an issue saved pixel was not loaded properly.

## [0.1.0-beta.4] - 2025-03-25

### Changed
- Improved error handling to prevent the application from crashing if `Client.txt` is not found.
- Enhanced support for standalone Path of Exile installations by locating `Client.txt` dynamically.

### Fixed
- Resolved an issue where pressing a keybind without setting a pixel value caused errors.
- Resolved an issue where mouse moved very slowly when pressing a keybing.

## [0.1.0-beta.3] - 2025-03-25

### Added
- Hotkeys for crafting orbs.
- Pixel selection for hotkeys (e.g., divination card trading and crafting orbs).
- Automatic enabling/disabling of hotkeys by reading the `Path of Exile Client.txt` log file.
- Overlay support for windowed mode.

### Changed
- Certain hotkeys are now active only in the hideout.
- Instance entry hotkeys (e.g., "Enter Hideout") can now be pressed while modifier keys are toggled.
- Divination card trading now uses pixel-based selection for improved compatibility across different resolutions.
- Configuration Window layout.

### Fixed
- Pressing the `TAB` key no longer acts as `ALT+TAB`.
- Overlay no longer blocks mouse clicks.

## [0.1.0-beta.2] - 2025-03-04
### Added
- Screen size templates for 1920x1080, 2560x1440 and 5120x1440
- Link to this Github web page
- Script version to configuration window
- Kill switch keybind

### Changed
- Split GameInfo object to it's own file.
- CenterUI checkbox is disabled if playing in a resolution that does not support it
- Disable tooltips for now

### Fixed
- Issue with CenterUI checkbox not syncing properly
- Issue when shipment values are not loaded when pressing save

## [0.1.0-beta.1] - 2025-03-02
### Added
- Initial release