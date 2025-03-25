# Quality of Exile

Feeling strain, exile?

## Motivation

Lately, I've been experiencing discomfort in my left pinky from frequently pressing modifier keys. To alleviate this, I created a small script that holds modifier keys (such as CTRL and SHIFT) for me. Over time, I expanded the tool to automate other repetitive tasks, giving my hands a break. My goal is not to automate anything that could compromise the integrity of the game, but simply to make the experience more comfortable and enjoyable without the pain. This tool is intended for anyone who faces similar issues, especially as they deal with the strain that can come with age.

I know this tool is in the gray area, or some might say illegal. There are tools that can achieve same results but not within one tool. You'd have to use multiple tools or even combine them. Morally I don't see the harm for being able to keep playing without discomfort or pain. As it allows me to enjoy the game, something I might otherwise have to give up due to discomfort. And personally I play only HC SSF, so I can't even affect other players.

That said, use at your own risk! The tool is designed to reduce strain on your hands, allowing you to play for longer in a day or over time.

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
- Clone repository
- Install [AHK2](https://www.autohotkey.com/)
- Run QualityOfExile.ahk
- Pull whenever new updates arrive

Option 3:
- Download .exe file (it will be recognized as virus)
- Run it

## How To Use

To change keybinds, press F10 (default) to open the hotkey configuration window. You can customize this keybind to your preference. Note that all the keybinds must be pressed in-game, as this script doesn't recognize keys pressed outside of the game.

### Kill Switch
Kill the tool. In case of there is a bug, you can press this exit the app.
By default: Insert

1. Press this keybind (only keybind that works outside of the game)

### Enter Hideout
Travel to hideout by typing "/hideout".

1. Press this keybind (in town)

### Enter League Specific Area
Travel to league specific area by typing e.g. "/kingsmarch".

1. Press this keybind (in town)

### Trade Full Stack of Divination Cards
Trade divination cards for items.

Setup:
1. Select pixel where the TRADE button is when trade window is open.
2. Select pixel where the ITEM is going to be when trade window is open.

How to use:
1. Open divination card trade window
2. Hover over full stack of divination cards
3. Press this keybind

### Open Stacked Divination Deck
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

### Orb of Transmutation (use on keybind)
Uses Orb of Transmutation on the item you are hovering over. You need to have currency tab open while doing this.

Setup:
1. Select pixel where the Orb of Transmutation is on the currency tab.

How to use:
1. Hover over item in inventory
2. Press this keybind

### Orb of Alteration (use on keybind)
Uses Orb of Alteration on the item you are hovering over. You need to have currency tab open while doing this.

Setup:
1. Select pixel where the Orb of Alteration is on the currency tab.

How to use:
1. Hover over item in inventory
2. Press this keybind

### Orb of Chance (use on keybind)
Uses Orb of Chance on the item you are hovering over. You need to have currency tab open while doing this.

Setup:
1. Select pixel where the Orb of Chance is on the currency tab.

How to use:
1. Hover over item in inventory
2. Press this keybind

### Alchemy Orb (use on keybind)
Uses Alchemy Orb on the item you are hovering over. You need to have currency tab open while doing this.

Setup:
1. Select pixel where the Alchemy Orb is on the currency tab.

How to use:
1. Hover over item in inventory
2. Press this keybind

### Orb of Scouring (use on keybind)
Uses Orb of Scouring on the item you are hovering over. You need to have currency tab open while doing this.

Setup:
1. Select pixel where the Orb of Scouring is on the currency tab.

How to use:
1. Hover over item in inventory
2. Press this keybind

### Chaos Orb (use on keybind)
Uses Chaos Orb on the item you are hovering over. You need to have currency tab open while doing this.

Setup:
1. Select pixel where the Chaos Orb is on the currency tab.

How to use:
1. Hover over item in inventory
2. Press this keybind

### Spam Ctrl Click
Holds CTRL and spams left click. Press it again to stop.

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


## Support
If Quality of Exile has helped you play more comfortably and you'd like to show your appreciation, consider buying me a coffee! The tool doesn't make any HTTP calls, so I can’t track its usage. So, supporting this way is the only way I know it's being used. If you'd like to support the project, please consider starring the project or supporting via the link below.


<a href="https://www.buymeacoffee.com/MeteoRain" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-red.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
