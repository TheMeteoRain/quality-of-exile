#Requires AutoHotkey v2.0
#Include "variables.ahk"
#Include "functions\LastEpoch.ahk"
#Include "functions\CalculateWeaponDPS.ahk"

LoadState() {
  global DynamicHotkeysActivated, DynamicHotkeysState

  if (FileExist(STATE_FILE)) {
    DynamicHotkeysActivated := IniRead(STATE_FILE, "STATE", "DynamicHotkeysActivated", 0)
    DynamicHotkeysState := IniRead(STATE_FILE, "STATE", "DynamicHotkeysState", "Off")
    FileDelete(STATE_FILE)
  }
}

SaveState() {
  global DynamicHotkeysActivated, DynamicHotkeysState

  IniWrite(DynamicHotkeysActivated, STATE_FILE, "STATE", "DynamicHotkeysActivated")
  IniWrite(DynamicHotkeysState, STATE_FILE, "STATE", "DynamicHotkeysState")
}

TerminateTCP(*) {
  global LastExecutionTime
  Critical

  if (Debounce("TerminateTCP", 2000)) {
    return
  }

  if (DEBUG) {
    MsgBox("TCP connections terminated.")
    return
  }

  tempFile := Q_CportsPathDir "\temp.txt"

  try {
    loop 5 {
      cportsCommand := Format("{} /close * * * * {}", Q_CportsPath, Game.PID)
      Run(A_ComSpec . " /c " . cportsCommand, "", "Hide")
    }

    cportsCommand := Format("{} /filter include:process:{} /stext {}", Q_CportsPath, Game.PID, tempFile)
    Run(A_ComSpec . " /c " . cportsCommand, "", "Hide")

    found := false
    loop 200 {
      if (FileExist(tempFile)) {
        found := true
        break
      }
      Sleep(10)
    }

    if (found) {
      if (FileGetSize(tempFile) > 0) {
        ; if log file has content, then the tcp connection is still alive, close the game
        ProcessClose(Game.PID)
        MsgBox(
          "Could not terminate TCP connections with cports. Closing game to be safe. This should not happen. Send an issue in: " Q_GithubLink
        )
      }
    } else {
      ; if log file is not found then the cports commands did not work, close the game
      ProcessClose(Game.PID)
      MsgBox(
        "Could not terminate TCP connections with cports. Closing game to be safe. This should not happen. Send an issue in: " Q_GithubLink
      )
    }
  } catch Error as e {
    ; close the game if something goes wrong
    ProcessClose(Game.PID)
    LogError(
      "Something went wrong when trying to close TCP connections. Closing game to be safe. This should not happen. Send an issue in: " Q_GithubLink,
      e
    )
  } finally {
    loop 20 {
      if (FileExist(tempFile)) {
        FileDelete(tempFile)
      }
      Sleep(100)
    }
  }
}

