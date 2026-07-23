#Requires AutoHotkey v2.0

; Top-right card showing the Settings + Kill Switch keybinds + ladder rank.

class HUD {
  static _gui := 0
  static _rankLabel := 0

  static Create() {
    HUD._gui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
    HUD._gui.BackColor := MAIN_COLOR
    WinSetTransColor("Black 150", HUD._gui)

    HUD._gui.Add("Text", "x5 y5 h30 w110 cWhite", "Settings: " Storage.Bindings.Get("Settings", "Not Set"))
      .SetFont("s6 q2")
    HUD._gui.Add("Text", "x5 y23 h30 w110 cWhite", "Kill Switch: " Storage.Bindings.Get("KillSwitch", "Not Set"))
      .SetFont("s6 q2")
    HUD._rankLabel := HUD._gui.Add("Text", "x5 y41 h30 w110 cWhite", "Rank: --")
    HUD._rankLabel.SetFont("s6 q2")
  }

  static Show() {
    if (HUD._gui) {
      HUD._gui.Show("x" Game.HudPosX " y" Game.HudPosY " w120 h58 NoActivate")
    }
  }

  static Hide() {
    if (HUD._gui) {
      HUD._gui.Hide()
    }
  }

  static SetRank(text) {
    if (HUD._rankLabel) {
      HUD._rankLabel.Text := "Rank: " text
    }
  }
}
