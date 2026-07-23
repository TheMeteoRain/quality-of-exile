#Requires AutoHotkey v2.0

; The Settings GUI — opens with the user's Settings keybind. Lets them rebind
; hotkeys, pick pixel coordinates, edit chat-command / regexp text, etc.
;
; Public API:
;   Settings.Open()       open / focus the window
;   Settings.Close()      hide it
;   Settings.Submit()     return the GUI's submitted controls (used by Storage.SaveConfig)
;
; Everything else (rendering, capture, pixel picker, tooltips) is private.

class Settings {
  ; ============================ Public API ============================

  static _gui := 0

  static Open(*) {
    global Configs

    ; If no game is attached yet (Settings opened via tray before game launch),
    ; default to PoE1 so fields populate. User can switch via the dropdown.
    if (Game.Variant == "") {
      Settings._SetGameVariant(1)
      Storage.LoadConfig()
    }

    if (Settings._gui) {
      Settings._gui.Destroy()
    }

    L := Settings._LAYOUT
    legend := "(D): Dynamic Hotkey"

    Settings._gui := Gui("+AlwaysOnTop +ToolWindow", "Quality of Exile")
    Settings._gui.Add("Text", Format("x{} y{} w300", L.legendX, L.legendY), legend).SetFont("w700")

    ; Game variant selector (top-right). Locked when a game is auto-detected.
    ddlX := L.windowW - 130
    Settings._gui.Add("Text", Format("x{} y{} w40 Right", ddlX - 45, L.legendY + 2), "Game:")
    gameDdl := Settings._gui.Add("DropDownList", Format("x{} y{} w120", ddlX, L.legendY - 2), Settings._VARIANT_LABELS)
    gameDdl.Choose(Settings._VariantIndex())
    if (Game.HWND) {
      gameDdl.Enabled := false
    }
    gameDdl.OnEvent("Change", (*) => Settings._SwitchGame(gameDdl.Value, tabCtrl.Value))

    OnMessage(Settings._WM_MOUSEMOVE, (wp, lp, msg, hwnd) => Settings._HandleHover(wp, lp, msg, hwnd))

    tabs := ["General", "PoE Commands", "PoE Regexp", "PoE Crafting", "PoE Inventory", "Last Epoch"]
    tabCtrl := Settings._gui.Add(
      "Tab3",
      Format("x{} y{} w{} h1300", L.tabX, L.tabY, L.windowW - L.tabX * 2),
      tabs
    )

    tabHeights := Map()
    for _, tab in tabs {
      tabCtrl.UseTab(tab)
      bottom := Settings._RenderTabGrid(tab, L.contentY)
      tabHeights[tab] := bottom + L.tabPad - L.tabY
    }
    tabCtrl.UseTab("")

    minTabH := tabHeights.Has("General") ? tabHeights["General"] : 0
    ; Restore the tab the user was on before a re-open (e.g. game-variant switch).
    if (Settings._pendingTabIndex > 0) {
      tabCtrl.Choose(Settings._pendingTabIndex)
    }
    initialTab := tabs[tabCtrl.Value]
    initialTabH := Max(tabHeights[initialTab], minTabH)
    tabCtrl.Move(, , , initialTabH)

    initialFooterY := L.tabY + initialTabH + L.footerGap
    footer := Settings._RenderFooter(initialFooterY)

    tabCtrl.OnEvent("Change", (*) => Settings._OnTabChange(tabCtrl, tabs, tabHeights, minTabH, footer))

    initialWindowH := initialFooterY + L.footerBottom + L.windowBottomPad
    if (Game.GameWindowCenterX > 0) {
      Settings._gui.Show(Format(
        "x{} y{} w{} h{}",
        Game.GameWindowCenterX - L.windowW / 2, Game.GameWindowCenterY - initialWindowH / 2,
        L.windowW, initialWindowH
      ))
    } else {
      ; No game attached yet — center on the active monitor.
      Settings._gui.Show(Format("w{} h{} Center", L.windowW, initialWindowH))
    }
    ControlFocus(Settings._gui, Settings._gui.Title)
  }

