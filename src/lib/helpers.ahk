#Requires AutoHotkey v2.0

KillSwitch(*) {
  ExitApp()
}

; Returns true if the call should be skipped (within cooldown).
Debounce(fnName, cooldownTime := 1000) {
  static lastExec := Map()
  currentTime := A_TickCount
  last := lastExec.Has(fnName) ? lastExec[fnName] : 0
  if (currentTime - last < cooldownTime) {
    return true
  }
  lastExec[fnName] := currentTime + cooldownTime
  return false
}

; SetCursorPos skips MouseMove's animation
CustomMouseMove(x, y) {
  DllCall("SetCursorPos", "int", x, "int", y)
}

ParseResolution(resolution) {
  if (!resolution || !RegExMatch(resolution, "^\d+(\.)?(\d+)?x\d+(\.)?(\d+)?$")) {
    return false
  }

  parts := StrSplit(resolution, "x")
  return {
    width: parts[1],
    height: parts[2]
  }
}

ConfigBool(config, prop) {
  return config.HasProp(prop) and config.%prop%
}

; Prefixes `var` with the active game variant ("PoE1_" / "PoE2_" / "LE_").
GameScopedKey(var) {
  return Game.PixelPrefix() . var
}

ReadGameScoped(section, var, default := "") {
  return IniRead(DATA_FILE, section, GameScopedKey(var), default)
}

ParseAndValidatePixel(name, variable) {
  if (!Storage.UserValues.Has(variable) or !Storage.UserValues.Get(variable)) {
    MsgBox("Set pixel for " name ". Use the Pixel Search button in settings (" Storage.Bindings["Settings"] ").")
    return false
  }

  resolution := ParseResolution(Storage.UserValues[variable])
  if (!resolution) {
    MsgBox("Invalid resolution for " name ". Please set a valid resolution in the format 'widthxheight' (e.g., 1920x1080)."
    )
    return false
  }

  return resolution
}
