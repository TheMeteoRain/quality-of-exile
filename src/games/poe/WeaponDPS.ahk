#Requires AutoHotkey v2.0

; Hover-a-weapon hotkey: Alt+Copy the item under the cursor, run it through
; CalculateWeaponDPS, show the result as a transparent overlay near the mouse
; for 5 seconds.

class WeaponDPS {
  static _AUTO_HIDE_MS := 5000   ; popup self-dismisses after this long

  static _gui := 0

  static Show(*) {
    if (Debounce("WeaponDPS", 250)) {
      return
    }

    WeaponDPS.Hide()
    SetTimer((*) => WeaponDPS.Hide(), 0)
    Clip.Save()
    Clip.Clear()
    Clip.CopyWithAlt()
    item := Clip.Get()
    Clip.Restore()

    WeaponDPS._gui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
    WeaponDPS._gui.BackColor := MAIN_COLOR
    WinSetTransparent("255", WeaponDPS._gui)

    try {
      ctrl := CalculateWeaponDPS(item, WeaponDPS._gui)
      if (!ctrl) {
        return
      }
    } catch Error as e {
      Log.Error("CalculateWeaponDPS", e)
    }

    MouseGetPos(&mouseX, &mouseY)
    WeaponDPS._gui.Show("NoActivate x" mouseX " y" mouseY)
    SetTimer((*) => WeaponDPS.Hide(), -WeaponDPS._AUTO_HIDE_MS)
  }

  static Hide() {
    if (WeaponDPS._gui) {
      WeaponDPS._gui.Destroy()
      WeaponDPS._gui := 0
      Sleep(100)
    }
  }
}
