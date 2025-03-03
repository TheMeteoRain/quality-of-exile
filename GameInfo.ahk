GameTitles := ["PathOfExile.exe", "PathOfExileSteam.exe"]
PoEMaxWidth := 3460

class GameInfo {
    HWND := 0
    Title := ""
    GameWidth := 0
    GameHeight := 0
    ScreenMiddleX := 0
    ScreenMiddleY := 0
    ScreenMiddleWithInventoryX := 0
    ScreenMiddleWithInventoryY := 0
    BlackBarSize := 0
    OverlayPosY := 0
    OverlayWidth := 200
    OverlayHeight := 200
    DivTradeAreaX := 1200
    DivTradeAreaY := 600
    DivTradeButtonX := 1200
    DivTradeButtonY := 955
    CenterUI := false

    __New(WinTitles := GameTitles, GameMaxWidth := PoEMaxWidth) {
        this.GameMaxWidth := PoEMaxWidth

        for index, title in WinTitles {
            exe := "ahk_exe " title
            if WinExist(exe) {
                this.HWND := WinWaitActive(exe)
                this.Title := exe
                break
            }
            Sleep 1000
        }

        ; Get window dimensions
        WinGetPos(&x, &y, &width, &height, this.HWND)

        this.GameWidth := width >= this.GameMaxWidth ? this.GameMaxWidth : width
        this.GameHeight := height
        this.BlackBarSize := this.GameWidth > this.GameMaxWidth ? (this.GameWidth - this.GameMaxWidth) / 2 : 0
        this.ScreenMiddleX := (this.BlackBarSize * 2 + this.GameWidth) / 2
        this.ScreenMiddleY := this.GameHeight / 2
        this.ScreenMiddleWithInventoryX := this.ScreenMiddleX - 450
        this.ScreenMiddleWithInventoryY := this.ScreenMiddleY - 150
        this.OverlayPosY := this.GameHeight - 250

        ; Adjust for full HD
        if (this.GameWidth == 1920 && this.GameHeight == 1080) {
            this.OverlayPosX := 450
            this.OverlayPosY := this.GameHeight - 200
            this.DivTradeAreaX := 630
            this.DivTradeAreaY := this.GameHeight - 630
            this.DivTradeButtonX := this.DivTradeAreaX
            this.DivTradeButtonY := this.GameHeight - 340
            this.ScreenMiddleWithInventoryX := this.ScreenMiddleX - 325
            this.ScreenMiddleWithInventoryY := this.ScreenMiddleY - 75
        }
    }

    ; Setter for OverlayPosX
    OverlayPosX {
        get => this.CenterUI ? this.BlackBarSize + 1200 : this.BlackBarSize + 600
    }

    ; Returns the object representation
    ToObject() {
        return {
            HWND: this.HWND,
            TITLE: this.Title,
            GAME_X: this.GameWidth,
            GAME_Y: this.GameHeight,
            SCREEN_MIDDLE_X: this.ScreenMiddleX,
            SCREEN_MIDDLE_Y: this.ScreenMiddleY,
            SCREEN_MIDDLE_WITH_INVENTORY_X: this.ScreenMiddleWithInventoryX,
            SCREEN_MIDDLE_WITH_INVENTORY_Y: this.ScreenMiddleWithInventoryY,
            BLACK_BAR_SIZE: this.BlackBarSize,
            OVERLAY_X: this.OverlayPosX,
            OVERLAY_Y: this.OverlayPosY,
            OVERLAY_WIDTH: this.OverlayWidth,
            OVERLAY_HEIGHT: this.OverlayHeight,
            DIV_TRADE_AREA_X: this.DivTradeAreaX,
            DIV_TRADE_AREA_Y: this.DivTradeAreaY,
            DIV_TRADE_BUTTON_X: this.DivTradeButtonX,
            DIV_TRADE_BUTTON_Y: this.DivTradeButtonY,
            CENTER_UI: this.CenterUI,
        }
    }
}