Settings(*) {
  global Hotkeys, Extra, Options, HotkeyGui, Configs
  ; padding x
  pX := 20
  ; padding y
  pY := 40
  w := 150
  colSize := 175
  rowSize := 30
  gap := 10
  maxY := 0

  if (IsSet(HotkeyGui)) {
    HotkeyGui.Destroy()
  }

  HotkeyGui := Gui("+AlwaysOnTop +ToolWindow", "Quality of Exile")
  TabControl := HotkeyGui.Add("Tab3", "", [
    "General",
    "PoE (A)",
    "PoE (B)",
    "Last Epoch"
  ])

  TabControl.UseTab("General")
  textCtrl := HotkeyGui.Add(
    "Text", Format("x{} y{} w500", pX, pY),
    "(K): Keyboard keybind | (M): Mouse keybind | (Px): Pixel | (D): Dynamic Hotkey"
  )
  textCtrl.SetFont("w700")

  TabControl.UseTab("PoE (A)")
  textCtrl := HotkeyGui.Add(
    "Text", Format("x{} y{} w500", pX, pY),
    "(K): Keyboard keybind | (M): Mouse keybind | (Px): Pixel | (D): Dynamic Hotkey"
  )
  textCtrl.SetFont("w700")

  TabControl.UseTab("PoE (B)")
  textCtrl := HotkeyGui.Add("Text", Format("x{} y{} w500", pX, pY),
  "(K): Keyboard keybind | (M): Mouse keybind | (Px): Pixel | (D): Dynamic Hotkey")
  textCtrl.SetFont("w700")

  TabControl.UseTab("Last Epoch")
  textCtrl := HotkeyGui.Add(
    "Text",
    Format("x{} y{} w500", pX, pY),
    "(K): Keyboard keybind | (M): Mouse keybind | (Px): Pixel | (D): Dynamic Hotkey"
  )
  textCtrl.SetFont("w700")

  pixelSearchCtrls(conf, key, options, x1, y1, x2, y2) {
    HotkeyGui.Add("Text", Format("x{} y{} w{}", x1, y1 + 4, w), "Px")
    pixelTextCtrl := HotkeyGui.Add(
      "Edit",
      Format("v{}Pixel x{} y{} w{} +Center {}", key, x1 + 20, y1, w - 10, options),
      Extra.Get(key, ""))
    if (key == "ToggleOverlayPosition" and !pixelTextCtrl.Value) {
      pixelTextCtrl.Value := Format("{}x{}", Game.OverlayPosX, Game.OverlayPosY)
    }
    pixelTextCtrl.OnEvent("Change", ValidatePixel.Bind(pixelTextCtrl.Value))
    pixelButtonCtrl := HotkeyGui.Add(
      "Button",
      Format("v{}PixelSelect x{} y{} w{}", key, x2 + 20, y2, w - 10),
      "Select Pixel"
    )
    pixelButtonCtrl.OnEvent("Click", SelectPixel.Bind(pixelButtonCtrl, pixelTextCtrl, conf))

    return {
      text: pixelTextCtrl,
      button: pixelButtonCtrl
    }
  }

  for key, config in Configs.OwnProps() {
    TabControl.UseTab(config.tab)
    x := config.coords.x + pX
    y := config.coords.y + pY + rowSize

    textGuiControl := HotkeyGui.Add("Text", Format("x{} y{} w{}", x, y, w), config.name)
    textGuiControl.SetFont("bold")
    textGuiControl.GetPos(&cX, &cY, &cW, &cH)
    y := y + cH - gap
    if (config.section == "Hotkey") {
      keyboardLabel := HotkeyGui.Add("Text", Format("x{} y{} Center", x, y + rowSize + 3 - gap), "K")
      mainGuiControl := HotkeyGui.Add("Hotkey", Format("v{} x{} y{} w{}", key, x + 10, y + rowSize - gap, w),
      Hotkeys.Get(key, ""))
      hotkeyValue := Hotkeys.Get(key, "")
      mainGuiControl.Value := hotkeyValue
      y := y + rowSize * 2
      ; if (key == "KillSwitch" or key == "Settings") {
      ;     mainGuiControl.
      ; }

      if (config.HasProp("mouseBind") and config.mouseBind) {
        mouseLabel := HotkeyGui.Add("Text", Format("x{} y{} Center", x, y + 3 - gap), "M")
        guiDropdown := HotkeyGui.Add(
          "DropDownList",
          Format("v{} x{} y{} w{}", key "_mouseDropdownOptions", x + 10, y - gap, w),
          MouseDropdownOptions
        )
        guiDropdown.OnEvent("Change", onChangeDropdownToHotkey.Bind(mainGuiControl))
        mainGuiControl.OnEvent("Change", onChangeHotkeyToDropdown.Bind(guiDropdown))

        hotkeyValue := Hotkeys.Get(key, "")
        if (hotkeyValue != "" and index := hasKey(MouseDropdownOptions, hotkeyValue)) {
          guiDropdown.Value := index
        } else {
          mainGuiControl.Value := hotkeyValue
        }
        y := y + rowSize
      }

      if (config.HasProp("pixelSelect") and config.pixelSelect) {
        newY := y
        if (config.HasProp("vars") and config.vars.Length > 0) {
          for index, var in config.vars {
            newY := index > 1 ? newY + rowSize * 2 : newY
            pixelSearchCtrls(config, var, "Readonly", x, newY - gap, x, newY + rowSize - gap)
          }
        } else {
          pixelSearchCtrls(config, key, "Readonly", x, y - gap, x, y + rowSize - gap)
        }
        y := newY + rowSize
      }

      if (key == "HighlightShopItems") {
        regexp := Extra.Get(key, "")
        characterLimitText := HotkeyGui.Add(
          "Text",
          Format("x{} y{}", x + 10, y + rowSize * 2 - gap),
          Format(
            "{} / {}`ndon't include quotation marks",
            StrLen(regexp),
            RegExpCharacterLimit
          )
        )
        extraGuiControl := HotkeyGui.Add(
          "Edit",
          Format("v{}_extra x{} y{} w{} Limit{} -VScroll h60",
            key, x + 10, y - gap, w, RegExpCharacterLimit
          ),
          regexp
        )
        extraGuiControl.OnEvent("Change", UpdateCharacterLimit.Bind(characterLimitText))
      }

      if (key == "FillShipment") {
        control := HotkeyGui.Add(
          "Button",
          Format("v{}_extra x{} y{} w{}", key, x + 10, y - gap, w),
          "Shipment values"
        )
        control.OnEvent("Click", openSettlersShipmentUI)
      }
    }

    if (config.section == "Options" or config.section == "Toggle") {
      if (key == "ToggleOverlayPosition") {
        pixelSearchCtrls(config, key, "", x, y + rowSize - gap, x, y + rowSize * 2 - gap)
      } else {
        HotkeyGui.Add("Text", Format("x{} y{} w{}", x, y + rowSize + 4 - gap, w), "Enabled")
        control := HotkeyGui.Add("Checkbox", Format("v{} x{} y{}", key, x + 45, y + 4 + rowSize - gap))
        control.Value := Hotkeys.Get(key, 0)
        control.Tooltip := config.tooltip
      }
    }

    maxY := Max(y, maxY)
  }

  TabControl.UseTab("")

  HotkeyGui.Add("Text", Format("x{} y{} w{} Center", 0, maxY, 200), "QualityOfExile version:`n" VERSION)
  HotkeyGui.Add(
    "Link",
    Format("x{} y{} w{}", pX * 2, maxY + 35, w),
    Format(
      '<a href="{}">Github / Documentation</a>',
      Q_GithubLink
    )
  )

  HotkeyGui
    .Add("Button", Format("x{} y{} w{} Default", 550 / 2 - 200 / 2, maxY, 200), "Save And Reload")
    .OnEvent("Click", SaveConfigurations)
  HotkeyGui
    .Add("Button", Format("x{} y{} w{}", 550 / 2 - 200 / 2, maxY + rowSize, 200), "Close")
    .OnEvent("Click", CloseConfigurations)

  maxY := Max(maxY + rowSize * 2, maxY)
  ;OnMessage(0x0200, On_WM_MOUSEMOVE)

  HotkeyGui.Show(
    Format(
      "x{} y{} w{} h{}",
      Game.GameWindowCenterX - 550 / 2, Game.GameWindowCenterY - 475 / 2, 550,
      475
    )
  )
  ControlFocus(HotkeyGui, HotkeyGui.Title)
}

