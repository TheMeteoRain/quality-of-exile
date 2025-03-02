#Requires AutoHotkey v2.0

class MousePositionSaver {
    __New() {
        this.OriginalX := 0
        this.OriginalY := 0
        this.Win := 0
    }

    SavePosition() {
        MouseGetPos(&OriginalX, &OriginalY, &Win)
        this.OriginalX := OriginalX
        this.OriginalY := OriginalY
        this.Win := Win
    }

    RestorePosition() {
        MouseMove(this.OriginalX, this.OriginalY, this.Win)
    }
}