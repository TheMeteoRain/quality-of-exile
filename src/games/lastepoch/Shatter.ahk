#Requires AutoHotkey v2.0

ShatterItem(*) {
  runeSelection := ParseAndValidatePixel("Shatter Item", "ShatterItemRuneSelection")
  shatterRune := ParseAndValidatePixel("Shatter Item", "ShatterItemShatterRune")
  shatterButton := ParseAndValidatePixel("Shatter Item", "ShatterItemButton")

  if (!shatterButton or !runeSelection or !shatterRune) {
    return
  }

  if (Debounce("ShatterItem", 100)) {
    return
  }

  state := Modifiers.SaveState()
  Modifiers.Reset()
  try {
    BlockInput("MouseMove")
    MousePos.SavePosition()
    SendInput("{Shift down}")
    Sleep(50)
    Send("!{Click Right}")
    Sleep(50)
    SendInput("{Shift up}")
    Sleep(50)
    ClickAt(runeSelection)
    ClickAt(shatterRune)
    ClickAt(shatterButton)
    MousePos.RestorePosition()
  } finally {
    SendInput("{Shift up}")
    BlockInput("MouseMoveOff")
    Modifiers.RestoreState(state)
  }
}

; Click at a pre-parsed pixel coordinate after a short delay.
ClickAt(resolution) {
  CustomMouseMove(resolution.width, resolution.height)
  Sleep(50)
  Click("left")
  Sleep(50)
}