ShowSettings(*) {
  HotkeyGui.Show(
    Format(
      "x{} y{} w{} h{}",
      Game.GameWindowCenterX - 550 / 2, Game.GameWindowCenterY - 550 / 2, 550, 550
    )
  )
  ControlFocus(HotkeyGui, HotkeyGui.Title)
}

HideSettings() {
  HotkeyGui.Hide()
}

ValidatePixel(oldValue, GuiCtrlObj, *) {
  resolution := ParseResolution(GuiCtrlObj.Value)
  if (!resolution) {
    GuiCtrlObj.Value := oldValue
  }
}

KillSwitch(*) {
  ExitApp()
}

UpdateCharacterLimit(LimitControl, RegExpControl, *) {
  ControlSetText(
    Format(
      "{} / {}`ndon't include quotation marks",
      StrLen(RegExpControl.Value),
      RegExpCharacterLimit
    ),
    LimitControl
  )
}

CloseConfigurations(*) {
  global Game
  HotkeyGui.Hide()
  Game.FocusGameWindow()
}

SaveConfigurations(*) {
  global Hotkeys, Options, Extra, Configs
  controls := HotkeyGui.Submit()

  for key in controls.OwnProps() {
    found := Configs.HasProp(key)

    ; duplication - fix me
    if (key == "ToggleOverlayPositionPixel") {
      var := "ToggleOverlayPosition"
      val := controls.%var "Pixel"%
      IniWrite(val, INI_FILE, "Pixels", var)
      Extra.Set(var, val)
      continue
    }

    if (!found) {
      if (InStr(key, "_extra")) {
        IniWrite(controls.%key%, INI_FILE, "Extra", SubStr(key, 1, StrLen(key) - 6))
      }
      continue
    }

    config := Configs.%key%

    if (config.HasProp("pixelSelect") and config.pixelSelect) {
      parsedValues := []

      if (config.HasProp("vars") and config.vars.Length > 0) {
        for index, var in config.vars {
          parsedValues.Push([
            var,
            controls.%var "Pixel"%
          ])
        }
      } else {
        parsedValues.Push([
          key,
          controls.%key "Pixel"%
        ])
      }

      for index, arr in parsedValues {
        var := arr[1]
        val := arr[2]

        IniWrite(val, INI_FILE, "Pixels", var)
        Extra.Set(var, val)
      }
    }

    if (config.HasProp("section") and config.section == "Hotkey") {
      val := controls.%key%

      if (config.mouseBind and val == "") {
        val := controls.%key "_mouseDropdownOptions"%
      }

      IniWrite(val, INI_FILE, "Hotkeys", key)
    }
    if (config.HasProp("section") and config.section == "Toggle") {
      IniWrite(controls.%key%, INI_FILE, "Toggle", key)
    }
    if (config.HasProp("section") and config.section == "Options") {
      IniWrite(controls.%key%, INI_FILE, "Options", key)
    }
  }

  SaveState()
  Reload()
  Game.FocusGameWindow()
}

LoadConfigurations() {
  global Hotkeys, Options, Game, Configs

  try {
    for key, config in Configs.OwnProps() {
      if (config.HasProp("game") and config.game != Game.Name) {
        continue
      }

      if (config.HasProp("pixelSelect") and config.pixelSelect) {
        if (config.HasProp("vars") and config.vars.Length > 0) {
          for index, var in config.vars {
            extraValue := IniRead(INI_FILE, "Pixels", var, "")
            Extra.Set(var, extraValue)
          }
        } else {
          extraValue := IniRead(INI_FILE, "Pixels", key, "")
          Extra.Set(key, extraValue)
        }
      }

      if (config.section == "Hotkey") {
        val := IniRead(INI_FILE, "Hotkeys", key, config.defaultHotkey)
        Hotkeys.Set(key, val)

        if (key == "HighlightShopItems") {
          extraValue := IniRead(INI_FILE, "Extra", key, "(\w\W){5}|-\w-.-|(-\w){4}|(-\w){5}|nne|rint|ll g")
          Extra.Set(key, extraValue)
        }

        if (val && key == "KillSwitch") {
          RegisterHotkey("*" val, config.func, "On", config.canBeDisabled, "")
        } else {
          if (config.HasProp("toggleOnInstance") and config.toggleOnInstance) {
            ; dynamic hotkeys
            RegisterHotkey("*" val, config.func, "On", config.canBeDisabled)
          } else if (config.blockKeyNativeFunction) {
            RegisterHotkey("*" val, config.func, "On", config.canBeDisabled)
          } else {
            RegisterHotkey("~" val, config.func, "On", config.canBeDisabled)
          }
        }

        continue
      }

      if (config.section == "Options") {
        val := IniRead(INI_FILE, "Options", key, 0)
        Hotkeys.Set(key, val)

        continue
      }

      if (config.section == "Toggle") {
        val := IniRead(INI_FILE, "Toggle", key, 0)
        Hotkeys.Set(key, val)

        if (val == 1) {
          if (key == "ToggleCtrl") {
            RegisterHotkey("*Ctrl", config.func, "On", config.canBeDisabled)
          }
          if (key == "ToggleShift") {
            RegisterHotkey("*Shift", config.func, "On", config.canBeDisabled)
          }
        }

        continue
      }
    }

    if (Hotkeys["ToggleCtrl"] == 1 and Hotkeys["ToggleShift"] == 0) {
      RegisterHotkey("*Shift", ResetToggle, "On", config.canBeDisabled)
    }
    if (Hotkeys["ToggleCtrl"] == 0 and Hotkeys["ToggleShift"] == 1) {
      RegisterHotkey("*Ctrl", ResetToggle, "On", config.canBeDisabled)
    }

    if (Hotkeys["ToggleCtrl"] == 1 or Hotkeys["ToggleShift"] == 1) {
      RegisterHotkey("#LWin", ResetToggle, "On", config.canBeDisabled)
      RegisterHotkey("~*LWin", ResetToggleWin, "On", config.canBeDisabled)
      RegisterHotkey("*Esc", ResetToggleEsc, "On", config.canBeDisabled)
      ; HotIfWinActive(Game.Title)
      ; Hotkey("*Space", ResetToggleSpace)
    }
  } catch Error as e {
    LogError(
      Format(
        'Error when loading configurations. If this persists consider deleting file: "{}".`nYou will lose your settings by doing this and have to start over.',
        INI_FILE
      ),
      e,
      true
    )
    KillSwitch()
  }
}

