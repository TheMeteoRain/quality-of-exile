#Requires AutoHotkey v2.0

; The two flavors are identical except the W/O variant toggles the inventory
; open before and after; one impl + two Configs bindings.
TransferMaterials(varName, toggleInventory, *) {
  global MousePos

  resolution := ParseAndValidatePixel("Transfer Materials", varName)
  if (!resolution) {
    return
  }

  if (Debounce(varName, 100)) {
    return
  }

  state := Modifiers.SaveState()
  Modifiers.Reset()
  try {
    if (GetKeyState("LButton", "P")) {
      Click("left up")
    }
    if (toggleInventory) {
      SendInput("i")
    }
    BlockInput("MouseMove")
    MousePos.SavePosition()
    CustomMouseMove(resolution.width, resolution.height)
    Sleep(50)
    Click("left")
    Sleep(50)
    MousePos.RestorePosition()
  } finally {
    if (GetKeyState("LButton", "P")) {
      Click("left down")
    }
    if (toggleInventory) {
      SendInput("i")
    }
    BlockInput("MouseMoveOff")
    Modifiers.RestoreState(state)
  }
}
