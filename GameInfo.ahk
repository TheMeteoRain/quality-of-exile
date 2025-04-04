class GameInfo {
    HWND := 0
    PID := 0
    ProcessPath := ""
    Titles := ["PathOfExile.exe", "PathOfExileSteam.exe"]
    Title := ""
    GameMaxWidth := 3460
    Windowed := false
    PreviousAttachTime := 0
    AttachTime := 0

    GameWidth := 0
    GameHeight := 0
    GamePosX := 0
    GamePosY := 0
    ScreenWidth := 0
    ScreenHeight := 0
    ScreenMiddleX := 0
    ScreenMiddleY := 0
    ScreenMiddleWithInventoryX := 0
    ScreenMiddleWithInventoryY := 0
    BlackBarSize := 0
    GameWindowCenterX := 0
    GameWindowCenterY := 0

    ; overlay
    OverlayPosX := 0
    OverlayPosY := 0
    OverlayWidth := 200
    OverlayHeight := 75
    HudPosX := 0
    HudPosY := 0

    __New() {

    }

    CalculatePixels() {
        if (!this.GameClientActive() or !this.HWND) {
            return
        }

        try {
            WinGetPos(&x, &y, &width, &height, this.HWND)
        } catch Error as e {
            this.Reset()
            return this.AttachToGame()
        }
        style := WinGetStyle(this.HWND)
        exStyle := WinGetExStyle(this.HWND)
        gameWidth := width >= this.GameMaxWidth ? this.GameMaxWidth : width

        isGameMoved := this.GamePosX != x or this.GamePosY != y or this.GameHeight != height or this.GameWidth != gameWidth

        this.Windowed := false
        ; Check for styles typically absent in exclusive fullscreen
        if (style & 0xC00000) ; WS_CAPTION
            this.Windowed := true
        if (style & 0x800000) ; WS_BORDER
            this.Windowed := true
        if (style & 0x40000)  ; WS_THICKFRAME
            this.Windowed := true
        if (exStyle & 0x4000000) ; WS_EX_CLIENTEDGE (often indicates borders)
            this.Windowed := true

        if (isGameMoved) {
            WinGetClientPos(&cx, &cy, &cw, &ch, this.HWND)

            this.GameWindowCenterX := x + width / 2
            this.GameWindowCenterY := y + height / 2
            this.ScreenWidth := A_ScreenWidth
            this.ScreenHeight := A_ScreenHeight
            this.GamePosX := x
            this.GamePosY := y
            this.GameTitleBarHeight := height - ch - 9

            monitor := 1
            monCount := MonitorGetCount()
            Loop monCount {
                MonitorGetWorkArea(A_Index, &mx, &my, &mw, &mh)
            
                ; Check if the window's center is within this monitor's bounds
                if (A_Index > 1 && this.GameWindowCenterX >= mx && this.GameWindowCenterX < mx + mw && this.GameWindowCenterY >= my && this.GameWindowCenterY < my + mh) {
                    this.ScreenWidth := mw - this.ScreenWidth
                    this.ScreenHeight := mh - this.ScreenHeight
    
                    monitor := A_Index
                    break
                }
            }

            borderSizeX := SysGet(32) ;SM_CXSIZEFRAME = horizontal border size
            this.GameWidth := width >= this.GameMaxWidth ? this.GameMaxWidth : width
            this.GameHeight := height
            this.BlackBarSize := this.Windowed ? 0 : (this.ScreenWidth - this.GameWidth == 0 ? 0 : (this.ScreenWidth - this.GameWidth) / 2)

            this.OverlayPosX := this.GamePosX + this.BlackBarSize + this.GameWidth - this.OverlayWidth
            this.OverlayPosY := this.GamePosY + this.GameHeight - this.OverlayHeight - this.OverlayHeight/2
            this.HudPosX := (this.GamePosX + this.GameWidth + this.BlackBarSize + (this.Windowed ? -borderSizeX*2 : 0)) - 150
            this.HudPosY := this.GamePosY + (this.Windowed ? this.GameTitleBarHeight : 0)

            this.ScreenMiddleX := (this.BlackBarSize * 2 + this.GameWidth) / 2
            this.ScreenMiddleY := this.GameHeight / 2
            this.ScreenMiddleWithInventoryX := this.ScreenMiddleX - Round(125 * (this.ScreenWidth / 1280) ** 0.55)
            this.ScreenMiddleWithInventoryY := Round(this.ScreenMiddleY - (this.ScreenMiddleY/10))


        }
    }

    AttachToGame() {
        gameProcessFound := false
        while (!this.HWND) {
            for index, title in this.Titles {
                exe := "ahk_exe " title

                if this.GameClientExists(exe) {
                    gameProcessFound := true
                    this.Title := exe
                    this.PID := WinGetPID(exe)
                    this.ProcessPath := ProcessGetPath(this.PID)
                    this.HWND := this.GameClientActive(exe)

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
        this.PreviousAttachTime := this.AttachTime
    }

    FocusGameWindow() {
        if (this.GameClientExists()) {
            WinActivate(this.HWND)
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
