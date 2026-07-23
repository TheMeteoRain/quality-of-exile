#Requires AutoHotkey v2.0

; CTRL / SHIFT toggle state + spam / disabled flags. Built unconditionally so
; the pixel-picker preview works even before any toggle features are bound.

class Overlay {
  static _gui := 0
  static _spamLabel := 0
  static _disabledLabel := 0
  static _previewLock := false
  static _previewOrigin := 0

  static Create() {
    if (Overlay._gui) {
      return
    }

    Overlay._gui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x20")
    Overlay._gui.Title := "Toggle Overlay"
    Overlay._gui.BackColor := "Black"
    WinSetTransColor(Overlay._gui.BackColor " 150", Overlay._gui)
    Modifiers.Ctrl.label := Overlay._gui.Add("Text", "x10 y10 w" Game.OverlayWidth / 2 " h30 vCtrlLabel", "CTRL:❌")
    Modifiers.Ctrl.label.SetFont("cWhite s15 q5")
    Modifiers.Shift.label := Overlay._gui.Add("Text", "x10 y40 w" Game.OverlayWidth / 2 " h30 vShiftLabel", "SHIFT:❌")
    Modifiers.Shift.label.SetFont("cWhite s15 q5")
    Overlay._spamLabel := Overlay._gui.Add("Text", "x" Game.OverlayWidth / 2 " y6 w" Game.OverlayWidth / 2 " h30 vSpam"
    )
    Overlay._spamLabel.SetFont("c4cff70 s20 q5")
    Overlay._disabledLabel := Overlay._gui.Add("Text", "x" Game.OverlayWidth / 2 " y33 w" Game.OverlayWidth / 2 " h30 vDisabled"
    )
    Overlay._disabledLabel.SetFont("cYellow s20 q5")
  }

  static Show() {
    if (!Overlay._gui) {
      return
    }
    if (Overlay._previewLock) {  ; picker owns position
      return
    }
    if (!Modifiers.AnyToggleableBound()) {
      Overlay.Hide()
      return
    }

    default := Format("{}x{}", Game.OverlayPosX, Game.OverlayPosY)
    val := Storage.UserValues.Get("ToggleOverlayPosition", default)
    resolution := ParseResolution(val)
    if (!resolution) {
      ; Corrupt / legacy stored position. Silently reset to the auto-computed
      ; default (and persist it) instead of blocking with a MsgBox — the error
      ; used to reappear every Show(), leaving the user no way to fix it.
      Storage.UserValues.Set("ToggleOverlayPosition", default)
      IniWrite(default, DATA_FILE, "Pixels", GameScopedKey("ToggleOverlayPosition"))
      resolution := ParseResolution(default)
      if (!resolution) {
        return
      }
    }

    Overlay._gui.Show("x" resolution.width " y" resolution.height " w" Game.OverlayWidth " h" Game.OverlayHeight " NoActivate"
    )
  }

  static Hide() {
    if (Overlay._previewLock) {  ; picker is using overlay as live preview
      return
    }
    if (!Overlay._gui) {
      return
    }
    Overlay._gui.Hide()
  }

  static SetSpam(text) {
    if (Overlay._spamLabel) {
      Overlay._spamLabel.Text := text
    }
  }

  static SetDisabled(text) {
    if (Overlay._disabledLabel) {
      Overlay._disabledLabel.Text := text
    }
  }

  ; --- Pixel-picker preview API ---

  static BeginPreview() {
    Overlay.Create()
    Overlay._gui.GetPos(&x, &y)
    Overlay._previewOrigin := {
      x: x,
      y: y
    }
    Overlay._previewLock := true
  }

  static MovePreview(x, y) {
    Overlay._gui.Show(Format("x{} y{} w{} h{} NoActivate", x, y, Game.OverlayWidth, Game.OverlayHeight))
  }

  static EndPreview(restore := false) {
    if (restore and Overlay._previewOrigin) {
      Overlay._gui.Show(Format(
        "x{} y{} w{} h{} NoActivate",
        Overlay._previewOrigin.x, Overlay._previewOrigin.y,
        Game.OverlayWidth, Game.OverlayHeight
      ))
    }
    Overlay._previewLock := false
    if (!Modifiers.AnyToggleableBound()) {
      Overlay.Hide()
    }
  }
}
