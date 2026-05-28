#Requires AutoHotkey v2.0

; Top-right card showing the Settings + Kill Switch keybinds.

class HUD {
  static _gui := 0

  static Create() {
    HUD._gui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
    HUD._gui.BackColor := MAIN_COLOR
    WinSetTransColor("Black 150", HUD._gui)

    HUD._gui.Add("Text", "x5 y5 h30 w100 cWhite", "Settings: " Storage.Bindings.Get("Settings", "Not Set"))
    .SetFont("s6 q2")
    HUD._gui.Add("Text", "x5 y23 h30 w100 cWhite", "Kill Switch: " Storage.Bindings.Get("KillSwitch", "Not Set"))
    .SetFont("s6 q2")
  }

  static Show() {
    if (HUD._gui) {
      HUD._gui.Show("x" Game.HudPosX " y" Game.HudPosY " w120 h40 NoActivate")
    }
  }

  static Hide() {
    if (HUD._gui) {
      HUD._gui.Hide()
    }
  }
}
