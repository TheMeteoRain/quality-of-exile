#Requires AutoHotkey v2.0

; Press the hotkey to type the chat command stored in Storage.UserValues[key].
; Wrapped in {Enter} so chat opens, the command types, chat sends.
ChatCommand(commandKey, *) {
  text := Storage.UserValues.Get(commandKey, "")
  if (text == "") {
    return
  }
  Modifiers.Reset()
  SendInput("{Enter}" text "{Enter}")
}
