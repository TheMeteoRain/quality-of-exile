#Requires AutoHotkey v2.0

; Hover an item → press hotkey → right-click the configured currency pixel,
; left-click the hovered item. Saves/restores Shift state because crafting
; often holds Shift for repeat use.
CraftWithCurrency(name, key, *) {
  global MousePos

  resolution := ParseAndValidatePixel(name, key)
  if (!resolution) {
    return
  }

  if (Debounce("CraftWithCurrency", 100)) {
    return
  }

  state := Modifiers.SaveState()
  Modifiers.Reset()
  try {
    BlockInput("MouseMove")
    MousePos.SavePosition()
    CustomMouseMove(resolution.width, resolution.height)
    Sleep(50)
    Click("right")
    Sleep(50)
    MousePos.RestorePosition()
    Sleep(25)
    Click("left")
  } finally {
    BlockInput("MouseMoveOff")
    Modifiers.RestoreState(state)
  }
}
