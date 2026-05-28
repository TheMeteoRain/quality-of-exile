#Requires AutoHotkey v2.0

; Save / restore wrapper around A_Clipboard. One global instance `Clip`.

class ClipboardSaver {
  OriginalClipboard := ""

  Save() {
    Sleep(50)
    this.OriginalClipboard := A_Clipboard
    Sleep(50)
  }

  CopyWithAlt() {
    Send("{LAlt}^c")
    Sleep(25)
    Send("{LAlt up}")
    Sleep(25)
  }

  Paste() {
    Send("^v")
  }

  Clear() {
    A_Clipboard := ""
  }

  Restore() {
    Sleep(50)
    A_Clipboard := this.OriginalClipboard
    Sleep(50)
  }

  Set(value) {
    A_Clipboard := value
  }

  Get() {
    return A_Clipboard
  }
}

global Clip := ClipboardSaver()