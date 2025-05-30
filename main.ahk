#Requires AutoHotkey v2.0
#Include "operations.ahk"

Game.AttachToGame()
LoadConfigurations()
LoadShipmentValues()
LoadState()
CreateToggleOverlay()
CreateHUD()

AdjustOverlay(*) {
  Game.CalculatePixels()
  ShowToggleOverlay()
  ShowHUD()
}

Main() {
  global Game, clientFilePath, DynamicHotkeysActivated

  Game.AttachToGame()

  if (Game.GameIsPathOfExile()) {
    GetPoEClientFilePath()
    ListenToClientFile()
    DynamicHotkeys()
  }

  ShowToggleOverlay()
  ShowHUD()
  SetTimer(AdjustOverlay, 5000)

  if (Game.GameClientNotActive()) {
    HideToggleOverlay()
    HideHUD()
    ResetToggle()
    SetTimer(AdjustOverlay, 0)

    if (Game.GameIsPathOfExile() and !Game.GameClientExists()) {
      UnlistenClientFile()
      SetDynamicHotkeysState("Off")
    }

    Main()
  }
}

Main()