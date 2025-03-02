# Quality of Exile

## Motivation

Lately, I've been experiencing discomfort in my left pinky from frequently pressing modifier keys. To alleviate this, I created a small script that holds modifier keys (such as CTRL and SHIFT) for me. Over time, I expanded the tool to automate other repetitive tasks, giving my hands a break. My goal is not to automate anything that could compromise the integrity of the game, but simply to make the experience more comfortable and enjoyable without the pain. This tool is intended for anyone who faces similar issues, especially as they deal with the strain that can come with age.

I know this tool is in the gray area, or some might say illegal. There are tools that can achieve same results but not within one tool. You'd have to use multiple tools or even combine them. Morally I don't see the harm for being able to keep playing without discomfort or pain. As it allows me to enjoy the game, that I might otherwise need to drop out.

That said, use at your own risk! While the tool is designed to ease the strain on your hands, I can't guarantee anything.

## Requirements

- Windows PC
- Path of Exile must be set to Windowed Full Screen

## Caveats

The tool should work with Path of Exile 2, but it has not been tested.

## Installation

Option 1:
- Install [AHK2](https://www.autohotkey.com/)
- Download .zip file for the source codes
- Unpack
- Run QualityOfExile.ahk

Option 2:
- Download .exe file (it will be recognized as virus)
- Run it

## How To Use

To change keybinds, press F10 (default) to open the hotkey configuration window. You can customize this keybind to your preference. Note that the keybind must be pressed in-game, as this script doesn't recognize keys pressed outside of the game.

### Enter Hideout
Travel to hideout by typing "/hideout".

How to use:
1. Press this keybind (in town)

### Enter League Specific Area
Travel to league specific area by typing e.g. "/kingsmarch".

How to use:
1. Press this keybind (in town)

### Trade Full Stack of Divination Cards
Trade divination cards for items.

How to use:
1. Open divination card trade window
2. Hover over full stack of divination cards
3. Press this keybind

### Open Divination Stacked Deck
Picks up one card and drops to the ground. You need to be in a location that allows you to drop loot. 

1. Hover over divination stacked deck
2. Press this keybind

### Drop Item From Inventory
Drops an item to the ground. You need to be in a location that allows you to drop loot.

1. Hover over item in inventory
2. Press this keybind

### Fill Shipments
Automatically fill the numerical values for shipments.

1. Select the first value of shipments table (Crimson Iron Ore)
2. Press this keybind

### Enter RegExp To Shop
Enters RegExp to the shop's search bar.

1. Open shop
2. Press this keybind

The default RegExp is: "(\w\W){5}|-\w-.-|(-\w){4}|(-\w){5}|nne|rint|ll g". This targets any 4-6 linked items, any 6-socket items, any +1 wand, and movement speed boots. You can modify the RegExp, so you can have whatever you want.

### Spam Ctrl Click
Holds CTRL and spams left click.

Use cases:
- Rabidly move items to the stash
- Loot items from ground (I don't recommend this, horrible user experience)

### Toggle CTRL
Press the keybind once to hold CTRL. Press it again to release CTRL. This is useful when you need more precision when moving items between stash and inventory.

Use cases:
- Move items from inventory to stash
- Move items from stash to inventory 

### Toggle SHIFT
Press the keybind once to hold SHIFT. Press it again to release SHIFT.

Use cases:
- Use crafting items continuously (e.g. alterations, jewellers, fusings) without needing to hold SHIFT yourself

