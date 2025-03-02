#Requires AutoHotkey v2.0

class ClipboardSaver {
    __New() {
        this.OriginalClipboard := ""
    }

    Save() {
        this.OriginalClipboard := A_Clipboard
    }

    Copy() {
        Send("^c")
    }

    Paste() {
        Send("^v")
    }

    Clear() {
        A_Clipboard := ""
    }

    Restore() {
        Sleep(100)
        A_Clipboard := this.OriginalClipboard
    }

    Set(value) {
        A_Clipboard := value
    }

    Get() {
        return A_Clipboard
    }

    IsItem() {
        result := false

        this.Save()
        this.Copy()

        Sleep(10)
        if (RegExMatch(this.Get(), "Item Class")) {
            result := true
        }

        return result
    }
}