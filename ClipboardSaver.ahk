#Requires AutoHotkey v2.0

class ClipboardSaver {
  __New() {
    this.OriginalClipboard := ""
  }

  Save() {
    Sleep(50)
    this.OriginalClipboard := A_Clipboard
    Sleep(50)
  }

  Copy() {
    Send("^c")
    Sleep(50)
  }

  CopyWithAlt() {
    Send("!^c")
    Sleep(50)
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

  IsItem() {
    this.Save()
    this.Copy()
    cp := this.Get()
    this.Restore()
    if (RegExMatch(cp, "Item Class")) {
      return true
    }

    return false
  }

  IsWeapon() {
    this.Save()
    this.Copy()
    cp := this.Get()
    this.Restore()
    if (RegExMatch(cp, "Attacks per Second: ")) {
      return true
    }

    return false
  }
}
