class GameInfo {
    HWND := 0
    PID := 0
    ProcessPath := ""
    Titles := ["PathOfExile.exe", "PathOfExileSteam.exe"]
    Title := ""
    GameMaxWidth := 3460
    Windowed := false

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

    ; overlay
    OverlayPosX := 0
    OverlayPosY := 0
    OverlayWidth := 200
    OverlayHeight := 75

    __New() {
        while (!this.HWND) {
            this.AttachToGame()
        }

        WinGetPos(&x, &y, &width, &height, this.HWND)
        style := WinGetStyle(this.HWND)
        exStyle := WinGetExStyle(this.HWND)
    
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

        this.GamePosX := x
        this.GamePosY := y
        this.ScreenWidth := A_ScreenWidth
        this.ScreenHeight := A_ScreenHeight
        this.GameWidth := width >= this.GameMaxWidth ? this.GameMaxWidth : width
        this.GameHeight := height
        this.BlackBarSize := this.ScreenWidth - this.GameMaxWidth == 0 ? 0 : (this.ScreenWidth - this.GameMaxWidth) / 2
        this.OverlayPosX := this.GamePosX + this.BlackBarSize + this.GameWidth - this.OverlayWidth
        this.OverlayPosY := this.GamePosY + this.GameHeight - this.OverlayHeight

        this.CalculatePositions()
    }

    AttachToGame() {
        for index, title in this.Titles {
            exe := "ahk_exe " title
            if WinExist(exe) {
                this.HWND := WinWaitActive(exe)
                this.PID := WinGetPID(this.HWND)
                this.ProcessPath := ProcessGetPath(this.PID)
                this.Title := exe
                break
            }
            Sleep 1000
        }
    }

    GameClientExists() {
        return WinExist(this.HWND)
    }

    CalculatePositions() {
        if (this.GameWidth >= 2500 && this.GameWidth < 3400) {
            this.WideScreenPreset()
        } else if (this.GameWidth >= 3400) {
            this.UltraWideScreenPreset()
        } else {
            this.FullHDPreset()
        }
    }

    ; 1920x1080
    FullHDPreset() {
        this.ScreenMiddleX := this.GameWidth / 2
        this.ScreenMiddleY := this.GameHeight / 2
        this.ScreenMiddleWithInventoryX := this.ScreenMiddleX - 325
        this.ScreenMiddleWithInventoryY := this.ScreenMiddleY - 75
    }

    ; 2560x
    WideScreenPreset() {
        this.ScreenMiddleX := this.GameWidth / 2
        this.ScreenMiddleY := this.GameHeight / 2
        this.ScreenMiddleWithInventoryX := this.ScreenMiddleX - 450
        this.ScreenMiddleWithInventoryY := this.ScreenMiddleY - 125
    }

    ; 3460x
    UltraWideScreenPreset() {
        this.ScreenMiddleX := (this.BlackBarSize * 2 + this.GameWidth) / 2
        this.ScreenMiddleY := this.GameHeight / 2
        this.ScreenMiddleWithInventoryX := this.ScreenMiddleX - 450
        this.ScreenMiddleWithInventoryY := this.ScreenMiddleY - 150
    }
}