EnableHotkeys() {
  global RegisteredHotkeys, DynamicHotkeysActivated, DynamicHotkeysState, ManualHotkeyEnabled, DisabledLabel

  if (!IsSet(OverlayGui)) {
    return
  }

  for key, obj in RegisteredHotkeys {
    RegisterHotkey(key, obj.Get("func"), "On")
  }
  LoadState()
  SetDynamicHotkeysState(DynamicHotkeysState, true)
  ManualHotkeyEnabled := false
  DisabledLabel.Text := " "
}
DisableHotkeys() {
  global RegisteredHotkeys, ManualHotkeyEnabled, DisabledLabel

  if (!IsSet(OverlayGui)) {
    return
  }

  ResetToggle()
  DisabledLabel.Text := "⚠️"
  ManualHotkeyEnabled := true
  SaveState()
  for key, obj in RegisteredHotkeys {
    if (!obj.Has("canBeDisabled")) {
      continue
    }
    if (!obj.Get("canBeDisabled")) {
      continue
    }

    RegisterHotkey(key, obj.Get("func"), "Off")
  }
}

ToggleHotkeys(*) {
  global ManualHotkeyEnabled

  if (Debounce("ToggleHotkeys", 500)) {
    return
  }

  LogInfo("ToggleHotkeys")

  if (!ManualHotkeyEnabled) {
    LogInfo("DisableHotkeys")
    DisableHotkeys()
  } else {
    LogInfo("EnableHotkeys")
    EnableHotkeys()
  }

}

RegisterHotkey(KeyName, Func, Action := "On", canBeDisabled := true, WinName := Game.Title) {
  global RegisteredHotkeys

  if (!RegisteredHotkeys.Has(KeyName)) {
    RegisteredHotkeys.Set(
      KeyName,
      Map()
      .Set("func", Func)
      .Set("action", Action)
      .Set("canBeDisabled", canBeDisabled)
    )
  }

  if (WinName == "") {
    HotIf()
  } else {
    HotIfWinActive(Game.Title)
  }
  Hotkey(KeyName, Func, Action)
}

SelectPixel(control, pixelTextControl, config, *) {
  try {
    SelectedX := 0
    SelectedY := 0
    name := config.name

    HotkeyGui.Hide()
    WinActivate(Game.HWND)

    if (config.HasProp("vars") and config.vars.Length > 0) {
      if (control.Name == "TradeDivinationCardButtonPixelSelect") {
        name := "Trade Divination Card Button"
      } else if (control.Name == "TradeDivinationCardItemAreaPixelSelect") {
        name := "Trade Divination Card Item Area"
      } else if (control.Name == "TransferMaterialsButtonPixelSelect") {
        name := "Transfer Materials Button"
      } else if (control.Name == "TransferMaterialsSortPixelSelect") {
        name := "Sort Button"
      } else if (control.Name == "ShatterItemButtonPixelSelect") {
        name := "Shatter Item Button"
      } else if (control.Name == "ShatterItemRuneSelectionPixelSelect") {
        name := "Shatter Item Rune Selection"
      } else if (control.Name == "ShatterItemShatterRunePixelSelect") {
        name := "Shatter Item Shatter Rune"
      }
    }

    WatchCursorBind := WatchCursor.Bind(&SelectedX, &SelectedY, name)

    SetTimer(WatchCursorBind, 15)
    Hotkey("Esc", DoNothing, "On")
    Hotkey("LButton", DoNothing, "On")

    loop {
      if GetKeyState("Esc", "P") {
        ; do nothing :)
        break
      }
      if GetKeyState("LButton", "P") {
        pixelTextControl.Value := SelectedX "x" SelectedY
        break
      }
      Sleep(10)
    }
    Sleep(250)
    SetTimer(WatchCursorBind, 0)  ; Turn off the timer after the click
    ToolTip()  ; Remove the tooltip
  } finally {
    HotkeyGui.Show()
    Hotkey("Esc", DoNothing, "Off")
    Hotkey("LButton", DoNothing, "Off")
  }
}

DoNothing(*) {
  return
}

WatchCursor(&SelectedX, &SelectedY, name, *) {
  ; Get the current mouse position

  CoordMode("Mouse", "Screen")
  MouseGetPos(&SelectedX, &SelectedY)

  ; Update the tooltip with the current coordinates
  ToolTip(
    "`nSelect pixel for: " name "`nCurrent Mouse Position: X = " SelectedX ", Y = " SelectedY "`nClick to confirm.`nEsc to cancel."
  )
}

onChangeDropdownToHotkey(hotkey, Control, *) {
  if (hotkey.Value != "") {
    hotkey.Value := MouseDropdownOptions[Control.Value]
  }
}

onChangeHotkeyToDropdown(dropdown, Control, *) {
  if (Control.Value != "") {
    dropdown.Value := ""
  }
}

