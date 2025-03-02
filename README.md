# Quality of Exile

## Motivation

Lately, I've been experiencing discomfort in my left pinky from frequently pressing modifier keys. To alleviate this, I created a small script that holds modifier keys (such as CTRL and SHIFT) for me. Over time, I expanded the tool to automate other repetitive tasks, giving my hands a break. My goal is not to automate anything that could compromise the integrity of the game, but simply to make the experience more comfortable and enjoyable without the pain. This tool is intended for anyone who faces similar issues, especially as they deal with the strain that can come with age.

I know this tool is in the gray area, or some might say illegal. There are tools that can achieve same results but not within one tool. You'd have to use multiple tools or even combine them. Morally I don't see the harm for being able to keep playing without discomfort or pain. As long as they don't ban me, I will still keep paying for the supported packs.

## Requirements

- Windows PC
- Path of Exile must be set to Windowed Full Screen

## Installation

Option 1:
- Install [AHK2](https://www.autohotkey.com/)
- Download .zip file for the source codes
- Unpack
- Run QualityOfExile.ahk

Options 2:
- Download .exe file (it will be recognized as virus)
- Run it

## How To Use

To change keybinds press F10 (by default) to open hotkey configuration window. You can change this keybind. You have to press the keybind in-game, this script doesn't recognize anything pressed outside of the game.

### Enter Hideout
Travel to hideout by typing "/hideout".

How to use:
1. Press this keybind (in town)

### Enter League Specific Area
Travel to league specific area by typing e.g. "/kingsmarch".

How to use:
1. Press this keybind (in town)

### Trade Full Stack of Divination Cards
Trade divination cards for items faster.

How to use:
1. Open divination card trade window
2. Hover over full stack of divination cards
3. Press this keybind

### Open Divination Stacked Deck
Picks up one card and drops to the ground. You need to be somewhere that allows to drop loot to the ground. 

1. Hover over divination stacked deck
2. Press this keybind

### Drop Item From Inventory
Drops an item to the ground.

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

The default is: "(\w\W){5}|-\w-.-|(-\w){4}|(-\w){5}|nne|rint|ll g", for any 4-6 links, any 6 socket, any +1 wand and movement speed boots. You can modify the RegExp, so you can have whatever you want.

### Spam Ctrl Click
Holds CTRL and spams left click.

Use cases:
- Rabidly click items to the stash
- Loot items from ground (I don't recommend this, horrible user experience)

### Toggle CTRL
Press keybind once to hold CTRL. Press keybind second time to release CTRL. Meant to be used when you need to use more intent, when moving items between stash and inventory.

Use cases:
- Move items from inventory to stash
- Move items from stash to inventory 

### Toggle SHIFT
Press keybind once to hold SHIFT. Press keybind second time to release SHIFT.

Use cases:
- Use crafting items continuously (e.g. alterations, jewellers, fusings) without needing to hold SHIFT yourself

