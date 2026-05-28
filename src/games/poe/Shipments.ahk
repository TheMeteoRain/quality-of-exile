#Requires AutoHotkey v2.0

; Kingsmarch (PoE Settlers league) shipment auto-filler. Click the first
; numeric cell of the in-game shipments table, press the hotkey, and Fill()
; types each saved amount + Tab through the remaining cells.
;
; Quantities are configured via OpenEditor() — bound to the "Shipment values"
; button on the FillShipment row in Settings.
;
; `var` is each material name with spaces stripped — used as both the INI key
; and the editor Edit control's v-name so Gui.Submit picks it up.

class Shipments {
  static _data := Shipments._Build([
    "Crimson Iron Ore", "Orichalcum Ore", "Petrified Amber Ore", "Bishmut Ore", "Verisium Ore",
    "Crimson Iron Bar", "Orichalcum Bar", "Petrified Amber Bar", "Bishmut Bar", "Verisium Bar",
    "Wheat", "Corn", "Pumpkin", "Orgourd", "Blue Zanthimum", "Thaumaturgic Dust"
  ])

  static Fill(*) {
    Modifiers.Reset()
    for index, row in Shipments._data {
      SendInput("^a")
      SendInput(row.value)
      if (index != Shipments._data.Length) {
        SendInput("{Tab}")
        Sleep(100)
      }
    }
  }

  static Load() {
    for row in Shipments._data {
      row.value := IniRead(DATA_FILE, "Shipment", row.var, 0)
    }
  }

  static OpenEditor(*) {
    editor := Gui("+AlwaysOnTop", "Shipment Manager")
    x := 10, y := 20, w := 100

    for row in Shipments._data {
      editor.Add("Text", "x" x " y" y " w" w, row.name ":")
      editor.Add("Edit", "v" row.var " x" (x + 100) " y" y " w" w, row.value)
      y := y + 30
    }

    editor.Add("Button", "Default", "Save Shipment Values")
    .OnEvent("Click", (*) => Shipments._Save(editor))
    editor.Add("Button", , "Close")
    .OnEvent("Click", (*) => editor.Destroy())

    editor.Show()
  }

  static _Build(names) {
    data := []
    for _, name in names {
      data.Push({
        name: name,
        var: StrReplace(name, " ", ""),
        value: 0
      })
    }
    return data
  }

  static _Save(editor) {
    controls := editor.Submit()
    for row in Shipments._data {
      IniWrite(controls.%row.var%, DATA_FILE, "Shipment", row.var)
    }
    Shipments.Load()
  }
}
