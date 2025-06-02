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
  ToggleHotkeys: 0
}
global CtrlToggled := false
global ShiftToggled := false
global ScrollSpam := false
global DPSGui := unset
global OverlayGui, CtrlLabel, ShiftLabel, SpamLabel, DisabledLabel, HotkeyGui, HUDGui
global clientFilePath, clientFile, clientFileReadFunc
global DynamicHotkeysActivated := false
global DynamicHotkeysState := "OFF"
global RegisteredHotkeys := Map()
global RegExpCharacterLimit := 48
global Game := GameInfo()
global mousePos := MousePositionSaver()
global clipboard := ClipboardSaver()
global Hotkeys := Map()
global Extra := Map()
global Options := Map()
global ManualHotkeyEnabled := false
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: false,
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
    canBeDisabled: false,
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
  ToggleHotkeys: {
    name: "Enable/Disable Hotkeys",
    canBeDisabled: false,
    defaultHotkey: "",
    func: ToggleHotkeys,
    blockKeyNativeFunction: true,
    mouseBind: false,
    tooltip: "TODO",
    toggleOnInstance: false,
    tab: "General",
    section: "Hotkey",
    coords: {
      x: X_GAP * 2,
      y: Y_GAP * 2
    }
  },
  ToggleCtrlKeybind: {
    name: "Toggle CTRL Hotkey",
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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
    canBeDisabled: true,
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