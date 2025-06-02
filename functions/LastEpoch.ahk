#Requires AutoHotkey v2.0

ShatterItem(*) {

  runeSelectionResolution := ParseAndValidatePixel("Shatter Item", "ShatterItemRuneSelection")
  shatterRuneResolution := ParseAndValidatePixel("Shatter Item", "ShatterItemShatterRune")
  buttonResolution := ParseAndValidatePixel("Shatter Item", "ShatterItemButton")

  if (!buttonResolution or !runeSelectionResolution or !shatterRuneResolution) {
    return
  }

  if (Debounce("ShatterItem", 100)) {
    return
  }

  state := SaveToggleState()
  ResetToggle()
  try {
    BlockInput("MouseMove")
    mousePos.SavePosition()
    SendInput("{Shift down}")
    Sleep(50)
    Send("!{Click Right}")
    Sleep(50)
    SendInput("{Shift up}")
    Sleep(50)
    CustomMouseMove(runeSelectionResolution.width, runeSelectionResolution.height)
    Sleep(50)
    Click("left")
    Sleep(50)
    CustomMouseMove(shatterRuneResolution.width, shatterRuneResolution.height)
    Sleep(50)
    Click("left")
    Sleep(50)
    CustomMouseMove(buttonResolution.width, buttonResolution.height)
    Sleep(50)
    Click("left")
    Sleep(50)
    mousePos.RestorePosition()
  } finally {
    SendInput("{Shift up}")
    BlockInput("MouseMoveOff")
    RestoreToggleState(state)
  }
}

ParseAndValidatePixel(name, variable) {
  if (!Extra.Has(variable) or !Extra.Get(variable)) {
    MsgBox("Set pixel for " name ". Use the Pixel Search button in settings (" Hotkeys["Settings"] ").")
    return false
  }

  resolution := ParseResolution(Extra[variable])
  if (!resolution) {
    MsgBox("Invalid resolution for " name ". Please set a valid resolution in the format 'widthxheight' (e.g., 1920x1080)."
    )
    return false
  }

  return resolution
}

TransferMaterialsWOInventory(*) {
  global mousePos

  if (!Extra.Has("TransferMaterialsWOInventory") or !Extra.Get("TransferMaterialsWOInventory")) {
    MsgBox("Set pixel for Transfer Materials. Use the Pixel Search button in settings (" Hotkeys["Settings"] ").")
    return
  }

  resolution := ParseResolution(Extra["TransferMaterialsWOInventory"])
  if (!resolution) {
    MsgBox(
      "Invalid resolution for Transfer Materials. Please set a valid resolution in the format 'widthxheight' (e.g., 1920x1080)."
    )
    return
  }

  if (Debounce("TransferMaterialsWOInventory", 100)) {
    return
  }

  state := SaveToggleState()
  ResetToggle()
  try {
    if (GetKeyState("LButton", "P")) {
      Click("left up")
    }
    SendInput("i")
    BlockInput("MouseMove")
    mousePos.SavePosition()
    CustomMouseMove(resolution.width, resolution.height)
    Sleep(50)
    Click("left")
    Sleep(50)
    mousePos.RestorePosition()
  } finally {
    if (GetKeyState("LButton", "P")) {
      Click("left down")
    }
    SendInput("i")
    BlockInput("MouseMoveOff")
    RestoreToggleState(state)
  }
}

TransferMaterialsWInventory(*) {
  global mousePos

  if (!Extra.Has("TransferMaterialsWInventory") or !Extra.Get("TransferMaterialsWInventory")) {
    MsgBox("Set pixel for Transfer Materials. Use the Pixel Search button in settings (" Hotkeys["Settings"] ").")
    return
  }

  resolution := ParseResolution(Extra["TransferMaterialsWInventory"])
  if (!resolution) {
    MsgBox(
      "Invalid resolution for Transfer Materials. Please set a valid resolution in the format 'widthxheight' (e.g., 1920x1080)."
    )
    return
  }

  if (Debounce("TransferMaterialsWInventory", 100)) {
    return
  }

  state := SaveToggleState()
  ResetToggle()
  try {
    if (GetKeyState("LButton", "P")) {
      Click("left up")
    }
    BlockInput("MouseMove")
    mousePos.SavePosition()
    CustomMouseMove(resolution.width, resolution.height)
    Sleep(50)
    Click("left")
    Sleep(50)
    mousePos.RestorePosition()
  } finally {
    if (GetKeyState("LButton", "P")) {
      Click("left down")
    }
    BlockInput("MouseMoveOff")
    RestoreToggleState(state)
  }
}