  static Close(*) {
    ToolTip()
    Settings._gui.Hide()
    Game.FocusGameWindow()
  }

  static Submit() {
    return Settings._gui.Submit()
  }

  ; Order matches Settings._VariantIndex and Settings._SwitchGame.
  static _VARIANT_LABELS := ["PoE1", "PoE2", "Last Epoch"]

  static _VariantIndex() {
    switch Game.Variant {
      case "PoE2": return 2
      case "LastEpoch": return 3
      default: return 1   ; PoE1 or unset
    }
  }

  static _SetGameVariant(idx) {
    static profiles := [
      { name: "PathOfExile", variant: "PoE1" },
      { name: "PathOfExile", variant: "PoE2" },
      { name: "LastEpoch",   variant: "LastEpoch" },
    ]
    p := profiles[idx]
    Game.Name := p.name
    Game.Variant := p.variant
  }

  static _pendingTabIndex := 0

  static _SwitchGame(idx, tabIndex := 0) {
    Settings._SetGameVariant(idx)
    Settings._pendingTabIndex := tabIndex
    Storage.LoadConfig()
    Settings.Open()
    Settings._pendingTabIndex := 0
  }

  ; ============================ Layout / constants ============================

  static _LAYOUT := {
    windowW: 580,
    legendX: 20,
    legendY: 10,
    tabX: 10,
    tabY: 35,
    contentY: 70,
    tabPad: 8,
    padX: 20,
    colSpacing: 175,
    fieldW: 150,
    inlineGap: 5,
    setBtnW: 70,
    rowH: 30,
    titleH: 22,
    titlePad: 2,
    groupGap: 20,
    regexpH: 60,
    footerGap: 12,
    footerLinkY: 35,
    footerBottom: 60,
    windowBottomPad: 15,
    buttonW: 200,
  }

  static _CAPTURE_HINT := "Click to bind a key"
  static _CAPTURE_PROMPT := "Press a key or mouse button..."
  static _CAPTURE_MOUSE_BUTTONS := ["MButton", "XButton1", "XButton2"]
  static _MODIFIER_KEYS := Map(
    "Control", true, "LControl", true, "RControl", true,
    "Alt", true, "LAlt", true, "RAlt", true,
    "Shift", true, "LShift", true, "RShift", true,
    "LWin", true, "RWin", true,
  )

  ; Win32 message IDs.
  static _WM_MOUSEMOVE := 0x0200
  static _EM_SETCUEBANNER := 0x1501

  static _KEYBIND_BG_DEFAULT := "FFFFFF"
  static _KEYBIND_BG_HOVER := "DDE6F5"
  static _KEYBIND_FG_DEFAULT := "000000"
  static _KEYBIND_FG_HOVER := "1565C0"
  static _TOOLTIP_WRAP_WIDTH := 60
  static _TOOLTIP_GAP := 8

  ; Per-slot display names for multi-pixel configs (vars).
  static _PixelLabels := Map(
    "TradeDivinationCardButton", "Trade Divination Card Button",
    "TradeDivinationCardItemArea", "Trade Divination Card Item Area",
    "ShatterItemButton", "Shatter Item Button",
    "ShatterItemRuneSelection", "Shatter Item Rune Selection",
    "ShatterItemShatterRune", "Shatter Item Shatter Rune",
  )

  ; ============================ Private state ============================

  static _capture := {
    active: false,
    field: "",
    prev: "",
    key: "",
    hook: ""
  }
  static _ttHoveredHwnd := 0
  static _ttHoveredKeybind := ""

  ; ============================ Rendering ============================

  static _OnTabChange(tabCtrl, tabs, tabHeights, minTabH, footer, *) {
    L := Settings._LAYOUT
    tabCtrl.Focus()

    active := tabs[tabCtrl.Value]
    if (!tabHeights.Has(active)) {
      return
    }

    newTabH := Max(tabHeights[active], minTabH)
    tabCtrl.Move(, , , newTabH)

    newFooterY := L.tabY + newTabH + L.footerGap
    footer.versionText.Move(, newFooterY)
    footer.link.Move(, newFooterY + L.footerLinkY)
    footer.saveBtn.Move(, newFooterY)
    footer.closeBtn.Move(, newFooterY + L.rowH)

    ; Gui.Show sets the CLIENT area; Gui.Move would set outer and clip footer.
    ; NA = NoActivate (resize without stealing focus).
    newClientH := newFooterY + L.footerBottom + L.windowBottomPad
    Settings._gui.Show(Format("w{} h{} NA", L.windowW, newClientH))
  }

