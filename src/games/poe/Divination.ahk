#Requires AutoHotkey v2.0

; Hover a full stack in your inventory, open the trade screen, press hotkey.
; Clicks the configured trade button and item area pixels.
PerformDivinationTrading(*) {
  global MousePos

  rand1 := Random(125, 175)
  rand2 := Random(125, 175)
  if (Debounce("PerformDivinationTrading", rand1 + rand2)) {
    return
  }

  buttonResolution := ParseAndValidatePixel("divination trade button", "TradeDivinationCardButton")
  areaResolution := ParseAndValidatePixel("divination item area", "TradeDivinationCardItemArea")
  if (!buttonResolution or !areaResolution) {
    return
  }

  try {
    BlockInput("MouseMove")
    MousePos.SavePosition()
    Modifiers.Reset()

    Send("^{Click}")
    DllCall("SetCursorPos", "int", buttonResolution.width, "int", buttonResolution.height)
    Sleep(rand1)
    Click("left")
    DllCall("SetCursorPos", "int", areaResolution.width, "int", areaResolution.height)
    Sleep(rand2)
    Send("^{Click}")

    MousePos.RestorePosition()
  } finally {
    BlockInput("MouseMoveOff")
  }
}

; Hover a stacked deck, press hotkey: pick one card off the top + drop on
; the ground (outdoor areas only — needs loot-drop permission).
OpenStackedDivinationDeck(*) {
  global MousePos

  if (Debounce("OpenStackedDivinationDeck", 185)) {
    return
  }

  try {
    Modifiers.Reset()
    BlockInput("MouseMove")
    MousePos.SavePosition()

    Click("right")
    Sleep(10)
    CustomMouseMove(Game.ScreenMiddleWithInventoryX, Game.ScreenMiddleWithInventoryY)
    Sleep(100)
    Click("left")
    Sleep(75)
    MousePos.RestorePosition()
  } finally {
    BlockInput("MouseMoveOff")
  }
}