On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
  static PrevHwnd := 0
  if (Hwnd != PrevHwnd) {
    Text := "", ToolTip() ; Turn off any previous tooltip.
    CurrControl := GuiCtrlFromHwnd(Hwnd)
    if CurrControl {
      if !CurrControl.HasProp("ToolTip")
        return ; No tooltip for this control.
      Text := CurrControl.ToolTip
      SetTimer () => ToolTip(Text), -1000
      SetTimer () => ToolTip(), -4000 ; Remove the tooltip.
    }
    PrevHwnd := Hwnd
  }
}

hasKey(arr, find) {
  for i, item in arr {
    if (item == find) {
      return i
    }
  }
}

CreateHUD() {
  global Hotkeys, Configs, HUDGui

  configHotkey := Hotkeys.Has("Settings") ? Hotkeys["Settings"] : "Not Set"
  killSwitchHotkey := Hotkeys.Has("KillSwitch") ? Hotkeys["KillSwitch"] : "Not Set"

  HUDGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
  HUDGui.BackColor := "20283f"
  WinSetTransColor("Black 150", HUDGui)  ; Make the background transparent

  ctrl := HUDGui.Add("Text", "x5 y5 h30 w100 cWhite", "Settings: " configHotkey)
  ctrl.SetFont("s6 q2")
  ctrl := HUDGui.Add("Text", "x5 y23 h30 w100 cWhite", "Kill Switch: " killSwitchHotkey)
  ctrl.SetFont("s6 q2")
}

HideHUD() {
  global HUDGui

  if (IsSet(HUDGui)) {
    HUDGui.Hide()
  }
}
ShowHUD() {
  global HUDGui

  if (IsSet(HUDGui)) {
    HUDGui.Show("x" Game.HudPosX " y" Game.HudPosY " w120 h40 NoActivate")
  }
}

CreateToggleOverlay() {
  global OverlayGui, CtrlLabel, ShiftLabel, SpamLabel, DisabledLabel

  if (IsSet(OverlayGui)) {
    return
  }

  if (CheckForAnyToggleableKeybinds()) {
    OverlayGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x20")
    OverlayGui.Title := "Toggle Overlay"
    OverlayGui.BackColor := "Black"
    WinSetTransColor(OverlayGui.BackColor " 150", OverlayGui)
    CtrlLabel := OverlayGui.Add("Text", "x10 y10 w" Game.OverlayWidth / 2 " h30 vCtrlLabel", "CTRL:❌")
    CtrlLabel.SetFont("cWhite s15 q5")
    ShiftLabel := OverlayGui.Add("Text", "x10 y40 w" Game.OverlayWidth / 2 " h30 vShiftLabel", "SHIFT:❌")
    ShiftLabel.SetFont("cWhite s15 q5")
    SpamLabel := OverlayGui.Add("Text", "x" Game.OverlayWidth / 2 " y6 w" Game.OverlayWidth / 2 " h30 vSpam")
    SpamLabel.SetFont("c4cff70 s20 q5")
    DisabledLabel := OverlayGui.Add("Text", "x" Game.OverlayWidth / 2 " y33 w" Game.OverlayWidth / 2 " h30 vDisabled")
    DisabledLabel.SetFont("cYellow s20 q5")
  }
}
ShowToggleOverlay() {
  global OverlayGui, Extra

  if (!IsSet(OverlayGui)) {
    return
  }

  val := Extra.Get("ToggleOverlayPosition", Format("{}x{}", Game.OverlayPosX, Game.OverlayPosY))
  resolution := ParseResolution(val)
  if (!resolution) {
    MsgBox(
      "Invalid resolution for toggle overlay position. Please set a valid resolution in the format 'widthxheight' (e.g., 1920x1080)."
    )
    return
  }

  OverlayGui
    .Show("x" resolution.width " y" resolution.height " w" Game.OverlayWidth " h" Game.OverlayHeight " NoActivate")

}
HideToggleOverlay() {
  global OverlayGui

  if (!IsSet(OverlayGui)) {
    return
  }

  OverlayGui.Hide()
}

CheckForAnyToggleableKeybinds() {
  global Hotkeys

  return (
    Hotkeys["ToggleCtrl"] or Hotkeys["ToggleShift"] or
    Hotkeys["CtrlClickSpamToggle"] or Hotkeys["ToggleCtrlKeybind"] or
    Hotkeys["ToggleShiftKeybind"] or Hotkeys["ToggleHotkeys"]
  )
}

ResetToggle(*) {

  if (CheckForAnyToggleableKeybinds()) {
    StopClickSpam()
    CtrlUp()
    ShiftUp()
  }
}

ResetToggleForInput(keys := "", *) {
  ResetToggle()
  Send(keys)
}

ResetToggleAltTab(*) {
  ResetToggle()
  Send ("{Alt down}{tab}")
}

ResetToggleSpace(*) {
  ResetToggle()
  Send ("{Space}")
}

ResetToggleEsc(*) {
  ResetToggle()
  Send ("{Esc}")
}

ResetToggleWin(*) {
  ResetToggle()
  SendInput("{LWin}")
}

ToggleCtrl(*) {
  global CtrlToggled

  ShiftUp()
  spamState := StopClickSpam()
  if (spamState) {
    return
  }

  if (!CtrlToggled) {
    CtrlDown()
  } else {
    CtrlUp()
  }
}

ToggleShift(*) {
  global ShiftToggled

  StopClickSpam()
  CtrlUp()
  if (!ShiftToggled) {
    ShiftDown()
  } else {
    ShiftUp()
  }
}

CtrlDown() {
  global CtrlToggled
  SendInput("{Ctrl down}")
  CtrlLabel.Text := "CTRL:✅"
  CtrlLabel.SetFont("c4cff70")
  CtrlToggled := true
}