  ; Row-major grid render. Returns y just below the last rendered item.
  static _RenderTabGrid(tab, startY) {
    L := Settings._LAYOUT
    rows := Map()
    maxRow := -1
    for key, config in Configs {
      if (!config.HasProp("tab") or config.tab != tab) {
        continue
      }
      if (!config.HasProp("row") or !config.HasProp("col")) {
        continue
      }
      r := config.row
      maxRow := Max(maxRow, r)
      if (!rows.Has(r)) {
        rows[r] := []
      }
      rows[r].Push({
        key: key,
        config: config
      })
    }

    y := startY
    loop maxRow + 1 {
      rowIdx := A_Index - 1
      if (!rows.Has(rowIdx)) {
        continue
      }

      items := rows[rowIdx]
      for _, item in items {
        if (ConfigBool(item.config, "gap")) {
          y += L.groupGap
          break
        }
      }

      rowBottom := y
      for _, item in items {
        x := L.padX + item.config.col * L.colSpacing
        rowBottom := Max(rowBottom, Settings._RenderConfigItem(item.key, item.config, x, y))
      }
      y := rowBottom
    }
    return y
  }

  static _ConfigWidth(config) {
    L := Settings._LAYOUT
    span := config.HasProp("span") ? config.span : 1
    return L.fieldW + (span - 1) * L.colSpacing
  }

  static _RenderConfigItem(key, config, x, y) {
    L := Settings._LAYOUT
    w := Settings._ConfigWidth(config)

    titleCtrl := Settings._gui.Add("Text", Format("x{} y{} w{}", x, y, w), config.name)
    titleCtrl.SetFont("bold")
    titleCtrl.GetPos(&_tx, &_ty, &_tw, &titleH)
    y += Max(titleH, L.titleH) + L.titlePad

    section := config.HasProp("section") ? config.section : ""
    if (section == "Hotkey") {
      y := Settings._RenderHotkey(key, config, x, y, w)
    } else if (section == "Toggle") {
      y := Settings._RenderCheckbox(key, config, x, y, w)
    } else if (ConfigBool(config, "pixelSelect")) {
      y := Settings._RenderPixel(config, key, x, y, w)
    }

    ; Sub-row controls (mutually exclusive).
    if (ConfigBool(config, "regexpField")) {
      y := Settings._RenderRegexp(key, config, x, y, w)
    } else if (key == "FillShipment") {
      y := Settings._RenderShipment(key, config, x, y, w)
    } else if (config.HasProp("dropdown")) {
      y := Settings._RenderDropdown(key, config, x, y, w)
    } else if (ConfigBool(config, "textField")) {
      y := Settings._RenderText(key, config, x, y, w)
    }

    ; labelField is additive on top of the sub-row above.
    if (ConfigBool(config, "labelField")) {
      y := Settings._RenderLabel(key, x, y, w)
    }

    return y + L.footerGap
  }

  static _RenderHotkey(key, config, x, y, w) {
    L := Settings._LAYOUT
    hotkeyValue := Storage.Bindings.Get(key, "")

    ; Text (not Edit): Edit auto-starts capture on Tab3 focus, and Click
    ; doesn't refire on already-focused Edits.
    display := Settings._gui.Add(
      "Text",
      Format("x{} y{} w{} h22 Border Center 0x200 Background" Settings._KEYBIND_BG_DEFAULT, x, y, w),
      Settings._DisplayValueFor(hotkeyValue)
    )
    display.IsKeybindField := true
    Settings._AttachTooltip(display, config)

    ; Hidden Edit mirrors the value for Settings._gui.Submit (v-names only).
    hidden := Settings._gui.Add(
      "Edit",
      Format("v{} x-1000 y0 w10 Hidden", key),
      hotkeyValue
    )
    display.HiddenMirror := hidden
    display.OnEvent("Click", (*) => Settings._StartCapture(display, key))
    y += L.rowH

    if (ConfigBool(config, "pixelSelect")) {
      vars := (config.HasProp("vars") and config.vars.Length > 0) ? config.vars : [key]
      for _, var in vars {
        y := Settings._RenderPixel(config, var, x, y, w)
      }
    }

    return y
  }

