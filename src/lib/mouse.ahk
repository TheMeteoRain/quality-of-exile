#Requires AutoHotkey v2.0

; Save / restore wrapper around the cursor position. One global instance `MousePos`.

class MousePositionSaver {
  OriginalX := 0
  OriginalY := 0

  SavePosition() {
    MouseGetPos(&x, &y)
    this.OriginalX := x
    this.OriginalY := y
  }

  RestorePosition() {
    MouseMove(this.OriginalX, this.OriginalY, 0)
  }
}

global MousePos := MousePositionSaver()