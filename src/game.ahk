#Requires AutoHotkey v2.0

; The attached game window. One global instance `Game` for the whole app;
; rebuilds on focus changes via Game.AttachToGame() from the main loop.

class GameInfo {
  ; Win32 window styles that indicate a windowed (non-fullscreen) game.
  static _WS_WINDOWED_MASK := 0xC00000 | 0x800000 | 0x40000  ; CAPTION | BORDER | THICKFRAME
  static _WS_EX_CLIENTEDGE := 0x4000000
  static _SM_CXSIZEFRAME := 32                              ; SysGet index

  HWND := 0
  PID := 0
  ProcessPath := ""
  ; PoE1 and PoE2 ship identical exe names — the Steam client of BOTH is
  ; PathOfExileSteam.exe, the standalone of both is PathOfExile.exe — so the exe
  ; can't tell them apart. They differ only by install folder ("Path of Exile"
  ; vs "Path of Exile 2"), so we detect the exe and resolve the variant from the
  ; process path (see AttachToGame). Last Epoch has its own exe.
  static _LastEpochExe := "Last Epoch.exe"
  static _GameExes := [
    "Last Epoch.exe",
    "PathOfExileSteam.exe",
    "PathOfExile.exe",
    "PathOfExile_x64Steam.exe",
    "PathOfExile_x64.exe",
  ]
  Title := ""
  Name := ""        ; "PathOfExile" or "LastEpoch" — used to match config.game
  Variant := ""     ; "PoE1" | "PoE2" | "LastEpoch" — namespaces pixel storage
  Windowed := false
  PreviousAttachTime := 0
  AttachTime := 0

  GameWidth := 0
  GameHeight := 0
  GamePosLeft := 0
  GamePosTop := 0
  ScreenMiddleWithInventoryX := 0
  ScreenMiddleWithInventoryY := 0
  GameWindowCenterX := 0
  GameWindowCenterY := 0

  OverlayPosX := 0
  OverlayPosY := 0
  OverlayWidth := 200
  OverlayHeight := 75
  HudPosX := 0
  HudPosY := 0

  CalculatePixels() {
    if (!this.GameClientActive() or !this.HWND) {
      return
    }

    try {
      WinGetPos(&x, &y, &width, &height, this.HWND)
    } catch Error {
      this.Reset()
      return this.AttachToGame()
    }
    style := WinGetStyle(this.HWND)
    exStyle := WinGetExStyle(this.HWND)

    this.Windowed := !!((style & GameInfo._WS_WINDOWED_MASK) | (exStyle & GameInfo._WS_EX_CLIENTEDGE))

    isGameMoved := this.GamePosLeft != x or this.GamePosTop != y
      or this.GameHeight != height or this.GameWidth != width
    if (!isGameMoved) {
      return
    }

    WinGetClientPos(&cx, &cy, &cw, &ch, this.HWND)

    this.GameWindowCenterX := x + width / 2
    this.GameWindowCenterY := y + height / 2
    this.GamePosLeft := x
    this.GamePosTop := y
    this.GameTitleBarHeight := height - ch - 9

    borderSizeX := SysGet(GameInfo._SM_CXSIZEFRAME)
    this.GameWidth := width
    this.GameHeight := height

    this.OverlayPosX := this.GamePosLeft + this.GameWidth - this.OverlayWidth
    this.OverlayPosY := this.GamePosTop + this.GameHeight - this.OverlayHeight - this.OverlayHeight / 2
    this.HudPosX := (this.GamePosLeft + this.GameWidth + (this.Windowed ? -borderSizeX * 2 : 0)) - 150
    this.HudPosY := this.GamePosTop + (this.Windowed ? this.GameTitleBarHeight : 0)

    this.ScreenMiddleWithInventoryX := this.GameWindowCenterX - Round(125 * (this.GameWindowCenterX / 1280) ** 0.55)
    this.ScreenMiddleWithInventoryY := Round(this.GameWindowCenterY - (this.GameWindowCenterY / 10))
  }

  GameIsPathOfExile() {
    return (this.Name == "PathOfExile")
  }

  GameIsLastEpoch() {
    return (this.Name == "LastEpoch")
  }

  ; INI key prefix namespacing per variant ("PoE1_" / "PoE2_" / "LE_").
  ; "" until a variant has been resolved.
  PixelPrefix() {
    switch this.Variant {
      case "PoE1": return "PoE1_"
      case "PoE2": return "PoE2_"
      case "LastEpoch": return "LE_"
    }
    return ""
  }

  AttachToGame() {
    gameProcessFound := false
    while (!this.HWND) {
      for exe in GameInfo._GameExes {
        title := "ahk_exe " exe

        if this.GameClientExists(title) {
          gameProcessFound := true
          this.Title := title
          this.PID := WinGetPID(title)
          this.ProcessPath := ProcessGetPath(this.PID)
          if (exe == GameInfo._LastEpochExe) {
            this.Name := "LastEpoch"
            this.Variant := "LastEpoch"
          } else {
            ; PoE1 vs PoE2 disambiguated by install folder, not exe name.
            this.Name := "PathOfExile"
            this.Variant := InStr(this.ProcessPath, "Path of Exile 2") ? "PoE2" : "PoE1"
          }
          this.HWND := this.GameClientActive(title)
          break
        }
        Sleep 1000
      }
    }

    if (gameProcessFound) {
      this.PreviousAttachTime := this.AttachTime
      this.AttachTime := A_Now
    }

    if (this.HWND) {
      this.CalculatePixels()
    }
  }

  Reset() {
    this.HWND := 0
    this.PID := 0
    this.ProcessPath := ""
    this.Title := ""
    this.Name := ""
    this.Variant := ""
    this.PreviousAttachTime := this.AttachTime
  }

  FocusGameWindow() {
    if (this.HWND) {
      try WinActivate(this.HWND)
    }
  }

  GameClientExists(title := this.Title) {
    return WinExist(title)
  }

  GameClientActive(title := this.Title) {
    return WinWaitActive(title)
  }

  GameClientNotActive() {
    return WinWaitNotActive(this.Title)
  }
}

global Game := GameInfo()