  static _RenderPixel(config, var, x, y, w) {
    L := Settings._LAYOUT
    ; Overlay position is the only hand-editable pixel field.
    editable := var == "ToggleOverlayPosition"
    valueW := w - L.inlineGap - L.setBtnW

    textCtrl := Settings._gui.Add(
      "Edit",
      Format(
        "v{}Pixel x{} y{} w{} +Center{}",
        var, x, y, valueW, editable ? "" : " Readonly"
      ),
      Storage.UserValues.Get(var, "")
    )
    if (editable and !textCtrl.Value) {
      textCtrl.Value := Format("{}x{}", Game.OverlayPosX, Game.OverlayPosY)
    }
    oldValue := textCtrl.Value
    textCtrl.OnEvent("Change", (ctrl, *) => Settings._ValidatePixel(oldValue, ctrl))

    btnX := x + valueW + L.inlineGap
    btn := Settings._gui.Add("Button", Format("v{}PixelSelect x{} y{} w{}", var, btnX, y, L.setBtnW), "Set pixel")
    btn.OnEvent("Click", (*) => Settings._SelectPixel(btn, textCtrl, config))

    ; Set pixel buttons get a per-slot tooltip telling the user what to click.
    if (config.HasProp("pixelTooltips") and config.pixelTooltips.Has(var)) {
      btn.Tooltip := config.pixelTooltips[var]
    }

    return y + L.rowH
  }

  static _RenderCheckbox(key, config, x, y, w) {
    L := Settings._LAYOUT
    Settings._gui.Add("Text", Format("x{} y{} w50", x, y + 4), "Enabled")
    ctrl := Settings._gui.Add("Checkbox", Format("v{} x{} y{}", key, x + 50, y + 4))
    ctrl.Value := Storage.Bindings.Get(key, 0)
    Settings._AttachTooltip(ctrl, config)
    return y + L.rowH
  }

  static _RenderRegexp(key, config, x, y, w) {
    L := Settings._LAYOUT
    regexp := Storage.UserValues.Get(key, "")
    edit := Settings._gui.Add(
      "Edit",
      Format(
        "v{}_extra x{} y{} w{} Limit{} -VScroll h{}",
        key, x, y, w, REGEXP_CHARACTER_LIMIT, L.regexpH
      ),
      regexp
    )
    ; disable for textareas
    ;Settings._AttachTooltip(edit, config)
    y += L.regexpH
    limit := Settings._gui.Add(
      "Text",
      Format("x{} y{} w{}", x, y, w),
      Format("{} / {}  |  don't include quotation marks", StrLen(regexp), REGEXP_CHARACTER_LIMIT)
    )
    edit.OnEvent("Change", (ctrl, *) => Settings._UpdateCharLimit(limit, ctrl))
    return y + L.rowH
  }

  static _RenderShipment(key, config, x, y, w) {
    L := Settings._LAYOUT
    btn := Settings._gui.Add("Button", Format("v{}_extra x{} y{} w{}", key, x, y, w), "Shipment values")
    btn.OnEvent("Click", Shipments.OpenEditor)
    Settings._AttachTooltip(btn, config)
    return y + L.rowH
  }

  static _RenderText(key, config, x, y, w) {
    L := Settings._LAYOUT
    edit := Settings._gui.Add(
      "Edit",
      Format("v{}_extra x{} y{} w{}", key, x, y, w),
      Storage.UserValues.Get(key, "")
    )
    if (config.HasProp("placeholder") and config.placeholder != "") {
      SendMessage(Settings._EM_SETCUEBANNER, 0, StrPtr(config.placeholder), edit)
    }
    ; disable
    ;Settings._AttachTooltip(edit, config)
    return y + L.rowH
  }

