#Requires AutoHotkey v2.0

; Used in vendor / search windows. Stores the user's regexp pattern (per-game),
; clears the clipboard, sets it to the quoted pattern, sends Ctrl+F + paste.
HighlightShopItems(commandKey, *) {
  text := Storage.UserValues.Get(commandKey, "")
  if (text == "") {
    return
  }

  ; Ctrl wins over Shift if both were held (matches prior behaviour).
  modifierToggled := Modifiers.Ctrl.toggled ? "ctrl" : Modifiers.Shift.toggled ? "shift" : ""

  Modifiers.Reset()

  Clip.Save()
  Clip.Clear()
  Clip.Set(Format("`"{}`"", text))

  SendInput("^f")
  Clip.Paste()
  Clip.Restore()

  if (modifierToggled == "shift") {
    Modifiers.ToggleShift()
  }
  if (modifierToggled == "ctrl") {
    Modifiers.ToggleCtrl()
  }
}
