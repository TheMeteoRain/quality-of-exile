#Requires AutoHotkey v2.0

global LastExecutionTime := {
  TerminateTCP: 0,
  CraftWithCurrency: 0,
  PerformDivinationTrading: 0,
  DropItem: 0,
  OpenStackedDivinationDeck: 0,
  TransferMaterialsWInventory: 0,
  TransferMaterialsWOInventory: 0,
  ShatterItem: 0,
  WeaponDPS: 0,
}
global CtrlToggled := false
global ShiftToggled := false
global ScrollSpam := false
global DPSGui := unset
global clientFilePath, clientFile, clientFileReadFunc
global DynamicHotkeysActivated := false
global DynamicHotkeysState := "OFF"
global RegExpCharacterLimit := 48
global Game := GameInfo()
global mousePos := MousePositionSaver()
global clipboard := ClipboardSaver()
global Hotkeys := Map()
global Extra := Map()
global Options := Map()
global MouseDropdownOptions := [
  "",
  "MButton",
  "XButton1",
  "XButton2"
]
global X_GAP := 175
global Y_GAP := 30
global Configs := {
  EnterHideout: {
    name: "Enter Hideout",
    var: "OpenHideout",
    defaultHotkey: "F5",
    func: OpenHideout,
    blockKeyNativeFunction: true,
    mouseBind: false,
    tooltip: "How to use: press hotkey to enter hideout.",
    toggleOnInstance: false,
    tab: "General",
    section: "Hotkey",
    coords: {
      x: 0,
      y: 0
    },
    game: "PathOfExile",
  },
  EnterKingsmarch: {
    name: "Enter Kingsmarch",
    var: "OpenKingsmarch",
    defaultHotkey: "F6",
    func: OpenKingsmarch,
    blockKeyNativeFunction: true,
    mouseBind: false,
    tooltip: "How to use: press hotkey to enter Kingsmarch.",
    toggleOnInstance: false,
    tab: "General",
    section: "Hotkey",
    coords: {
      x: X_GAP,
      y: 0
    },
    game: "PathOfExile",
  },
  OpenStackedDivinationDeck: {
    name: "Open Stacked Divination Deck",
    defaultHotkey: "",
    func: OpenStackedDivinationDeck,
    blockKeyNativeFunction: true,
    mouseBind: true,
    tooltip: "How to use: hover over the desired divination stack in your inventory and press this hotkey. Only usable in outdoor areas, since you cannot drop cards in hideout or similar areas.",
    toggleOnInstance: false,
    tab: "PoE (2)",
    section: "Hotkey",
    coords: {
      x: X_GAP,
      y: 0
    },
    game: "PathOfExile",
  },
  TradeDivinationCard: {
    name: "Trade Divination Card",
    defaultHotkey: "",
    func: PerformDivinationTrading,
    blockKeyNativeFunction: true,
    extraField: true,
    mouseBind: false,
    tooltip: "How to use: open divination card trade screen and press this hotkey, while hovering over the desired full divination card stack in your inventory.",
    toggleOnInstance: false,
    tab: "PoE (2)",
    section: "Hotkey",
    coords: {
      x: X_GAP * 2,
      y: 0
    },
    pixelSelect: true,
    vars: [
      "TradeDivinationCardButton",
      "TradeDivinationCardItemArea"
    ],
    game: "PathOfExile",
  },
  DropItem: {
    name: "Drop Item From Inventory",
    defaultHotkey: "",
    func: DropItem,
    mouseBind: true,
    blockKeyNativeFunction: true,
    tooltip: "How to use: hover over item in your inventory and press this hotkey.",
    toggleOnInstance: false,
    tab: "PoE (2)",
    section: "Hotkey",
    coords: {
      x: 0,
      y: 0
    },
    game: "PathOfExile",
  },
  FillShipment: {
    name: "Fill Shipments",
    var: "FillShipment",
    defaultHotkey: "",
    func: FillShipments,
    blockKeyNativeFunction: true,
    mouseBind: true,
    tooltip: "TODO",
    toggleOnInstance: false,
    tab: "PoE (2)",
    section: "Hotkey",
    coords: {
      x: 0,
      y: Y_GAP * 3
    },
    game: "PathOfExile",
  },
  HighlightShopItems: {
    name: "Enter RegExp",
    defaultHotkey: "",
    func: HighlightShopItems,
    blockKeyNativeFunction: true,
    extraField: true,
    mouseBind: true,
    tooltip: "TODO",
    toggleOnInstance: false,
    tab: "PoE (2)",
    section: "Hotkey",
    coords: {
      x: X_GAP,
      y: Y_GAP * 3
    },
    game: "PathOfExile",
  },
  OrbOfTransmutation: {
    name: "Orb of Transmutation (D)",
    defaultHotkey: "",
    func: OrbOfTransmutation,
    blockKeyNativeFunction: true,
    extraField: true,
    mouseBind: false,
    tooltip: "TODO",
    toggleOnInstance: true,
    tab: "PoE (1)",
    section: "Hotkey",
    coords: {
      x: 0,
      y: 0
    },
    pixelSelect: true,
    game: "PathOfExile",
  },
  OrbOfAlteration: {
    name: "Orb of Alteration (D)",
    defaultHotkey: "",
    func: OrbOfAlteration,
    blockKeyNativeFunction: true,
    extraField: true,
    mouseBind: false,
    tooltip: "TODO",
    toggleOnInstance: true,
    tab: "PoE (1)",
    section: "Hotkey",
    coords: {
      x: X_GAP,
      y: 0
    },
    pixelSelect: true,
    game: "PathOfExile",
  },
  OrbOfChance: {
    name: "Orb of Chance (D)",
    defaultHotkey: "",
    func: CraftOrbOfChance,
    blockKeyNativeFunction: true,
    extraField: true,
    mouseBind: false,
    tooltip: "TODO",
    toggleOnInstance: true,
    tab: "PoE (1)",
    section: "Hotkey",
    coords: {
      x: X_GAP * 2,
      y: 0
    },
    pixelSelect: true,
    game: "PathOfExile",
  },
  AlchemyOrb: {
    name: "Alchemy Orb (D)",
    defaultHotkey: "",
    func: CraftAlchemyOrb,
    blockKeyNativeFunction: true,
    extraField: true,
    mouseBind: false,
    tooltip: "TODO",
    toggleOnInstance: true,
    tab: "PoE (1)",
    section: "Hotkey",
    coords: {
      x: 0,
      y: Y_GAP * 4
    },
    pixelSelect: true,
    game: "PathOfExile",
  },
  OrbOfScouring: {
    name: "Orb of Scouring (D)",
    defaultHotkey: "",
    func: CraftOrbOfScouring,
    blockKeyNativeFunction: true,
    extraField: true,
    mouseBind: false,
    tooltip: "TODO",
    toggleOnInstance: true,
    tab: "PoE (1)",
    section: "Hotkey",
    coords: {
      x: X_GAP,
      y: Y_GAP * 4
    },
    pixelSelect: true,
    game: "PathOfExile",
  },
  ChaosOrb: {
    name: "Chaos Orb (D)",
    defaultHotkey: "",
    func: ChaosOrb,
    extraField: true,
    blockKeyNativeFunction: true,
    mouseBind: false,
    tooltip: "TODO",
    toggleOnInstance: true,
    tab: "PoE (1)",
    section: "Hotkey",
    coords: {
      x: X_GAP * 2,
      y: Y_GAP * 4
    },
    pixelSelect: true,
    game: "PathOfExile",
  },
  CalcWeaponDPS: {
    name: "Calc Weapon DPS",
    canBeDisabled: true,
    defaultHotkey: "",
    func: WeaponDPS,
    extraField: false,
    blockKeyNativeFunction: true,
    mouseBind: false,
    tooltip: "TODO",
    toggleOnInstance: false,
    tab: "PoE (1)",
    section: "Hotkey",
    coords: {
      x: 0,
      y: Y_GAP * 8
    },
    pixelSelect: false,
    game: "PathOfExile",
  },
  KillSwitch: {
    name: "Kill Switch",
    defaultHotkey: "Home",
    func: KillSwitch,
    blockKeyNativeFunction: true,
    mouseBind: false,
    tooltip: "TODO",
    toggleOnInstance: false,
    tab: "General",
    section: "Hotkey",
    coords: {
      x: X_GAP,
      y: Y_GAP * 2
    }
  },
  Settings: {
    name: "Settings (This GUI)",
    defaultHotkey: "F10",
    func: Settings,
    blockKeyNativeFunction: true,
    mouseBind: false,
    tooltip: "TODO",
    toggleOnInstance: false,
    tab: "General",
    section: "Hotkey",
    coords: {
      x: 0,
      y: Y_GAP * 2
    }
  },
  ToggleCtrlKeybind: {
    name: "Toggle CTRL Hotkey",
    defaultHotkey: "",
    func: ToggleCtrl,
    blockKeyNativeFunction: true,
    mouseBind: true,
    tooltip: "TODO",
    toggleOnInstance: false,
    tab: "General",
    section: "Hotkey",
    coords: {
      x: X_GAP,
      y: Y_GAP * 8
    }
  },
  ToggleShiftKeybind: {
    name: "Toggle SHIFT Hotkey",
    defaultHotkey: "",
    func: ToggleShift,
    blockKeyNativeFunction: true,
    mouseBind: true,
    tooltip: "TODO",
    toggleOnInstance: false,
    tab: "General",
    section: "Hotkey",
    coords: {
      x: X_GAP * 2,
      y: Y_GAP * 8
    }
  },
  CtrlClickSpamToggle: {
    name: "Spam Ctrl Click",
    defaultHotkey: "",
    func: CtrlClickSpamToggle,
    blockKeyNativeFunction: true,
    mouseBind: true,
    tooltip: "TODO",
    toggleOnInstance: false,
    coords: {
      x: 0,
      y: Y_GAP * 8
    },
    tab: "General",
    section: "Hotkey"
  },
  ForceLogout: {
    name: "Force Logout",
    defaultHotkey: "",
    func: TerminateTCP,
    blockKeyNativeFunction: true,
    mouseBind: false,
    tooltip: "TODO",
    toggleOnInstance: false,
    tab: "General",
    section: "Hotkey",
    coords: {
      x: X_GAP * 2,
      y: 0
    }
  },
  ToggleCtrl: {
    name: "Toggle CTRL",
    defaultValue: 0,
    func: ToggleCtrl,
    tooltip: "TODO",
    section: "Toggle",
    tab: "General",
    toggleOnInstance: false,
    coords: {
      x: X_GAP,
      y: Y_GAP * 5
    }
  },
  ToggleShift: {
    name: "Toggle SHIFT",
    defaultValue: 0,
    func: ToggleShift,
    tooltip: "TODO",
    section: "Toggle",
    tab: "General",
    toggleOnInstance: false,
    coords: {
      x: X_GAP * 2,
      y: Y_GAP * 5
    }
  },
  ToggleOverlayPosition: {
    name: "Toggle Overlay Position",
    tooltip: "TODO",
    section: "Options",
    tab: "General",
    toggleOnInstance: false,
    pixelSelect: true,
    coords: {
      x: 0,
      y: Y_GAP * 5
    }
  },
  TransferMaterialsWInventory: {
    name: "Transfer Materials (w/ inventory open)",
    defaultHotkey: "",
    func: TransferMaterialsWInventory,
    blockKeyNativeFunction: true,
    mouseBind: false,
    extraField: true,
    tooltip: "TODO",
    tab: "Last Epoch",
    section: "Hotkey",
    coords: {
      x: 0,
      y: 0
    },
    pixelSelect: true,
    toggleOnInstance: false,
    game: "LastEpoch",
    ; vars: ["TransferMaterialsButton", "TransferMaterialsSort"],
  },
  TransferMaterialsWOInventory: {
    name: "Transfer Materials (w/o inventory open)",
    defaultHotkey: "",
    func: TransferMaterialsWOInventory,
    blockKeyNativeFunction: true,
    mouseBind: false,
    extraField: true,
    tooltip: "TODO",
    tab: "Last Epoch",
    section: "Hotkey",
    coords: {
      x: X_GAP,
      y: 0
    },
    pixelSelect: true,
    toggleOnInstance: false,
    game: "LastEpoch",
    ;vars: ["TransferMaterialsButton", "TransferMaterialsSort"],
  },
  ShatterItem: {
    name: "Shatter Item",
    defaultHotkey: "",
    func: ShatterItem,
    blockKeyNativeFunction: true,
    mouseBind: false,
    extraField: true,
    tooltip: "TODO",
    tab: "Last Epoch",
    section: "Hotkey",
    coords: {
      x: X_GAP * 2,
      y: 0
    },
    pixelSelect: true,
    toggleOnInstance: false,
    game: "LastEpoch",
    vars: [
      "ShatterItemRuneSelection",
      "ShatterItemShatterRune",
      "ShatterItemButton"
    ],
  },
}