  ; Dropdown whose options come from config.dropdown — a function that
  ; returns an Array of strings (e.g. fetched league names). When the call
  ; returns nothing and the config provides `emptyError`, render a disabled
  ; dropdown with the error text in its label slot instead.
  static _RenderDropdown(key, config, x, y, w) {
    L := Settings._LAYOUT
    options := config.dropdown.Call()
    if (options.Length == 0 and config.HasProp("emptyError")) {
      ; No v-name on purpose — keeps Submit from overwriting the stored
      ; league value with the error placeholder.
      ddl := Settings._gui.Add(
        "DropDownList",
        Format("x{} y{} w{}", x, y, w),
        [config.emptyError]
      )
      ddl.Choose(1)
      ddl.Enabled := false
      Settings._AttachTooltip(ddl, config)
      return y + L.rowH
    }
    ddl := Settings._gui.Add(
      "DropDownList",
      Format("v{}_extra x{} y{} w{}", key, x, y, w),
      options
    )
    current := Storage.UserValues.Get(key, "")
    if (current != "") {
      for i, opt in options {
        if (opt == current) {
          ddl.Choose(i)
          break
        }
      }
    }
    Settings._AttachTooltip(ddl, config)
    return y + L.rowH
  }

  ; Mnemonic field for currency slots — does not affect runtime.
  static _RenderLabel(key, x, y, w) {
    L := Settings._LAYOUT
    edit := Settings._gui.Add(
      "Edit",
      Format("v{}_label x{} y{} w{}", key, x, y, w),
      Storage.SlotLabels.Get(key, "")
    )
    SendMessage(Settings._EM_SETCUEBANNER, 0, StrPtr("Label / mnemonic"), edit)
    return y + L.rowH
  }

  static _RenderFooter(y) {
    L := Settings._LAYOUT
    centerBtnX := L.windowW / 2 - L.buttonW / 2

    versionText := Settings._gui.Add(
      "Text", Format("x0 y{} w200 Center", y), "QualityOfExile version:`n" VERSION
    )
    link := Settings._gui.Add(
      "Link",
      Format("x{} y{} w{}", L.padX * 2, y + L.footerLinkY, L.fieldW),
      Format('<a href="{}">Github / Documentation</a>', GITHUB_URL)
    )
    saveBtn := Settings._gui.Add(
      "Button", Format("x{} y{} w{} Default", centerBtnX, y, L.buttonW), "Save And Reload"
    )
    saveBtn.OnEvent("Click", (*) => Storage.SaveConfig())
    closeBtn := Settings._gui.Add(
      "Button", Format("x{} y{} w{} ", centerBtnX, y + L.rowH, L.buttonW), "Close"
    )
    closeBtn.OnEvent("Click", (*) => Settings.Close())

    return {
      versionText: versionText,
      link: link,
      saveBtn: saveBtn,
      closeBtn: closeBtn
    }
  }

  static _AttachTooltip(ctrl, config) {
    if (!config.HasProp("tooltip") or config.tooltip == "") {
      return
    }
    ctrl.Tooltip := config.tooltip
  }

  static _DisplayValueFor(storedValue) {
    return storedValue == "" ? Settings._CAPTURE_HINT : storedValue
  }

  static _ValidatePixel(oldValue, GuiCtrlObj, *) {
    resolution := ParseResolution(GuiCtrlObj.Value)
    if (!resolution) {
      GuiCtrlObj.Value := oldValue
    }
  }

  static _UpdateCharLimit(LimitControl, RegExpControl, *) {
    ControlSetText(
      Format(
        "{} / {}  |  don't include quotation marks",
        StrLen(RegExpControl.Value),
        REGEXP_CHARACTER_LIMIT
      ),
      LimitControl
    )
  }

  ; ============================ Hotkey capture ============================
  ; Click a keybind field → next key or mouse button binds it. Esc cancels,
  ; Backspace clears. One capture at a time.