CtrlUp() {
  global CtrlToggled
  SendInput("{Ctrl up}")
  CtrlLabel.Text := "CTRL:❌"
  CtrlLabel.SetFont("cWhite")
  CtrlToggled := false
}

ShiftDown() {
  global ShiftToggled
  SendInput("{Shift down}")
  ShiftLabel.Text := "SHIFT:✅"
  ShiftLabel.SetFont("c4cff70")
  ShiftToggled := true
}

ShiftUp() {
  global ShiftToggled
  SendInput("{Shift up}")
  ShiftLabel.Text := "SHIFT:❌"
  ShiftLabel.SetFont("cWhite")
  ShiftToggled := false
}

StartCtrlClickSpam() {
  global ScrollSpam, SpamLabel

  ScrollSpam := true
  SpamLabel.Text := "🖱️❗"

  ShiftUp()
  CtrlDown()
  SetTimer(ClickSpam, Random(75, 100))
}

ClickSpam() {
  SendInput("{LButton}")
}

StopClickSpam() {
  global ScrollSpam, SpamLabel, CtrlToggled

  savedState := ScrollSpam
  ScrollSpam := false
  SpamLabel.Text := ""
  SetTimer(ClickSpam, 0)
  return savedState
}

StopCtrlClickSpam() {
  CtrlUp()
  StopClickSpam()
}

CtrlClickSpamToggle(*) {
  global ScrollSpam
  ScrollSpam := !ScrollSpam

  if (ScrollSpam) {
    StartCtrlClickSpam()
  } else {
    StopCtrlClickSpam()
  }
}

PerformDivinationTrading(*) {
  global CtrlToggled, mousePos

  rand1 := Random(125, 175)
  rand2 := Random(125, 175)
  if (Debounce("PerformDivinationTrading", rand1 + rand2)) {
    return
  }

  buttonPixelKey := "TradeDivinationCardButton"
  areaPixelKey := "TradeDivinationCardItemArea"

  if (!Extra.Has(buttonPixelKey) or !Extra.Get(buttonPixelKey)) {
    MsgBox("Set pixel for divination trade button. Use the Pixel Search button in settings (" Hotkeys["Settings"] ")."
    )
    return
  }

  if (!Extra.Has(areaPixelKey) or !Extra.Get(areaPixelKey)) {
    MsgBox("Set pixel for divination item area. Use the Pixel Search button in settings (" Hotkeys["Settings"] ")."
    )
    return
  }

  buttonResolution := ParseResolution(Extra[buttonPixelKey])
  areaResolution := ParseResolution(Extra[areaPixelKey])
  if (!buttonResolution) {
    MsgBox(
      "Invalid resolution for divination trade button. Please set a valid resolution in the format 'widthxheight' (e.g., 1920x1080)."
    )
    return
  }
  if (!areaResolution) {
    MsgBox(
      "Invalid resolution for divination item area. Please set a valid resolution in the format 'widthxheight' (e.g., 1920x1080)."
    )
    return
  }

  try {
    BlockInput("MouseMove")
    mousePos.SavePosition()
    ResetToggle()

    Send("^{Click}")
    DllCall("SetCursorPos", "int", buttonResolution.width, "int", buttonResolution.height)
    ; MouseMove(buttonResolution.width, buttonResolution.height, 0)
    Sleep(rand1)
    Click("left")
    DllCall("SetCursorPos", "int", areaResolution.width, "int", areaResolution.height)
    ; MouseMove(areaResolution.width, areaResolution.height, 0)
    Sleep(rand2)
    Send("^{Click}")

    mousePos.RestorePosition()
  } finally {
    BlockInput("MouseMoveOff")
  }

}

OpenStackedDivinationDeck(*) {
  global mousePos

  if (Debounce("OpenStackedDivinationDeck", 185)) {
    return
  }

  try {
    ResetToggle()
    BlockInput("MouseMove")
    mousePos.SavePosition()

    Click("right")
    Sleep(10)
    CustomMouseMove(Game.ScreenMiddleWithInventoryX, Game.ScreenMiddleWithInventoryY)
    Sleep(100)
    Click("left")
    Sleep(75)
    mousePos.RestorePosition()
  } finally {
    BlockInput("MouseMoveOff")
  }
}

DropItem(*) {
  global mousePos, clipboard

  if (Debounce("DropItem", 185)) {
    return
  }

  try {
    ResetToggle()
    BlockInput("MouseMove")
    mousePos.SavePosition()

    Click("left")
    Sleep(10)
    CustomMouseMove(Game.ScreenMiddleWithInventoryX, Game.ScreenMiddleWithInventoryY)
    Sleep(100)
    Click("left")
    Sleep(75)
    mousePos.RestorePosition()
  } finally {
    BlockInput("MouseMoveOff")
  }
}

OpenHideout(*) {
  ResetToggle()
  SendInput("{Enter}/hideout{Enter}")
}

OpenKingsmarch(*) {
  ResetToggle()
  SendInput("{Enter}/kingsmarch{Enter}")
}

CraftAlchemyOrb(*) {
  CraftWithCurrency("Alchemy Orb", "AlchemyOrb")
}
CraftOrbOfChance(*) {
  CraftWithCurrency("Orb of Chance", "OrbOfChance")
}
CraftOrbOfScouring(*) {
  CraftWithCurrency("Orb of Scouring", "OrbOfScouring")
}
ChaosOrb(*) {
  CraftWithCurrency("Chaos Orb", "ChaosOrb")
}
OrbOfTransmutation(*) {
  CraftWithCurrency("Orb of Transmutation", "OrbOfTransmutation")
}
OrbOfAlteration(*) {
  CraftWithCurrency("Orb of Alteration", "OrbOfAlteration")
}

