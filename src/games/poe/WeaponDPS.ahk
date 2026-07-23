#Requires AutoHotkey v2.0

; Runs copied item text through CalculateWeaponDPS and shows the result as a
; transparent overlay near the mouse for 5 seconds. Invoked from the item
; context menu.

class WeaponDPS {
  static _AUTO_HIDE_MS := 5000   ; popup self-dismisses after this long

  static _gui := 0

  ; Item text describes a weapon when it carries an attack-speed line.
  static IsWeapon(item) {
    return InStr(item, "Attacks per Second:")
  }

  static Show(item) {
    if (Debounce("WeaponDPS", 250)) {
      return
    }

    WeaponDPS.Hide()
    SetTimer((*) => WeaponDPS.Hide(), 0)

    WeaponDPS._gui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
    WeaponDPS._gui.BackColor := MAIN_COLOR
    WinSetTransparent("255", WeaponDPS._gui)

    try {
      ctrl := CalculateWeaponDPS(item, WeaponDPS._gui)
      if (!ctrl) {
        WeaponDPS.Hide()
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
