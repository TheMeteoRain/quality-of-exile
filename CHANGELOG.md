# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.1.0-beta.15](https://github.com/TheMeteoRain/quality-of-exile/compare/v0.1.1-beta.14...v0.1.0-beta.15) (2025-06-02)


### Miscellaneous Chores

* release 0.1.0-beta.15 ([103dd1e](https://github.com/TheMeteoRain/quality-of-exile/commit/103dd1e56d7c08ea56ef7e7b2cd415cdb587511b))

## [0.1.1-beta.14](https://github.com/TheMeteoRain/quality-of-exile/compare/v0.1.0-beta.14...v0.1.1-beta.14) (2025-06-02)


### Bug Fixes

* Stop checking for updates if application was gracefully reloaded ([44d1c01](https://github.com/TheMeteoRain/quality-of-exile/commit/44d1c014ac0ef8fe30b382c52975bd1d4dac343d))

## [0.1.0-beta.14](https://github.com/TheMeteoRain/quality-of-exile/compare/v0.1.0-beta.13...v0.1.0-beta.14) (2025-06-02)


### Features

* Add master keybind to activate/deactivate other keybinds ([56ee1e7](https://github.com/TheMeteoRain/quality-of-exile/commit/56ee1e7ee4c0910e5873cf651e3966ddd838884e))
* Add weapon dps calculation ([16d7ee9](https://github.com/TheMeteoRain/quality-of-exile/commit/16d7ee91ece654c2c45a51fc8a382da4210ca1ef))
* Prettify overlay UI ([a60427e](https://github.com/TheMeteoRain/quality-of-exile/commit/a60427e8baf658385191ec4c9c070c8502a0bac3))


### Bug Fixes

* Add waiting in-between copy and pasting ([9585b05](https://github.com/TheMeteoRain/quality-of-exile/commit/9585b054e2f1908f4daaaf11350e99b7551b97d7))
* Issue with fetching latest version ([c21af8a](https://github.com/TheMeteoRain/quality-of-exile/commit/c21af8a35e17302b8c15fab7c5bf93d782694506))
* Rename Master hotkey ([73714c3](https://github.com/TheMeteoRain/quality-of-exile/commit/73714c30da7500e11ce2a12db123616ddb015980))
* Rename tabs to prevent confusion ([d94bcf8](https://github.com/TheMeteoRain/quality-of-exile/commit/d94bcf8bb52c4dd37fe0f39fe357bbf46e2fcbb1))
* Show splash screen once program is running as admin ([5e804ad](https://github.com/TheMeteoRain/quality-of-exile/commit/5e804ad226f7987daa854786e1f5961dc6685bd0))


### Miscellaneous Chores

* release 0.1.0-beta.14 ([6342582](https://github.com/TheMeteoRain/quality-of-exile/commit/63425826b14498e9421c0e90a530738b8e7850d1))

## [0.1.0-beta.13](https://github.com/TheMeteoRain/quality-of-exile/compare/v0.1.0-beta.12...v0.1.0-beta.13) (2025-05-30)


### Features

* Running application again will kill the previous process ([1c0a69f](https://github.com/TheMeteoRain/quality-of-exile/commit/1c0a69fde8f5c75aa76c5036c12b1c2590a5264d))

## [0.1.0-beta.12](https://github.com/TheMeteoRain/quality-of-exile/compare/v0.1.0-beta.11...v0.1.0-beta.12) (2025-05-29)


### Miscellaneous Chores

* release 0.1.0-beta.12 just to test self updating functionality ([cddd417](https://github.com/TheMeteoRain/quality-of-exile/commit/cddd4173a937eb5b899445665e2c684f799cd010))

## [0.1.0-beta.11](https://github.com/TheMeteoRain/quality-of-exile/compare/v0.1.0-beta.8...v0.1.0-beta.11) (2025-05-29)


### Features

* Self update scripts when detecting new versions ([fbe52ea](https://github.com/TheMeteoRain/quality-of-exile/commit/fbe52ea9ed15fe067974e10fd5e3536f6aba3765))


### Bug Fixes

* Compare versions strictly to avoid issues ([f878dc1](https://github.com/TheMeteoRain/quality-of-exile/commit/f878dc1650e997a3da514d1d585b36cdec864744))
* Handle .ahk self updating process correctly ([bcdbc15](https://github.com/TheMeteoRain/quality-of-exile/commit/bcdbc1582482f0f0058678c20c7821ffc30b7a5b))
* Remove gif images from main branch ([49273a2](https://github.com/TheMeteoRain/quality-of-exile/commit/49273a2a5b90245f58b8f585df0253f762044d0b))
* Use correct tab value ([ac9571c](https://github.com/TheMeteoRain/quality-of-exile/commit/ac9571c9c0f54ccef93ac9ffceaee8046bf74eef))
* Random occurence of character moving instead of dropping an item or dropping stacked deck.
* Multi monitor setup calculations.


### Miscellaneous Chores

* release 0.1.0-beta.10 ([aa02d69](https://github.com/TheMeteoRain/quality-of-exile/commit/aa02d699cf8cf6d304445bbd59afebee2c068e25))

## [0.1.0-beta.10] - 2025-05-28

### Added
- Multi game support. Added hotkeys for Last Epoch.

### Changed
- Updated README.md

### Fixed
- Random occurence of character moving instead of drop item and opening stacked deck macro executing properly.
- Multi monitor setup calculations.

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