CraftWithCurrency(name, key) {
  global mousePos

  if (!Extra.Has(key) or !Extra.Get(key)) {
    MsgBox("Set pixel for " name ". Use the Pixel Search button in settings (" Hotkeys["Settings"] ").")
    return
  }

  resolution := ParseResolution(Extra[key])
  if (!resolution) {
    MsgBox("Invalid resolution for " name ". Please set a valid resolution in the format 'widthxheight' (e.g., 1920x1080)."
    )
    return
  }

  if (Debounce("CraftWithCurrency", 100)) {
    return
  }

  state := SaveToggleState()
  ResetToggle()
  try {
    BlockInput("MouseMove")
    mousePos.SavePosition()
    CustomMouseMove(resolution.width, resolution.height)
    Sleep(50)
    Click("right")
    Sleep(50)
    mousePos.RestorePosition()
    Sleep(25)
    Click("left")
  } finally {
    BlockInput("MouseMoveOff")
    RestoreToggleState(state)
  }
}

Debounce(fnName, cooldownTime := 1000) {
  global LastExecutionTime

  currentTime := A_TickCount
  if (currentTime - LastExecutionTime.%fnName% < cooldownTime) {
    return true
  }

  LastExecutionTime.%fnName% := currentTime + cooldownTime
  return false
}

CustomMouseMove(x, y) {
  DllCall("SetCursorPos", "int", x, "int", y)
}

SaveToggleState() {
  global CtrlToggled, ShiftToggled
  return {
    ctrl: CtrlToggled,
    shift: ShiftToggled
  }
}

RestoreToggleState(state) {
  global CtrlToggled, ShiftToggled
  if (state.ctrl) {
    CtrlDown()
  } else {
    CtrlUp()
  }
  if (state.shift) {
    ShiftDown()
  } else {
    ShiftUp()
  }
}

ParseResolution(resolution) {
  if (!resolution || !RegExMatch(resolution, "^\d+(\.)?(\d+)?x\d+(\.)?(\d+)?$")) {
    return false
  }

  parts := StrSplit(resolution, "x")
  return {
    width: parts[1],
    height: parts[2]
  }
}

