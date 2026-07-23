#Requires AutoHotkey v2.0

; INI persistence for the whole app. Driven entirely by the Configs registry —
; no per-key branches in here. Section flags on the config entries decide what
; gets read/written:
;   DATA_FILE  [Hotkeys] [Pixels] [Extra] [Labels] [Toggle]
;   STATE_FILE [STATE]   — per-session, cleared on clean ExitApp.
; Game-scoped keys carry PoE1_ / PoE2_ / LE_ prefix.

class Storage {
  static Bindings := Map()  ; hotkey + toggle values, keyed by Configs key
  static UserValues := Map()  ; pixels + chat-command text + regexp patterns
  static SlotLabels := Map()  ; user-typed mnemonics for currency slots etc.

  static LoadState() {
    if (FileExist(STATE_FILE)) {
      ClientLog.Activated := IniRead(STATE_FILE, "STATE", "DynamicHotkeysActivated", 0)
    }
  }

  static SaveState() {
    IniWrite(ClientLog.Activated, STATE_FILE, "STATE", "DynamicHotkeysActivated")
    IniWrite(ClientLog.LastLocation, STATE_FILE, "STATE", "LastLocation")
  }

  static SaveConfig(*) {
    global Configs
    controls := Settings.Submit()

    if (conflict := Storage._FindDuplicateHotkey(controls)) {
      MsgBox(Format(
        "Hotkey '{}' is bound to both '{}' and '{}'. Pick a different key for one of them.",
        conflict.value, conflict.firstName, conflict.secondName
      ), "Quality of Exile", MSGBOX_TOPMOST)
      return
    }

    for key, config in Configs {
      Storage._SavePixels(key, config, controls)
      Storage._SaveSectionValue(key, config, controls)
      Storage._SaveExtra(key, config, controls)
      Storage._SaveLabel(key, config, controls)
    }

    Storage.SaveState()
    Reload()
    Game.FocusGameWindow()
  }

  static LoadConfig() {
    global Configs

    try {
      for key, config in Configs {
        if (config.HasProp("game") and config.game != Game.Name) {
          continue
        }
        Storage._LoadPixels(key, config)
        Storage._LoadAndRegister(key, config)
      }
      Modifiers.WireFallbacks()
    } catch Error as e {
      Log.Error(
        Format(
          'Error when loading configurations. If this persists consider deleting file: "{}".`nYou will lose your settings by doing this and have to start over.',
          DATA_FILE
        ),
        e,
        true
      )
      KillSwitch()
    }
  }

  ; ============================ Save helpers ============================

  static _SavePixels(key, config, controls) {
    if (!ConfigBool(config, "pixelSelect")) {
      return
    }
    vars := (config.HasProp("vars") and config.vars.Length > 0) ? config.vars : [key]
    for _, var in vars {
      pixelKey := var "Pixel"
      if (!controls.HasOwnProp(pixelKey)) {
        continue
      }
      val := controls.%pixelKey%
      IniWrite(val, DATA_FILE, "Pixels", GameScopedKey(var))
      Storage.UserValues.Set(var, val)
    }
  }

  static _SaveSectionValue(key, config, controls) {
    section := config.HasProp("section") ? config.section : ""
    if ((section != "Hotkey" and section != "Toggle") or !controls.HasOwnProp(key)) {
      return
    }
    iniSection := section == "Hotkey" ? "Hotkeys" : "Toggle"
    IniWrite(controls.%key%, DATA_FILE, iniSection, key)
  }

  static _SaveExtra(key, config, controls) {
    if (!ConfigBool(config, "textField") and !ConfigBool(config, "regexpField") and !config.HasProp("dropdown")) {
      return
    }
    extraKey := key "_extra"
    if (!controls.HasOwnProp(extraKey)) {
      return
    }
    storageKey := ConfigBool(config, "gameScoped") ? GameScopedKey(key) : key
    IniWrite(controls.%extraKey%, DATA_FILE, "Extra", storageKey)
  }

  static _SaveLabel(key, config, controls) {
    if (!ConfigBool(config, "labelField")) {
      return
    }
    labelKey := key "_label"
    if (!controls.HasOwnProp(labelKey)) {
      return
    }
    storageKey := ConfigBool(config, "gameScoped") ? GameScopedKey(key) : key
    IniWrite(controls.%labelKey%, DATA_FILE, "Labels", storageKey)
  }

  ; ============================ Load helpers ============================

  static _LoadPixels(key, config) {
    if (!ConfigBool(config, "pixelSelect")) {
      return
    }
    vars := (config.HasProp("vars") and config.vars.Length > 0) ? config.vars : [key]
    for _, var in vars {
      Storage.UserValues.Set(var, ReadGameScoped("Pixels", var))
    }
  }

  static _LoadAndRegister(key, config) {
    ; textField / regexpField / labelField data is independent of section
    ; (sectionless configs can still have these — e.g. ladder character/league).
    Storage._LoadTextValues(key, config)

    section := config.HasProp("section") ? config.section : ""
    if (section == "Hotkey") {
      Storage._LoadHotkey(key, config)
    } else if (section == "Toggle") {
      Storage._LoadToggle(key, config)
    }
  }

  static _LoadTextValues(key, config) {
    if (ConfigBool(config, "textField") or ConfigBool(config, "regexpField") or config.HasProp("dropdown")) {
      dflt := config.HasProp("defaultText") ? config.defaultText : ""
      Storage.UserValues.Set(key, ConfigBool(config, "gameScoped")
        ? ReadGameScoped("Extra", key, dflt)
        : IniRead(DATA_FILE, "Extra", key, dflt))
    }
    if (ConfigBool(config, "labelField")) {
      Storage.SlotLabels[key] := ConfigBool(config, "gameScoped")
        ? ReadGameScoped("Labels", key, "")
        : IniRead(DATA_FILE, "Labels", key, "")
    }
  }

  static _LoadHotkey(key, config) {
    val := IniRead(DATA_FILE, "Hotkeys", key, config.defaultHotkey)
    Storage.Bindings.Set(key, val)

    ; No game attached + not explicitly global → skip the hotkey registration,
    ; otherwise it would fire everywhere (Game.Title is empty → HotIf() = global).
    if (!ConfigBool(config, "globalScope") and !Game.HWND) {
      return
    }

    winName := ConfigBool(config, "globalScope") ? "" : Game.Title
    blockNative := ConfigBool(config, "blockKeyNativeFunction") or ConfigBool(config, "toggleOnInstance")
    prefix := blockNative ? "*" : "~"
    Keybinds.Register(prefix . val, config.func, "On", config.canBeDisabled, winName)
  }

  static _LoadToggle(key, config) {
    val := IniRead(DATA_FILE, "Toggle", key, 0)
    Storage.Bindings.Set(key, val)

    if (val == 1 and config.HasProp("companionKey") and Game.HWND) {
      Keybinds.Register(config.companionKey, config.func, "On", config.canBeDisabled)
    }
  }

  ; ============================ Internal ============================

  ; Returns { value, firstName, secondName } on conflict, or false otherwise.
  static _FindDuplicateHotkey(controls) {
    seen := Map()
    for key, config in Configs {
      if (!config.HasProp("section") or config.section != "Hotkey") {
        continue
      }
      if (!controls.HasOwnProp(key)) {
        continue
      }
      val := controls.%key%
      if (val == "") {
        continue
      }
      if (seen.Has(val)) {
        return {
          value: val,
          firstName: Configs[seen[val]].name,
          secondName: config.name
        }
      }
      seen[val] := key
    }
    return false
  }
}
