#Requires AutoHotkey v2.0

; Press-once-to-hold Ctrl / Shift. ToggleableModifier instances hold the
; physical-state + overlay-label pairing; Modifiers is the namespace + the
; high-level orchestration the rest of the app calls into.

class ToggleableModifier {
  toggled := false

  __New(sendKey, display) {
    this.sendKey := sendKey   ; "Ctrl" / "Shift" — used in SendInput
    this.display := display   ; "CTRL" / "SHIFT" — shown in overlay
  }

  Down() {
    SendInput("{" this.sendKey " down}")
    this.toggled := true
    this.UpdateLabel()
  }

  Up() {
    SendInput("{" this.sendKey " up}")
    this.toggled := false
    this.UpdateLabel()
  }

  Set(on) {
    if (on) {
      this.Down()
    } else {
      this.Up()
    }
  }

  Toggle() {
    if (this.toggled) {
      this.Up()
    } else {
      this.Down()
    }
  }

  UpdateLabel() {
    if (!this.HasOwnProp("label")) {
      return
    }
    this.label.Text := this.display . (this.toggled ? ":✅" : ":❌")
    this.label.SetFont(this.toggled ? "c4cff70" : "cWhite")
  }
}

class Modifiers {
  static Ctrl := ToggleableModifier("Ctrl", "CTRL")
  static Shift := ToggleableModifier("Shift", "SHIFT")

  ; True iff any binding that depends on the toggle overlay is set.
  static AnyToggleableBound() {
    return (
      Storage.Bindings["ToggleCtrl"] or Storage.Bindings["ToggleShift"] or
      Storage.Bindings["CtrlClickSpamToggle"] or Storage.Bindings["ToggleCtrlKeybind"] or
      Storage.Bindings["ToggleShiftKeybind"] or Storage.Bindings["ToggleHotkeys"]
    )
  }

  static Reset(*) {
    if (Modifiers.AnyToggleableBound()) {
      ClickSpam.Stop()
      Modifiers.Ctrl.Up()
      Modifiers.Shift.Up()
    }
  }

  static ResetAndSend(keys, *) {
    Modifiers.Reset()
    SendInput(keys)
  }

  static ToggleCtrl(*) {
    if (Debounce("ToggleCtrl", 50)) {
      return
    }
    Modifiers.Shift.Up()
    ; click-spam holds Ctrl; stopping it leaves Ctrl held for the next press to release.
    if (ClickSpam.Stop()) {
      return
    }
    Modifiers.Ctrl.Toggle()
  }

  static ToggleShift(*) {
    if (Debounce("ToggleShift", 50)) {
      return
    }
    ClickSpam.Stop()
    Modifiers.Ctrl.Up()
    Modifiers.Shift.Toggle()
  }

  static SaveState() {
    return {
      ctrl: Modifiers.Ctrl.toggled,
      shift: Modifiers.Shift.toggled
    }
  }

  static RestoreState(state) {
    Modifiers.Ctrl.Set(state.ctrl)
    Modifiers.Shift.Set(state.shift)
  }

  ; Called once at boot after configs load. Wires:
  ;   - If only one of Ctrl/Shift toggle is bound, the OTHER physical key
  ;     resets toggles when pressed (so releasing held modifiers feels natural).
  ;   - Esc and the Windows key release held modifiers + stop click-spam, then
  ;     send the key normally. Modifiers are released BEFORE the re-send, or a
  ;     held Ctrl turns Esc/Win into Ctrl+Esc/Ctrl+Win (Start menu).
  static WireFallbacks() {
    if (!Game.HWND) {
      return  ; no game attached → registering globally would steal keys app-wide
    }
    ctrlOn := Storage.Bindings["ToggleCtrl"] == 1
    shiftOn := Storage.Bindings["ToggleShift"] == 1

    if (ctrlOn and !shiftOn) {
      Keybinds.Register("*Shift", Modifiers.Reset, "On", true)
    }
    if (!ctrlOn and shiftOn) {
      Keybinds.Register("*Ctrl", Modifiers.Reset, "On", true)
    }

    ; Any toggle that can leave held state (Ctrl/Shift holds, click-spam) gets
    ; the Esc/Win escape hatch — not just the Ctrl/Shift toggles.
    if (Modifiers.AnyToggleableBound()) {
      Keybinds.Register("*Esc", (*) => Modifiers.ResetAndSend("{Esc}"), "On", true)
      Keybinds.Register("*LWin", (*) => Modifiers.ResetAndSend("{LWin}"), "On", true)
      Keybinds.Register("*RWin", (*) => Modifiers.ResetAndSend("{RWin}"), "On", true)
    }
  }
}
