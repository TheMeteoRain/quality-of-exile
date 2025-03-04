class GameInfo {
    HWND := 0
    Titles := ["PathOfExile.exe", "PathOfExileSteam.exe"]
    Title := ""
    GameMaxWidth := 3460

    GameWidth := 0
    GameHeight := 0
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
    OverlayHeight := 200

    ; div
    DivTradeAreaX := 0
    DivTradeAreaY := 0
    DivTradeButtonX := 0
    DivTradeButtonY := 0

    CenterUI := false

    __New() {
        while (!this.HWND) {
            this.ConnectToGame()
        }

        WinGetPos(&x, &y, &width, &height, this.HWND)

        this.ScreenWidth := width
        this.ScreenHeight := height
        this.GameWidth := width >= this.GameMaxWidth ? this.GameMaxWidth : width
        this.GameHeight := height
        this.BlackBarSize := (this.ScreenWidth - this.GameMaxWidth) / 2

        this.CalculatePositions()
    }

    ConnectToGame() {
        for index, title in this.Titles {
            exe := "ahk_exe " title
            if WinExist(exe) {
                this.HWND := WinWaitActive(exe)
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
        if (this.GameWidth >= 2560 && this.GameMaxWidth < 3460) {
            this.WideScreenPreset()
        } else if (this.GameWidth >= 3460) {
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

        this.OverlayPosX := 450
        this.OverlayPosY := this.GameHeight - 200

        this.DivTradeAreaX := 630
        this.DivTradeAreaY := this.GameHeight - 630
        this.DivTradeButtonX := this.DivTradeAreaX
        this.DivTradeButtonY := this.GameHeight - 340
    }

    ; 2560x
    WideScreenPreset() {
        this.ScreenMiddleX := this.GameWidth / 2
        this.ScreenMiddleY := this.GameHeight / 2
        this.ScreenMiddleWithInventoryX := this.ScreenMiddleX - 450
        this.ScreenMiddleWithInventoryY := this.ScreenMiddleY - 125

        this.OverlayPosX := 590
        this.OverlayPosY := this.GameHeight - 200

        this.DivTradeAreaX := 840
        this.DivTradeAreaY := this.GameHeight - 840
        this.DivTradeButtonX := this.DivTradeAreaX
        this.DivTradeButtonY := this.GameHeight - 450
    }

    ; 3460x
    UltraWideScreenPreset() {
        this.ScreenMiddleX := (this.BlackBarSize * 2 + this.GameWidth) / 2
        this.ScreenMiddleY := this.GameHeight / 2
        this.ScreenMiddleWithInventoryX := this.ScreenMiddleX - 450
        this.ScreenMiddleWithInventoryY := this.ScreenMiddleY - 150

        this.OverlayPosX := 600
        this.OverlayPosY := this.GameHeight - 250

        this.DivTradeAreaX := 1300
        this.DivTradeAreaY := this.GameHeight - 830
        this.DivTradeButtonX := this.DivTradeAreaX
        this.DivTradeButtonY := this.GameHeight - 450
    }

    OverlayPosX {
        get => this._OverlayPosX
        set {
            this._OverlayPosX := this.BlackBarSize + Value
        }
    }

    CenterUI {
        get => this._CenterUI
        set {
            if (this.GameWidth < this.GameMaxWidth) {
                this._CenterUI := Value
                return
            }
            if (Value) {
                this._CenterUI := Value
                this.OverlayPosX := 1200
            } else {
                this._CenterUI := Value
                this.OverlayPosX := 600
            }
        }
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
