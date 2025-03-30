# Quality of Exile

Feeling strained, exile?

## Motivation

For a long time, I've been experiencing discomfort in my left pinky from frequently having to hold modifier keys (CTRL and SHIFT). To alleviate this, I created a small script that toggles modifier keys. Over time, I expanded the tool to hotkey other repetitive tasks to give my hands a break from the constant wrist movements and click spamming. My goal is not to hotkey anything that could compromise the integrity of the game, but simply to make the experience more comfortable (mostly in towns) and enjoyable without the pain. This tool is intended for anyone who faces similar issues, especially as they deal with the strain that can come with age.

Like all tools of this nature, this one also falls into a gray area. There are tools that can achieve same results but not within one tool. You'd have to use multiple tools or even combine them. Morally I don't see the harm for being able to keep playing without discomfort or pain. Personally it allows me to enjoy the game more, something I might otherwise have to give up due to discomfort. I will be expanding the tool and adding features as I encounter them, but again I won't be automating anything. Game is supposed to be played yourself.

That said, use at your own risk! The tool is designed to reduce strain on your hands, allowing you to play comfortably for longer periods, whether in a single session or over time.

## Requirements

- Windows PC

## Caveats

- Game must be on your primary monitor for the overlays to work, other things should work fine.
- Tool should not be started while you are in combat area as Dynamic Hotkeys are enabled by default or visit a town afterwards (read more below).

## Installation

