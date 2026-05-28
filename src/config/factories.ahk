#Requires AutoHotkey v2.0

; Factories for src/config/configs.ahk entries. Each merges defaults with
; the overrides object so registry rows stay short.

HotkeyEntry(overrides) {
  defaults := {
    canBeDisabled: true,
    defaultHotkey: "",
    blockKeyNativeFunction: true,
    toggleOnInstance: false,
    pixelSelect: false,
    section: "Hotkey",
  }
  return MergeProps(defaults, overrides)
}

ToggleEntry(overrides) {
  defaults := {
    canBeDisabled: true,
    toggleOnInstance: false,
    section: "Toggle",
  }
  return MergeProps(defaults, overrides)
}

; `n` indexes both the displayed slot and the Configs key (HighlightShopItems1..N).
RegexpEntry(n, defaultHotkey, defaultText, row, gap) {
  key := "HighlightShopItems" n
  return HotkeyEntry({
    name: "RegExp Search #" n,
    func: HighlightShopItems.Bind(key),
    defaultHotkey: defaultHotkey,
    defaultText: defaultText,
    regexpField: true,
    gameScoped: true,
    game: "PathOfExile",
    tab: "PoE Regexp",
    row: row,
    col: 0,
    span: 3,
    gap: gap,
    tooltip: "Inputs the text to any text field that is focusable with CTRL+F.",
  })
}

; `n` indexes both the displayed slot and the Configs key (ChatCommand1..6).
ChatCommandConfig(n, defaultHotkey, defaultText) {
  key := "ChatCommand" n
  return HotkeyEntry({
    name: "Chat Command #" n,
    func: ChatCommand.Bind(key),
    defaultHotkey: defaultHotkey,
    defaultText: defaultText,
    textField: true,
    gameScoped: true,
    placeholder: "chat command (e.g. /hideout)",
    tab: "PoE Commands",
    row: n <= 3 ? 0 : 1,
    col: Mod(n - 1, 3),
    tooltip: "Sends the chat command below.",
  })
}

; Generic currency slot — user picks pixel + label per slot.
CurrencyConfig(n, row, col, gap := false) {
  key := "CraftingCurrency" n
  displayName := "Crafting Currency #" n
  return HotkeyEntry({
    name: displayName " (D)",
    func: CraftWithCurrency.Bind(displayName, key),
    toggleOnInstance: true,
    pixelSelect: true,
    labelField: true,
    gameScoped: true,
    tab: "PoE Crafting",
    row: row,
    col: col,
    gap: gap,
    game: "PathOfExile",
    tooltip: "Hover an item to apply this currency. (D) means it only fires in towns and hideouts.",
    pixelTooltips: Map(key, "Click this currency in your stash or inventory."),
  })
}

TransferConfig(name, key, toggleInventory, row, col, tooltip) {
  return HotkeyEntry({
    name: name,
    func: TransferMaterials.Bind(key, toggleInventory),
    pixelSelect: true,
    tab: "Last Epoch",
    row: row,
    col: col,
    game: "LastEpoch",
    tooltip: tooltip,
    pixelTooltips: Map(key, "Click the Transfer Materials button."),
  })
}

MergeProps(defaults, overrides) {
  out := {}
  for k, v in defaults.OwnProps() {
    out.%k% := v
  }
  for k, v in overrides.OwnProps() {
    out.%k% := v
  }
  return out
}
