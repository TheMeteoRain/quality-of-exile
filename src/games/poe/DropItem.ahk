#Requires AutoHotkey v2.0

; Hover an item, press the hotkey to drop it on the ground. Only works in
; areas where loot drops are allowed (not in hideout).
DropItem(*) {
  global MousePos

  if (Debounce("DropItem", 185)) {
    return
  }

  try {
    Modifiers.Reset()
    BlockInput("MouseMove")
    MousePos.SavePosition()

    Click("left")
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