  static _StartCapture(field, key, *) {
    if (Settings._capture.active) {
      return
    }
    Settings._capture.active := true
    Settings._capture.field := field
    Settings._capture.prev := field.HiddenMirror.Value
    Settings._capture.key := key
    field.Text := Settings._CAPTURE_PROMPT

    HotIfWinActive("ahk_id " Settings._gui.Hwnd)
    for _, btn in Settings._CAPTURE_MOUSE_BUTTONS {
      Hotkey("*" btn, ((b) => (*) => Settings._CaptureFromMouse(b))(btn), "On")
    }
    HotIf()

    Settings._StartCaptureHook()
  }

  ; Split out so a modifier-only press can restart capture cheaply.
  static _StartCaptureHook() {
    ; No `V`: suppress so captured Home doesn't also fire KillSwitch etc.
    ih := InputHook("L1")
    ih.KeyOpt("{All}", "E")
    ih.OnEnd := (h) => Settings._KeyboardCaptured(h)
    ih.Start()
    Settings._capture.hook := ih
  }

  static _CaptureFromMouse(button, *) {
    Settings._FinishCapture(button)
  }

  static _KeyboardCaptured(ih) {
    key := ih.EndKey
    if (key == "Escape") {       ; cancel
      Settings._FinishCapture(Settings._capture.prev)
      return
    }
    if (key == "Backspace" or key == "Delete") {    ; clear
      Settings._FinishCapture("")
      return
    }
    if (Settings._MODIFIER_KEYS.Has(key)) {  ; wait for non-modifier
      Settings._StartCaptureHook()
      return
    }
    Settings._FinishCapture(key)
  }

  ; Pass "" to clear, prev to cancel, or a key/mouse string to bind. On
  ; conflict the value is reverted and the user is told via MsgBox.
  static _FinishCapture(value, *) {
    if (!Settings._capture.active) {
      return
    }

    ; Snapshot before cleanup wipes _capture.
    field := Settings._capture.field
    ownKey := Settings._capture.key
    prev := Settings._capture.prev
    attempted := value

    HotIfWinActive("ahk_id " Settings._gui.Hwnd)
    for _, btn in Settings._CAPTURE_MOUSE_BUTTONS {
      try Hotkey("*" btn, , "Off")
    }
    HotIf()
    try Settings._capture.hook.Stop()

    Settings._capture.active := false
    Settings._capture.field := ""
    Settings._capture.prev := ""
    Settings._capture.key := ""
    Settings._capture.hook := ""

    conflict := ""
    if (value != "" and value != prev) {
      conflict := Settings._FindHotkeyConflict(value, ownKey)
      if (conflict != "") {
        value := prev
      }
    }

    field.Text := Settings._DisplayValueFor(value)
    field.HiddenMirror.Value := value

    if (conflict != "") {
      MsgBox(Format(
        "'{}' is already bound to '{}'. Pick a different key.",
        attempted, conflict
      ), "Quality of Exile", MSGBOX_TOPMOST)
    }
  }

  static _FindHotkeyConflict(value, ownKey) {
    for key, config in Configs {
      if (!config.HasProp("section") or config.section != "Hotkey") {
        continue
      }
      if (key == ownKey) {
        continue
      }
      try {
        if (Settings._gui[key].Value == value) {
          return config.name
        }
      }
    }
    return ""
  }

  ; ============================ Pixel picker ============================

  static _SelectPixel(control, pixelTextControl, config, *) {
    try {
      Settings._pickX := 0
      Settings._pickY := 0
      name := config.name

      Settings._gui.Hide()
      WinActivate(Game.HWND)

      varName := SubStr(control.Name, 1, -StrLen("PixelSelect"))
      if (config.HasProp("vars") and config.vars.Length > 0) {
        if (Settings._PixelLabels.Has(varName)) {
          name := Settings._PixelLabels[varName]
        }
      }

      isOverlayPick := varName == "ToggleOverlayPosition"
      if (isOverlayPick) {
        Overlay.BeginPreview()
      }

      Settings._pickName := name
      Settings._pickOverlay := isOverlayPick
      tick := (*) => Settings._WatchCursor()

      ToolTip()  ; clear any hover tooltip left over from the Settings GUI
      SetTimer(tick, 15)
      Hotkey("Esc", Settings._DoNothing, "On")
      Hotkey("LButton", Settings._DoNothing, "On")

      cancelled := false
      loop {
        if GetKeyState("Esc", "P") {
          cancelled := true
          break
        }
        if GetKeyState("LButton", "P") {
          pixelTextControl.Value := Settings._pickX "x" Settings._pickY
          break
        }
        Sleep(10)
      }
      Sleep(250)
      SetTimer(tick, 0)
      ToolTip()

      if (isOverlayPick) {
        Overlay.EndPreview(cancelled)
      }
    } finally {
      Settings._gui.Show()
      Hotkey("Esc", Settings._DoNothing, "Off")
      Hotkey("LButton", Settings._DoNothing, "Off")
    }
  }