Option 1:
- Install [AHK2](https://www.autohotkey.com/)
- Download [.zip file](https://github.com/TheMeteoRain/quality-of-exile/releases) for the source codes
- Unpack
- Run QualityOfExile.ahk

Option 2:
- Install [AHK2](https://www.autohotkey.com/)
- Clone repository
- Run QualityOfExile.ahk

Option 3:
- Download [.exe file](https://github.com/TheMeteoRain/quality-of-exile/releases) (it will be recognized as virus)
- Run it

## Features
- **Read Local Client.txt File**
  - Leverages the `Client.txt` file from Path of Exile 1 or 2 to enable advanced features.
- **Toggle Modifier Keys**
  - Instead of holding modifier keys (SHIFT and CTRL) continuously, you can toggle them on or off as needed.
  - When toggling modifier keys, an overlay will display their current status. By default, this overlay appears in the bottom-right corner of the game. However, it is recommended to reposition it via the settings. The overlay is designed to fit above your flasks but can be placed anywhere you prefer.
- **Automatic Toggle Reset**
  - Toggles are automatically reset when pressing ALT+TAB, the Windows key, or ESC.
  - Toggles also reset upon entering a new area or when the game window loses focus.
  - Uses local `Client.txt` file.
- **Dynamic Hotkeys**
  - Dynamic Hotkeys allow keys to serve dual purposes based on your current location in the game. 
  - For example, you can assign numbers (1, 2, 3, 4, 5) to Dynamic Hotkeys. In combat areas, these keys perform their default actions (e.g. using flasks). In towns, they execute specific macros (e.g. crafting). This effectively lets you "double-bind" keys for different contexts. This is to combat keybind bloat.
  - Dynamic Hotkeys are clearly marked in the list below.
  - When the tool starts, Dynamic Hotkeys are enabled by default, executing their corresponding macros. It will begin tracking location on the first loading screen.
  - Uses local `Client.txt` file.
- **Pixel Selection**
  - Allows you to select specific pixels where a hotkey will be triggered.
  - Designed to address differences in screen resolutions, ensuring consistent functionality across various setups.
- **In-Game Hotkey Detection**
  - Keybinds are only active while the game is running and in focus.
  - Assigned keybinds will not interfere with other applications or actions outside the game.

## How To Use

To change keybinds, press F10 (default) to open the hotkey configuration window. You can customize this keybind to your preference. Note that all the keybinds must be pressed in-game, as this script doesn't recognize keys pressed outside of the game.

How to reposition toggle overlay:
![setting toggle overlay](assets/overlay.gif)

## Hotkeys

### Logout Macro
Close TCP connections of Path of Exile process.

### Toggle CTRL
Press the keybind once to hold CTRL. Press it again to release CTRL. You can also rebind CTRL to any key you want, maybe you have small macro keypad. My favourite is setting my mouse's side buttons to CTRL and SHIFT. So, I don't have to use pinky at all. 

Use cases:
- Move items from inventory to stash.
- Move items from stash to inventory.
- Pre-toggle before interacting with an NPC to trigger specific actions, such as opening the sell window or identifying items (PoE2:The Hooded One).

### Toggle SHIFT
Press the keybind once to hold SHIFT. Press it again to release SHIFT. You can also rebind SHIFT to any key you want, maybe you have small macro keypad. My favourite is setting my mouse's side buttons to CTRL and SHIFT. So, I don't have to use pinky at all.

Use cases:
- Use crafting items continuously (e.g. alterations, jewellers, fusings) without needing to hold down SHIFT yourself.

### Spam Ctrl Click
Holds CTRL and spams left click. Press it again to stop.

Use cases:
- Rabidly move items to the stash.

### Kill Switch
Kill the tool. In case of there is a bug, you can press this to exit the app.
By default: Home

1. Press the assigned keybind. (only keybind that works outside of the game)

### Enter Hideout
Travel to hideout by typing "/hideout".

1. Press the assigned keybind. (in town)

### Enter League Specific Area
Travel to league specific area by typing e.g. "/kingsmarch".

1. Press the assigned keybind. (in town)

### Orb of Transmutation (Dynamic Hotkey)
Uses Orb of Transmutation on the item you are hovering over. You need to have the currency tab open while doing this.

Setup:
1. Select the pixel where the Orb of Transmutation is located in the currency tab.

How to use:
1. Hover over the item in your inventory.
2. Press the assigned keybind.

### Orb of Alteration (Dynamic Hotkey)
Uses Orb of Alteration on the item you are hovering over. You need to have the currency tab open while doing this.

Setup:
1. Select the pixel where the Orb of Transmutation is located in the currency tab.

How to use:
1. Hover over the item in your inventory.
2. Press the assigned keybind.

### Orb of Chance (Dynamic Hotkey)
Uses Orb of Chance on the item you are hovering over. You need to have the currency tab open while doing this.

Setup:
1. Select the pixel where the Orb of Chance is located in the currency tab.

How to use:
1. Hover over the item in your inventory.
2. Press the assigned keybind.

### Alchemy Orb (Dynamic Hotkey)
Uses Alchemy Orb on the item you are hovering over. You need to have the currency tab open while doing this.

Setup:
1. Select the pixel where the Alchemy Orb is located in the currency tab.

How to use:
1. Hover over the item in your inventory.
2. Press the assigned keybind.

### Orb of Scouring (Dynamic Hotkey)
Uses Orb of Scouring on the item you are hovering over. You need to have the currency tab open while doing this.

Setup:
1. Select the pixel where the Orb of Scouring is located in the currency tab.

How to use:
1. Hover over the item in your inventory.
2. Press the assigned keybind.

### Chaos Orb (Dynamic Hotkey)
Uses Chaos Orb on the item you are hovering over. You need to have the currency tab open while doing this.

Setup:
1. Select the pixel where the Chaos Orb is located in the currency tab.

How to use:
1. Hover over the item in your inventory.
2. Press the assigned keybind.

### Trade Full Stack of Divination Cards
Trade divination cards for items.

Setup:
1. Select the pixel where the TRADE BUTTON is when trade window is open.
2. Select the pixel where the ITEM AREA is when trade window is open.

How to use:
1. Open divination card trade window.
2. Hover over full stack of divination cards.
3. Press the assigned keybind.

### Open Stacked Divination Deck
Picks up one card from a stacked deck and drops it to the ground. This requires being in a location where dropping loot is allowed.

1. Hover over the stacked divination deck in your inventory.
2. Press the assigned keybind.

### Drop Item From Inventory
Drops an item to the ground. You need to be in a location that allows you to drop loot.

1. Hover over the item in your inventory.
2. Press the assigned keybind.

### Fill Shipments
Automatically fill the numerical values for shipments.

Setup:
1. Set the numerical values for each resource.

How to use:
1. Select the first value of shipments table (Crimson Iron Ore).
2. Press the assigned keybind.

### Enter RegExp
Inputs RegExp into any window with search functionality.

1. Open a window with search functionality.
2. Press the assigned keybind.

Default RegExp: `(\w\W){5}|-\w-.-|(-\w){4}|(-\w){5}|nne|rint|ll g`

This default RegExp is designed to target:
- 4-6 linked items.
- 6-socket items.
- +1 wands.
- Movement speed boots.

You can customize the RegExp to suit your specific needs, enabling you to search for items with your own criteria.

## Support
If Quality of Exile has helped you play more comfortably and you'd like to show your appreciation, consider buying me a coffee! P.S. Accidentally spent way too much time on this.


<a href="https://www.buymeacoffee.com/MeteoRain" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-red.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
