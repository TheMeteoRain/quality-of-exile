#Requires AutoHotkey v2.0

class App {
  static _OVERLAY_REFRESH_MS := 5000   ; how often AdjustOverlay re-syncs HUD positions

  ; Same arrow each time so the same SetTimer ref turns it on and off.
  static _AdjustOverlayTimer := (*) => App._AdjustOverlay()

  ; Runs once at script start: attach to the game, load config + state, build
  ; the floating HUDs.
  static Boot() {
    ; Set up the tray menu BEFORE the blocking Game.AttachToGame() so the
    ; "Open Settings" entry is available even while waiting for the game.
    A_TrayMenu.Add()  ; separator
    A_TrayMenu.Add("Open Settings", (*) => Settings.Open())
    A_TrayMenu.Default := "Open Settings"

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
        Leaderboard.Start()
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

      if (!Game.GameClientExists()) {
        ; Game quit. Stop services and wipe Game state so the next
        ; AttachToGame() re-blocks on WinWaitActive instead of no-op'ing
        ; with a dead HWND (which would respin Show/Hide and leave the
        ; overlay visible).
        if (Game.GameIsPathOfExile()) {
          ClientLog.Stop()
          Leaderboard.Stop()
        }
        Game.Reset()
      } else {
        ; Plain alt-tab — game still running. Wait for it to come back
        ; before re-showing the overlay; otherwise WinWaitNotActive returns
        ; immediately on the now-inactive window and the loop busy-spins.
        ; Poll with a 1s timeout so we still notice if the game dies during
        ; the wait.
        loop {
          if (WinWaitActive(Game.Title,, 1)) {
            break
          }
          if (!Game.GameClientExists()) {
            break
          }
        }
      }
    }
  }

  ; SetTimer callback: re-syncs HUD positions when the game window moves.
  static _AdjustOverlay() {
    ; The game can lose focus between this timer firing and being turned off;
    ; bail so we neither block in CalculatePixels (WinWaitActive) nor re-show the
    ; overlay over another window.
    if (!Game.IsActive()) {
      return
    }
    Game.CalculatePixels()
    Overlay.Show()
    HUD.Show()
  }
}

App.Boot()
App.Run()