  static _DoNothing(*) {
    return
  }

  static _pickX := 0
  static _pickY := 0
  static _pickName := ""
  static _pickOverlay := false

  static _WatchCursor() {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&x, &y)
    Settings._pickX := x
    Settings._pickY := y

    if (Settings._pickOverlay) {
      Overlay.MovePreview(x, y)
      return
    }

    ToolTip(
      "`nSelect pixel for: " Settings._pickName "`nCurrent Mouse Position: X = " x ", Y = " y "`nClick to confirm.`nEsc to cancel."
    )
  }

  ; ============================ Hover tooltips + keybind hover style ============================
  ; AHK GUI controls don't have built-in hover tooltips or hover styling, so we
  ; fake both with a WM_MOUSEMOVE handler scoped to Settings._gui.

  static _HandleHover(wParam, lParam, msg, hwnd) {
    if (hwnd == Settings._ttHoveredHwnd) {
      return
    }
    Settings._ttHoveredHwnd := hwnd
    ToolTip()

    if (Settings._ttHoveredKeybind != "") {
      Settings._ApplyKeybindHover(Settings._ttHoveredKeybind, false)
      Settings._ttHoveredKeybind := ""
    }

    ctrl := GuiCtrlFromHwnd(hwnd)
    if (!ctrl or !Settings._gui or ctrl.Gui !== Settings._gui) {
      return
    }

    if (ctrl.HasOwnProp("IsKeybindField") and ctrl.IsKeybindField) {
      Settings._ApplyKeybindHover(ctrl, true)
      Settings._ttHoveredKeybind := ctrl
    }

    ; WinGetPos gives absolute screen coords (ctrl.GetPos is tab-relative inside Tab3).
    if (ctrl.HasOwnProp("Tooltip") and ctrl.Tooltip != "") {
      CoordMode("ToolTip", "Screen")
      WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " ctrl.Hwnd)
      ToolTip(Settings._WrapTooltip(ctrl.Tooltip), wx + ww + Settings._TOOLTIP_GAP, wy)
    }
  }

  ; SetFont is the reliable cue; BG flip + InvalidateRect rarely repaint Text
  ; controls after creation, so they're best-effort bonus.
  static _ApplyKeybindHover(ctrl, hovered) {
    bg := hovered ? Settings._KEYBIND_BG_HOVER : Settings._KEYBIND_BG_DEFAULT
    font := hovered ? "bold c" Settings._KEYBIND_FG_HOVER : "norm c" Settings._KEYBIND_FG_DEFAULT
    try ctrl.Opt("+Background" bg)
    ctrl.SetFont(font)
    try DllCall("InvalidateRect", "Ptr", ctrl.Hwnd, "Ptr", 0, "Int", 1)
  }

  ; AHK's ToolTip has no max-width — wrap manually.
  static _WrapTooltip(text) {
    text := Trim(RegExReplace(text, "\s+", " "))
    lines := []
    current := ""
    for _, word in StrSplit(text, " ") {
      candidate := current == "" ? word : current " " word
      if (StrLen(candidate) > Settings._TOOLTIP_WRAP_WIDTH and current != "") {
        lines.Push(current)
        current := word
      } else {
        current := candidate
      }
    }
    if (current != "") {
      lines.Push(current)
    }
    out := ""
    for i, line in lines {
      out .= (i > 1 ? "`n" : "") line
    }
    return out
  }
}
