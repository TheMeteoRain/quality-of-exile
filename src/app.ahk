#Requires AutoHotkey v2.0

class App {
  static _OVERLAY_REFRESH_MS := 5000   ; how often AdjustOverlay re-syncs HUD positions

  ; Same arrow each time so the same SetTimer ref turns it on and off.
  static _AdjustOverlayTimer := (*) => App._AdjustOverlay()

  ; Runs once at script start: attach to the game, load config + state, build
  ; the floating HUDs.
  static Boot() {
    Game.AttachToGame()
    Storage.LoadConfig()
    Shipments.Load()
    Storage.LoadState()
    Overlay.Create()
    HUD.Create()
  }

  ; Focus-tracking loop: each iteration tracks one game-active session,
  ; arming HUDs + dynamic hotkeys while focused and tearing them down on
  ; focus loss.
  static Run() {
    loop {
      Game.AttachToGame()

      if (Game.GameIsPathOfExile()) {
        ClientLog.Start()
      }

      Overlay.Show()
      HUD.Show()
      SetTimer(App._AdjustOverlayTimer, App._OVERLAY_REFRESH_MS)

      ; Blocks until the game window is no longer active.
      Game.GameClientNotActive()

      Overlay.Hide()
      HUD.Hide()
      Modifiers.Reset()
      SetTimer(App._AdjustOverlayTimer, 0)

      if (Game.GameIsPathOfExile() and !Game.GameClientExists()) {
        ClientLog.Stop()
      }
    }
  }

  ; SetTimer callback: re-syncs HUD positions when the game window moves.
  static _AdjustOverlay() {
    Game.CalculatePixels()
    Overlay.Show()
    HUD.Show()
  }
}

App.Boot()
App.Run()