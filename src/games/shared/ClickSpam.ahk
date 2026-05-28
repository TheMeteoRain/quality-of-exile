#Requires AutoHotkey v2.0

; Hold Ctrl while spamming left-click. Used to move stacks in/out of stash —
; works in any inventory game. Toggle on / off via ClickSpam.Toggle.

class ClickSpam {
  static _active := false
  ; Same arrow each time so SetTimer's start + stop refs match.
  static _Timer := (*) => SendInput("{LButton}")

  ; Returns whether spam was active before this call.
  static Stop() {
    was := ClickSpam._active
    ClickSpam._active := false
    Overlay.SetSpam("")
    SetTimer(ClickSpam._Timer, 0)
    return was
  }

  static Toggle(*) {
    if (ClickSpam._active) {
      ClickSpam.Stop()
      Modifiers.Ctrl.Up()
      return
    }
    ClickSpam._active := true
    Overlay.SetSpam("🖱️❗")
    Modifiers.Shift.Up()
    Modifiers.Ctrl.Down()
    SetTimer(ClickSpam._Timer, Random(75, 100))
  }
}