HighlightShopItems(*) {
  global CtrlToggled, ShiftToggled, clipboard
  modifierToggled := ""
  if (ShiftToggled) {
    modifierToggled := "shift"
  }
  if (CtrlToggled) {
    modifierToggled := "ctrl"
  }

  ResetToggle()

  clipboard.Save()
  clipboard.Clear()
  clipboard.Set(Format("`"{}`"", Extra.Get("HighlightShopItems", "(\w\W){5}|-\w-.-|(-\w){4}|(-\w){5}|nne|rint|ll g")))

  SendInput("^f")
  clipboard.Paste()
  clipboard.Restore()

  if (modifierToggled == "shift") {
    ToggleShift()
  }
  if (modifierToggled == "ctrl") {
    ToggleCtrl()
  }
}

CheckMapModifiers() {
  global clipboard
  clipboard.Save()
  clipboard.Clear()
  clipboard.Copy()
  Sleep(100)

  if (!InStr(clipboard.Get(), "Item Class: Maps")) {
    return
  }

  if RegExMatch(clipboard.Get(), "Monsters reflect (\d+)% of Physical Damage") {
    ToolTip("Read modifiers: physical reflect")
  } else if (RegExMatch(clipboard.Get(), "Monsters reflect (\d+)% of Elemental Damage")) {
    ToolTip("Read modifiers: elemental reflect")
  } else {
    ToolTip("OK")
  }

  Sleep(1000)
  ToolTip()
  clipboard.Restore()
}

; league specific
global ShipmentData := [{
  name: "Crimson Iron Ore",
  var: "CrimsonIronOre",
  value: 0
}, {
  name: "Orichalcum Ore",
  var: "OrichalcumOre",
  value: 0
}, {
  name: "Petrified Amber Ore",
  var: "PetrifiedAmberOre",
  value: 0
}, {
  name: "Bishmut Ore",
  var: "BishmutOre",
  value: 0
}, {
  name: "Verisium Ore",
  var: "VerisiumOre",
  value: 0
}, {
  name: "Crimson Iron Bar",
  var: "CrimsonIronBar",
  value: 0
}, {
  name: "Orichalcum Bar",
  var: "OrichalcumBar",
  value: 0
}, {
  name: "Petrified Amber Bar",
  var: "PetrifiedAmberBar",
  value: 0
}, {
  name: "Bishmut Bar",
  var: "BishmutBar",
  value: 0
}, {
  name: "Verisium Bar",
  var: "VerisiumBar",
  value: 0
}, {
  name: "Wheat",
  var: "Wheat",
  value: 0
}, {
  name: "Corn",
  var: "Corn",
  value: 0
}, {
  name: "Pumpkin",
  var: "Pumpkin",
  value: 0
}, {
  name: "Orgourd",
  var: "Orgourd",
  value: 0
}, {
  name: "Blue Zanthimum",
  var: "BlueZanthimum",
  value: 0
}, {
  name: "Thaumaturgic Dust",
  var: "ThaumaturgicDust",
  value: 0
},]
FillShipments(*) {
  global ShipmentData
  ResetToggle()

  for index, data in ShipmentData {
    SendInput("^a")
    SendInput(data.value)

    if (index != ShipmentData.Length) {
      SendInput("{Tab}")
      Sleep(100)
    }
  }
}
SaveShipmentValues(ShipmentGui) {
  global ShipmentData
  controls := ShipmentGui.Submit()

  for data in ShipmentData {
    IniWrite(controls.%data.var%, INI_FILE, "Shipment", data.var)
  }
  LoadShipmentValues()
}
LoadShipmentValues() {
  global ShipmentData

  for data in ShipmentData {
    shipmentValue := IniRead(INI_FILE, "Shipment", data.var, 0)
    data.value := shipmentValue
  }
}
openSettlersShipmentUI(*) {
  global ShipmentData
  ShipmentGui := Gui("+AlwaysOnTop", "Shipment Manager")
  x := 10
  y := 20
  w := 100

  for data in ShipmentData {
    ShipmentGui.Add("Text", "x" x " y" y " w" w, data.name ":")
    control := ShipmentGui.Add("Edit", "v" data.var " x" x + 100 " y" y " w" w, data.value)
    y := y + 30
  }

  ShipmentGui
    .Add("Button", "Default", "Save Shipment Values")
    .OnEvent("Click", (*) => SaveShipmentValues(ShipmentGui))
  ShipmentGui
    .Add("Button", , "Close")
    .OnEvent("Click", (*) => ShipmentGui.Destroy())

  ShipmentGui.Show()
}

DynamicHotkeys() {
  global clientFilePath, DynamicHotkeysActivated, DynamicHotkeysState

  FileModificationTime := FileGetTime(clientFilePath, "M")

  LastModified := DateDiff(A_Now, FileModificationTime, "Seconds")

  if (DynamicHotkeysActivated) {
    SetDynamicHotkeysState(DynamicHotkeysState, false)
    return
  }

  if (LastModified > 300 or Game.PreviousAttachTime) {
    SetDynamicHotkeysState("Off", false)
  } else {
    SetDynamicHotkeysState("On", false)
  }
}

GetPoEClientFilePath() {
  global clientFilePath, Configs, Hotkeys

  if (IsSet(clientFilePath) and clientFilePath) {
    return
  }

  ProcessPath := ProcessGetPath(Game.PID)
  logFilePath := RegExReplace(ProcessPath, "\\[^\\]*$", "\logs\Client.txt")

  if FileExist(logFilePath) {
    clientFilePath := logFilePath
  }
}
ListenToClientFile() {
  global clientFilePath, clientFile, clientFileReadFunc

  if (!IsSet(clientFile) and clientFilePath) {
    ; Open the file in read mode without locking it
    clientFile := FileOpen(clientFilePath, "r")
  }

  if (clientFile and !IsSet(clientFileReadFunc)) {
    clientFileReadFunc := ReadLogFile.Bind(clientFile)
    clientFile.Seek(0, 2)  ; Move to the end of the file
    SetTimer(clientFileReadFunc, 1000)
  }
}
UnlistenClientFile() {
  global clientFileReadFunc

  if (IsSet(clientFileReadFunc)) {
    SetTimer(clientFileReadFunc, 0)
    clientFileReadFunc := unset
  }
}
MatchPoe2Lines(line) {
  if (RegExMatch(line, "Generating level \d+ area `"(?:C_)?G\d_town|.*Hideout.*`"")) {
    return true
  }
  return false
}
MatchPoe1Lines(line) {
  if (RegExMatch(line, "Generating level \d+ area `"\d+_\d+(?:_.*)?_town|.*Hideout.*|KalguuranSettlersLeague`"")) {
    return true
  }
  return false
}
SetDynamicHotkeysState(state := "Off", setState := true) {
  global Configs, Hotkeys, DynamicHotkeysActivated, DynamicHotkeysState, ManualHotkeyEnabled

  if (ManualHotkeyEnabled) {
    return
  }

  for key, config in Configs.OwnProps() {
    if (config.toggleOnInstance and Hotkeys[key]) {
      RegisterHotkey("*" Hotkeys[key], config.func, state, config.canBeDisabled, Game.Title)
    }
  }
  if (setState) {
    DynamicHotkeysActivated := true
    DynamicHotkeysState := state
    SaveState()
  }
}
ReadLogFile(clientFile) {
  global Configs, Hotkeys, DynamicHotkeysActivated, DynamicHotkeysState

  if !IsObject(clientFile) {
    return  ; Ensure the file object is valid
  }

  if (newLines := clientFile.Read()) {
    if (RegExMatch(newLines, "\[STARTUP\] Game Start|Connected to")) {
      SetDynamicHotkeysState("Off")
    } else if (RegExMatch(newLines, "Generating level")) {
      ResetToggle()

      if (MatchPoe1Lines(newLines) or MatchPoe2Lines(newLines)) {
        SetDynamicHotkeysState("On")
      } else {
        SetDynamicHotkeysState("Off")
      }
    }
  }
}

HideWeaponDPS() {
  global DPSGui

  if (IsSet(DPSGui)) {
    DPSGui.Destroy()
    DPSGui := unset
    Sleep(100)
  }
}

WeaponDPS(*) {
  global DPSGui, clipboard

  if (Debounce("WeaponDPS", 250)) {
    return
  }

  HideWeaponDPS()
  SetTimer(HideWeaponDPS, 0)
  clipboard.Save()
  clipboard.Clear()
  clipboard.CopyWithAlt()
  item := clipboard.Get()
  clipboard.Restore()

  DPSGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
  DPSGui.BackColor := MAIN_COLOR
  WinSetTransparent("255", DPSGui)

  try {
    GuiCtrl := CalculateWeaponDPS(item, DPSGui)
    if (!GuiCtrl) {
      return
    }
  } catch Error as e {
    LogError("CalculateWeaponDPS", e)
  }

  MouseGetPos(&mouseX, &mouseY)
  DPSGui.Show("NoActivate x" mouseX " y" mouseY)
  SetTimer(HideWeaponDPS, -5000)
}
