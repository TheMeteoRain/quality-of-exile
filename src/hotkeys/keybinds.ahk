#Requires AutoHotkey v2.0

class Keybinds {
  static _registered := Map()
  static _suspended := false

  static IsSuspended() {
    return Keybinds._suspended
  }

  ; Register or re-arm a hotkey. WinName="" leaves it global (KillSwitch only).
  static Register(KeyName, Func, Action := "On", canBeDisabled := true, WinName := Game.Title) {
    if (!Keybinds._registered.Has(KeyName)) {
      Keybinds._registered[KeyName] := {
        func: Func,
        canBeDisabled: canBeDisabled
      }
    }
    if (WinName == "") {
      HotIf()
    } else {
      HotIfWinActive(Game.Title)
    }
    Hotkey(KeyName, Func, Action)
  }

  ; Master enable/disable. canBeDisabled:false entries (KillSwitch, Settings,
  ; ToggleHotkeys) stay registered regardless.
  static SetEnabled(enabled) {
    if (!enabled) {
      Modifiers.Reset()
    }

    ; Set before ClientLog.SetDynamic — it bails while suspended.
    Keybinds._suspended := !enabled

    action := enabled ? "On" : "Off"
    for key, obj in Keybinds._registered {
      if (!enabled and !obj.canBeDisabled) {
        continue
      }
      Keybinds.Register(key, obj.func, action)
    }

    ClientLog.SetDynamic(enabled and ClientLog.LastLocation == "safe", true)
    Overlay.SetDisabled(enabled ? " " : "⚠️")
  }

  static Toggle(*) {
    if (Debounce("ToggleHotkeys", 500)) {
      return
    }
    Keybinds.SetEnabled(Keybinds._suspended)
  }
}
