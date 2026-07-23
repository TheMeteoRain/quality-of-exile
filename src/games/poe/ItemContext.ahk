#Requires AutoHotkey v2.0

; Hover an item, hit the hotkey: we Ctrl+Alt+C the item and pop a context menu
; near the cursor — jump to its affixes on Craft of Exile (when the base matches
; a bundled dataset) and, for weapons, a DPS breakdown. Silently no-ops when the
; item offers neither — common for currency, maps, etc.

class ItemContext {
  ; Sorted longest-first so the substring scan picks the most specific base
  ; (e.g. "Composite Bow" beats "Bow" when both could match a magic item).
  static _bases := Map()  ; variant -> Array of {name, idBase, idBitem}

  static _COE_URL := Map(
    "PoE1", "https://www.craftofexile.com/?game=poe1",
    "PoE2", "https://www.craftofexile.com/?game=poe2",
  )

  ; --- Public ---

  static Show(*) {
    if (Debounce("ItemContext", 250)) {
      return
    }
    if (!Game.HWND or !ItemContext._COE_URL.Has(Game.Variant)) {
      return
    }

    text := ItemContext._Copy()
    if (text == "") {
      return
    }

    ; Name can't be `menu` — AHK is case-insensitive so a local `menu` shadows
    ; the built-in `Menu` class and breaks the constructor call.
    popup := Menu()
    entries := 0

    base := ItemContext._MatchBase(Game.Variant, text)
    if (base) {
      coeUrl := ItemContext._CoeUrl(Game.Variant, base, text)
      popup.Add("Affixes (Craft of Exile)", (*) => Run(coeUrl))
      entries++
    }

    if (WeaponDPS.IsWeapon(text)) {
      popup.Add("Calculate Weapon DPS", (*) => WeaponDPS.Show(text))
      entries++
    }

    if (entries == 0) {
      return  ; nothing to offer — stay silent
    }
    popup.Show()
  }

  ; --- Internal ---

  static _Copy() {
    Clip.Save()
    Clip.Clear()
    Clip.CopyWithAlt()
    text := Clip.Get()
    Clip.Restore()
    return text
  }

  static _CoeUrl(variant, base, text) {
    qs := Format("&b={}&bi={}", base.idBase, base.idBitem)
    if (ilvl := ItemContext._ExtractILvl(text)) {
      qs .= "&lv=" ilvl
    }
    return ItemContext._COE_URL[variant] qs
  }

  ; The dataset is sorted longest-first; the first substring hit wins,
  ; which naturally handles magic items like "Sturdy Composite Bow of
  ; Roaring" — "Composite Bow" matches before plain "Bow" would.
  static _MatchBase(variant, text) {
    for _, row in ItemContext._LoadData(variant) {
      if (InStr(text, row.name)) {
        return row
      }
    }
    return false
  }

  static _ExtractILvl(text) {
    if (RegExMatch(text, "im)^Item Level:\s*(\d+)", &m)) {
      return m[1]
    }
    return ""
  }

  static _LoadData(variant) {
    if (ItemContext._bases.Has(variant)) {
      return ItemContext._bases[variant]
    }
    slug := variant == "PoE1" ? "poe1" : "poe2"
    path := Format("{}\src\data\coe\bases_{}.tsv", A_ScriptDir, slug)
    rows := []
    if (FileExist(path)) {
      for _, line in StrSplit(FileRead(path, "UTF-8"), "`n", "`r") {
        if (line == "") {
          continue
        }
        parts := StrSplit(line, "`t")
        if (parts.Length < 3) {
          continue
        }
        rows.Push({ name: parts[1], idBase: parts[2], idBitem: parts[3] })
      }
    } else {
      Log.Error("ItemContext: missing dataset " path)
    }
    ItemContext._bases[variant] := rows
    return rows
  }
}
