# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
-

### Changed
- 

### Fixed
- Random occurence of character moving instead of drop item and opening stacked deck macro executing properly.
- Multi monitor setup calculations.

### Removed
- 

## [0.1.0-beta.9] - 2025-04-01

### Added
- Character counter for RegExp textbox.
- Support for running game in windowed mode.
- Support for running game in another monitor.

### Changed
- More checks for Dynamic Hotkeys, so they would function properly.

## [0.1.0-beta.8] - 2025-03-30

### Added
- Introduced a debounce mechanism for hotkeys to prevent accidental multiple triggers, ensuring correct execution of hotkey actions.

### Fixed
- Stop reading `Client.txt` when game does not exist or is not active.
- Hide all overlays when game does not exist or is not active.

## [0.1.0-beta.7] - 2025-03-29

### Added
- Introduced a logout macro for quick character logout.
- Enabled rebinding of SHIFT and CTRL modifier keys.
- Added the ability to reposition the toggle overlay.

### Changed
- Currency hotkeys now function correctly even when a modifier key is toggled.
- The toggle overlay now defaults to the bottom-right corner of the game.
- Improved the overall UI layout for better clarity and usability.
- The script now requires administrative privileges to run properly, primarily due to the logout macro functionality.

### Fixed
- Resolved an issue where custom RegExp values were not being saved correctly.
- Fixed a bug where Ctrl Click Spam was not properly canceled when another toggle was activated.

## [0.1.0-beta.6] - 2025-03-26

### Added
- Enhanced documentation to provide clearer explanations of all features.
- PoE2: Added support for reading `Path of Exile 2 Client.txt` to enable Dynamic Hotkeys based on the player's current location.
- Disabled mouse movement when pressing a hotkey that requires mouse input, ensuring precise execution of actions.
- Added safeguards to prevent hotkey failures from interrupting the user's keyboard or mouse input.

### Changed
- PoE1: Dynamic Hotkeys work now on all towns not only in hideouts.

### Fixed
- Resolved an issue where Dynamic Hotkeys would remain disabled after being toggled off once. They now properly enable and disable as expected.
- Tooltip texts when selecting a pixel.

### Removed
- Extra MsgBox when selecting a pixel.

## [0.1.0-beta.5] - 2025-03-25

### Fixed
- Fixed an issue where saved pixel values were not loaded correctly.
- Fixed an issue where the Shop RegExp functionality was not working as expected.

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