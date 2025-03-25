#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2
#Include "MousePositionSaver.ahk"
#Include "ClipboardSaver.ahk"
#Include "GameInfo.ahk"

ScriptVersion := "0.1.0-beta.3"

; Initialize variables
global CtrlToggled := false
global ShiftToggled := false
global ScrollSpam := false
global OverlayGui, CtrlLabel, ShiftLabel, SpamLabel, HotkeyGui
global Game := GameInfo()
global mousePos := MousePositionSaver()
global clipboard := ClipboardSaver()
global INI_FILE := "data.ini"
global Hotkeys := Map()
global Extra := Map()
global Options :=  Map()
global MouseDropdownOptions := ["", "MButton", "XButton1", "XButton2", "WheelDown", "WheelUp"]
global Remember := {
    EnterHideout: {
        name: "Enter Hideout",
        var: "OpenHideout",
        defaultHotkey: "F5",
        func: OpenHideout,
        mouseBind: false,
        tooltip: "How to use: press hotkey to enter hideout.",
        toggleOnInstance: false,
        tab: "Tab1",
        section: "Hotkey",
        coords: { x: 0, y: 0 }
    },
    EnterKingsmarch: {
        name: "Enter Kingsmarch",
        var: "OpenKingsmarch",
        defaultHotkey: "F6",
        func: OpenKingsmarch,
        mouseBind: false,
        tooltip: "How to use: press hotkey to enter Kingsmarch.",
        toggleOnInstance: false,
        tab: "Tab1",
        section: "Hotkey",
        coords: { x: 0, y: 40 }
    },
    OpenStackedDivinationDeck: {
        name: "Open Stacked Divination Deck",
        defaultHotkey: "",
        func: OpenStackedDivinationDeck,
        mouseBind: true,
        tooltip: "How to use: hover over the desired divination stack in your inventory and press this hotkey. Only usable in outdoor areas, since you cannot drop cards in hideout or similar areas.",
        toggleOnInstance: false,
        tab: "Tab1",
        section: "Hotkey",
        coords: { x: 0, y: 120 }
    },
    TradeDivinationCard: {
        name: "Trade Divination Card",
        defaultHotkey: "",
        func: PerformDivinationTrading,
        extraField: true,
        mouseBind: false,
        tooltip: "How to use: open divination card trade screen and press this hotkey, while hovering over the desired full divination card stack in your inventory.",
        toggleOnInstance: false,
        tab: "Tab2",
        section: "Hotkey",
        coords: { x: 0, y: 0 },
        pixelSelect: true,
        vars: ["TradeDivinationCardButton", "TradeDivinationCardArea"]
    },
    DropItem: {
        name: "Drop Item From Inventory",
        defaultHotkey: "",
        func: DropItem,
        mouseBind: true,
        tooltip: "How to use: hover over item in your inventory and press this hotkey.",
        toggleOnInstance: false,
        tab: "Tab1",
        section: "Hotkey",
        coords: { x: 0, y: 160 }
    },
    FillShipment: {
        name: "Fill Shipments",
        var: "FillShipment",
        defaultHotkey: "",
        func: FillShipments,
        mouseBind: true,
        tooltip: "TODO",
        toggleOnInstance: false,
        tab: "Tab1",
        section: "Hotkey",
        coords: { x: 0, y: 200 }
    },
    CtrlClickSpamToggle: {
        name: "Spam Ctrl Click",
        defaultHotkey: "",
        func: CtrlClickSpamToggle,
        mouseBind: true,
        tooltip: "TODO",
        toggleOnInstance: false,
        coords: { x: 0, y: 80 },
        tab: "Tab1",
        section: "Hotkey"
    },
    HighlightShopItems: {
        name: "Enter Shop RegExp",
        defaultHotkey: "",
        func: HighlightShopItems,
        extraField: true,
        mouseBind: true,
        tooltip: "TODO",
        toggleOnInstance: false,
        tab: "Tab1",
        section: "Hotkey",
        coords: { x: 0, y: 260 }
    },
    OrbOfTransmutation: {
        name: "Orb of Transmutation",
        defaultHotkey: "",
        func: OrbOfTransmutation,
        extraField: true,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: true,
        tab: "Tab2",
        section: "Hotkey",
        coords: { x: 0, y: 80 },
        pixelSelect: true
    },
    OrbOfAlteration: {
        name: "Orb of Alteration",
        defaultHotkey: "",
        func: OrbOfAlteration,
        extraField: true,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: true,
        tab: "Tab2",
        section: "Hotkey",
        coords: { x: 0, y: 120 },
        pixelSelect: true
    },
    OrbOfChance: {
        name: "Orb of Chance",
        defaultHotkey: "",
        func: CraftOrbOfChance,
        extraField: true,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: true,
        tab: "Tab2",
        section: "Hotkey",
        coords: { x: 0, y: 160 },
        pixelSelect: true
    },
    AlchemyOrb: {
        name: "Alchemy Orb",
        defaultHotkey: "",
        func: CraftAlchemyOrb,
        extraField: true,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: true,
        tab: "Tab2",
        section: "Hotkey",
        coords: { x: 0, y: 200 },
        pixelSelect: true
    },
    OrbOfScouring: {
        name: "Orb of Scouring",
        defaultHotkey: "",
        func: CraftOrbOfScouring,
        extraField: true,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: true,
        tab: "Tab2",
        section: "Hotkey",
        coords: { x: 0, y: 240 },
        pixelSelect: true
    },
    ChaosOrb: {
        name: "Chaos Orb",
        defaultHotkey: "",
        func: ChaosOrb,
        extraField: true,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: true,
        tab: "Tab2",
        section: "Hotkey",
        coords: { x: 0, y: 280 },
        pixelSelect: true
    },
    KillSwitch: {
        name: "Kill Switch",
        defaultHotkey: "Insert",
        func: KillSwitch,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: false,
        tab: "Tab3",
        section: "Hotkey",
        coords: { x: 0, y: 120 }
    },
    OpenConfigurationWindow: {
        name: "Options (This GUI)",
        defaultHotkey: "F10",
        func: OpenConfigurationWindow,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: false,
        tab: "Tab3",
        section: "Hotkey",
        coords: { x: 0, y: 160 }
    },
    ToggleCtrl: { name: "Toggle CTRL", defaultValue: 0, func: ToggleCtrl, tooltip: "TODO", section: "Toggle", tab: "Tab3", coords: { x: 0, y: 0 } },
    ToggleShift: { name: "Toggle SHIFT", defaultValue: 0, func: ToggleShift, tooltip: "TODO", section: "Toggle", tab: "Tab3", coords: { x: 0, y: 40 } },
    CenterUI: { value: 0, field: "Checkbox", name: "Center UI", tooltip: "TODO", section: "Options", tab: "Tab3", coords: { x: 0, y: 80 } },
}

KillSwitch(*) {
    ExitApp()
}

OpenConfigurationWindow(*) {
    global Hotkeys, Extra, Options, HotkeyGui, Remember
    ; padding x
    pX := 20
    ; padding y
    pY := 40
    w := 150
    colSize := 175
    rowSize := 30
    maxY := 0

    if (IsSet(HotkeyGui)) {
        HotkeyGui.Destroy()
    }

    HotkeyGui := Gui(, "Hotkey Manager")
    TabControl := HotkeyGui.Add("Tab3", "", ["Tab1","Tab2","Tab3"])
    
    TabControl.UseTab("Tab1")
    HotkeyGui.Add("Text", Format("x{} y{} w{}", pX, pY, 200), "Set Hotkeys for Actions:")
    HotkeyGui.Add("Text", Format("x{} y{}", pX+colSize, pY), "Keyboard Hotkey")
    HotkeyGui.Add("Text", Format("x{} y{}", pX+colSize*2, pY), "Mouse Hotkey")

    TabControl.UseTab("Tab2")
    HotkeyGui.Add("Text", Format("x{} y{} w{}", pX, pY, 200), "Set Hotkeys for Actions:")
    HotkeyGui.Add("Text", Format("x{} y{}", pX+colSize, pY), "Keyboard Hotkey")
    HotkeyGui.Add("Text", Format("x{} y{}", pX+colSize*2, pY), "Pixel")

    TabControl.UseTab("Tab3")
    HotkeyGui.Add("Text", Format("x{} y{} w{}", pX, pY, 200), "Set Hotkeys for Actions:")
    HotkeyGui.Add("Text", Format("x{} y{}", pX+colSize, pY), "Keyboard Hotkey")

    pixelSearchCtrls(key, x1, y1, x2, y2) {
        pixelTextCtrl := HotkeyGui.Add("Edit", Format("v{}Pixel x{} y{} w{} {}", key, x1, y1, 100, "+Center ReadOnly"), Extra.Get(key "Pixel", ""))
        pixelButtonCtrl := HotkeyGui.Add("Button", Format("v{}PixelSelect x{} y{} w{}", key, x2, y2, 100), "Select Pixel")
        pixelButtonCtrl.OnEvent("Click", SelectPixel.Bind(pixelButtonCtrl, pixelTextCtrl, key))
    }

    for key, config in Remember.OwnProps() {
        TabControl.UseTab(config.tab)
        x := config.coords.x + pX
        y := config.coords.y + pY + rowSize
        maxY := Max(y, maxY)

        if (config.section == "Hotkey") {
            textGuiControl := HotkeyGui.Add("Text", Format("x{} y{} w{}", x, y, w), config.name ":")
            mainGuiControl := HotkeyGui.Add("Hotkey", Format("v{} x{} y{} w{}", key, x+colSize, y, w), Hotkeys.Get(key, ""))
            hotkeyValue := Hotkeys.Get(key, "")
            mainGuiControl.Value := hotkeyValue


            if (config.HasProp("mouseBind") and config.mouseBind) {
                guiDropdown := HotkeyGui.Add("DropDownList", Format("v{} x{} y{} w{}", key "_mouseDropdownOptions", x+colSize*2, y, w), MouseDropdownOptions)
                guiDropdown.OnEvent("Change", onChangeDropdownToHotkey.Bind(mainGuiControl))
                mainGuiControl.OnEvent("Change", onChangeHotkeyToDropdown.Bind(guiDropdown))

                hotkeyValue := Hotkeys.Get(key, "")
                if (hotkeyValue != "" and index := hasKey(MouseDropdownOptions, hotkeyValue)) {
                    guiDropdown.Value := index
                } else {
                    mainGuiControl.Value := hotkeyValue
                }
            }

            if (config.HasProp("pixelSelect") and config.pixelSelect) {
                if (config.HasProp("vars") and config.vars.Length > 0) {
                    for index, var in config.vars {
                        pixelSearchCtrls(var, x+colSize*2, y+rowSize*(index-1), x+(colSize-20)*3, y+rowSize*(index-1))
                    }
                } else {
                    pixelSearchCtrls(key, x+colSize*2, y, x+(colSize-20)*3, y)
                }
            }

            if (key == "HighlightShopItems") {
                extraGuiControl := HotkeyGui.Add("Edit", Format("v{}_extra x{} y{} w{} {}", key, x+colSize, y+rowSize, w, "Limit50 -VScroll h60"), Extra.Get(key, ""))
            }

            if (key == "FillShipment") {
                control := HotkeyGui.Add("Button", Format("v{}_extra x{} y{}", key, x+colSize, y+rowSize), "Shipment values")
                control.OnEvent("Click", openSettlersShipmentUI)
            }

            continue
        }

        if (config.section == "Options" or config.section == "Toggle") {
            HotkeyGui.Add("Text", Format("x{} y{} w{}", x, y, w), config.name ":")
            control := HotkeyGui.Add("Checkbox", Format("v{} x{} y{}", key, x+colSize, y))
            control.Value := Hotkeys.Get(key, 0)
            control.Tooltip := config.tooltip

            if (key == "CenterUI") {
                if (Game.AllowCenterUI) {
                    control.Enabled := 1
                } else {
                    control.Enabled := 0
                }
            }

            continue
        }
    }

    TabControl.UseTab("")

    HotkeyGui.Add("Text", Format("x{} y{} w{} Center", 0, maxY + 100, 200), "QualityOfExile version:`n" ScriptVersion)
    HotkeyGui.Add("Link", Format("x{} y{} w{}", x+pX, maxY + 135, w), '<a href="https://github.com/TheMeteoRain/quality-of-exile">Github / Documentation</a>')

    HotkeyGui.Add("Button", Format("x{} y{} w{} Default", 210, maxY + 100, 200), "Save And Reload").OnEvent("Click", SaveConfigurations)
    HotkeyGui.Add("Button", Format("x{} y{} w{}", 210, maxY + 100 + rowSize, 200), "Close").OnEvent("Click", (*) => HotkeyGui.Destroy())

    HotkeyGui.Show()
    ;OnMessage(0x0200, On_WM_MOUSEMOVE)
}


SelectPixel(control, pixelTextControl, param1, *) {
    SelectedX := 0
    SelectedY := 0

    HotkeyGui.Hide()
    ; Enable real-time tooltip to show mouse coordinates
    ToolTip("Move your mouse to select a pixel. Click to confirm." param1 " " control.name)

    WatchCursorBind := WatchCursor.Bind(&SelectedX, &SelectedY)
    ; Continuously update the tooltip with the current mouse position
    SetTimer(WatchCursorBind, 5)

    ; Wait for the user to click
    KeyWait("LButton", "D")  ; Wait for the left mouse button to be pressed
    SetTimer(WatchCursorBind, 0)  ; Turn off the timer after the click
    ToolTip()  ; Remove the tooltip

    ; Display the selected coordinates
    MsgBox("Selected Pixel: X = " SelectedX ", Y = " SelectedY " "  param1 " " control.name)
    pixelTextControl.Value := SelectedX "x" SelectedY
    HotkeyGui.Show()
}

WatchCursor(&SelectedX, &SelectedY, *) {
    ; Get the current mouse position
    
    CoordMode("Mouse", "Window")
    MouseGetPos(&SelectedX, &SelectedY)
    
    ; Update the tooltip with the current coordinates
    ToolTip("Current Mouse Position: X = " SelectedX ", Y = " SelectedY "`nClick to confirm.")
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

On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd)
{
    static PrevHwnd := 0
    if (Hwnd != PrevHwnd)
    {
        Text := "", ToolTip() ; Turn off any previous tooltip.
        CurrControl := GuiCtrlFromHwnd(Hwnd)
        if CurrControl
        {
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

SaveConfigurations(*) {
    global INI_FILE, Hotkeys, Options, Extra, Remember
    controls := HotkeyGui.Submit()

    for key, config in Remember.OwnProps() {
        if (config.section == "Hotkey") {
            val := controls.%key%

            if (config.mouseBind and val == "") {
                val := controls.%key "_mouseDropdownOptions"%
            }
    
            IniWrite(val, INI_FILE, "Hotkeys", key)
    
            if (config.HasProp("pixelSelect") and config.pixelSelect) {
                if (config.HasProp("vars") and config.vars.Length > 0) {
                    for index, var in config.vars {
                        IniWrite(controls.%var "Pixel"%, INI_FILE, "Pixels", var "Pixel")
                        Extra.Set(var, controls.%var "Pixel"%)
                    }
                } else {
                    IniWrite(controls.%key "Pixel"%, INI_FILE, "Pixels", key "Pixel")
                    Extra.Set(key, controls.%key "Pixel"%)
                }
            }
            
            continue
        }
        
        if (config.section == "Toggle") {
            IniWrite(controls.%key%, INI_FILE, "Toggle", key)
            continue
        }

        if (config.section == "Options") {
            IniWrite(controls.%key%, INI_FILE, "Options", key)
            continue
        }
    }

    Reload()
}

LoadConfigurations() {
    global INI_FILE, Hotkeys, Options, Game, Remember

    try {
        for key, config in Remember.OwnProps() {
            if (config.section == "Hotkey") {
                val := IniRead(INI_FILE, "Hotkeys", key, config.defaultHotkey)
                Hotkeys.Set(key, val)
        
                if (config.HasProp("pixelSelect") and config.pixelSelect) {
                    if (config.HasProp("vars") and config.vars.Length > 0) {
                        for index, var in config.vars {
                            extraValue := IniRead(INI_FILE, "Pixels", var "Pixel", "")
                            Extra.Set(var "Pixel", extraValue)
                        }
                    } else {
                        extraValue := IniRead(INI_FILE, "Pixels", key "Pixel", "")
                        Extra.Set(key "Pixel", extraValue)
                    }
                }

                if (key == "HighlightShopItems") {
                    extraValue := IniRead(INI_FILE, "Extra", key, "-\\w-.-|(-\\w){4}|(-\\w){5}|[gr]-[gr]-[gr]|nne|rint")
                    Extra.Set(key, extraValue)
                }

                if (val && key == "KillSwitch") {
                    HotIf()
                    Hotkey("*" val, config.func)
                } else {
                    HotIfWinActive(Game.Title)
                    Hotkey("*" val, config.func)
                }

                continue
            }
            
            if (config.section == "Options") {
                val := IniRead(INI_FILE, "Options", key, 0)
                Hotkeys.Set(key, val)

                if (key == "CenterUI" and val == 1 and Game.AllowCenterUI) {
                    Game.CenterUi := true
                } else {
                    Game.CenterUi := false
                }

                continue
            }

            if (config.section == "Toggle") {
                val := IniRead(INI_FILE, "Toggle", key, 0)
                Hotkeys.Set(key, val)

                HotIfWinActive(Game.Title)
                if (val == 1) {
                    if (key == "ToggleCtrl") {
                        Hotkey("*Ctrl", config.func)
                    }
                    if (key == "ToggleShift") {
                        Hotkey("*Shift", config.func)
                    }
                }

                continue
            }
        }

        if (Hotkeys["ToggleCtrl"] == 1 and Hotkeys["ToggleShift"] == 0) {
            HotIfWinActive(Game.Title)
            Hotkey("*Shift", ResetToggle)
        }
        if (Hotkeys["ToggleCtrl"] == 0 and Hotkeys["ToggleShift"] == 1) {
            HotIfWinActive(Game.Title)
            Hotkey("*Ctrl", ResetToggle)
        }

        if (Hotkeys["ToggleCtrl"] == 1 or Hotkeys["ToggleShift"] == 1) {
            HotIfWinActive(Game.Title)
            Hotkey("#LWin", ResetToggle)
            HotIfWinActive(Game.Title)
            Hotkey("~*LWin", ResetToggleWin)
            HotIfWinActive(Game.Title)
            Hotkey("*Esc", ResetToggleEsc)
            ; HotIfWinActive(Game.Title)
            ; Hotkey("*Space", ResetToggleSpace)
        }
    } catch Error as e {
        MsgBox("An error occurred while running the script:`n`n"
            . "Error: " e.what "`n"
            . "Details: " e.message "`n"
            . "File: " e.file "`n"
            . "Line: " e.line "`n"
            . (e.extra ? "Additional Info: " e.extra "`n" : ""), "Error", 16
        )
        KillSwitch()
    }
}

CreateOverlay() {
    global OverlayGui, CtrlLabel, ShiftLabel, SpamLabel

    if (IsSet(OverlayGui)) {
        return
    }

    if (Hotkeys["ToggleCtrl"] or Hotkeys["ToggleShift"] or Hotkeys["CtrlClickSpamToggle"]) {
        OverlayGui := Gui()
        OverlayGui.Title := "Toggle Overlay"
        OverlayGui.BackColor := "Black"
        OverlayGui.Opt("-Caption +AlwaysOnTop +ToolWindow +E0x20")
        WinSetTransColor(OverlayGui.BackColor " 150", OverlayGui)
        CtrlLabel := OverlayGui.Add("Text", "x10 y10 w" Game.OverlayWidth / 2 " h30 vCtrlLabel", "Ctrl: OFF")
        CtrlLabel.SetFont("cWhite s12 w700 q4")
        ShiftLabel := OverlayGui.Add("Text", "x10 y40 w" Game.OverlayWidth / 2 " h30 vShiftLabel", "Shift: OFF")
        ShiftLabel.SetFont("cWhite s12 w700 q4")
        SpamLabel := OverlayGui.Add("Text", "x" Game.OverlayWidth / 2 " y10 w" Game.OverlayWidth / 2 " h30 vSpam")
        SpamLabel.SetFont("cRed s12 w700 q4")
    }
}
ShowOverlay() {
    global OverlayGui
    if (IsSet(OverlayGui)) {
        OverlayGui.Show("x" Game.OverlayPosX " y" Game.OverlayPosY " w" Game.OverlayWidth " h" Game.OverlayHeight " NoActivate")
    }
}
HideOverlay() {
    global OverlayGui

    if (IsSet(OverlayGui)) {
        OverlayGui.Hide()
    }
}
; Functions
ResetToggle(*) {
    global Hotkeys

    if (Hotkeys["ToggleCtrl"] or Hotkeys["ToggleShift"] or Hotkeys["CtrlClickSpamToggle"]) {
        StopSpam2()
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
    global CtrlToggled, ShiftToggled

    ShiftUp()
    if (!CtrlToggled) {
        CtrlDown()
    } else {
        CtrlUp()
    }
}

ToggleShift(*) {
    global CtrlToggled, ShiftToggled
    
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
    CtrlLabel.Text := "Ctrl: ON ***"
    CtrlLabel.SetFont("cRed")
    CtrlToggled := true
}

CtrlUp() {
    global CtrlToggled
    SendInput("{Ctrl up}")
    CtrlLabel.Text := "Ctrl: OFF"
    CtrlLabel.SetFont("cWhite")
    CtrlToggled := false
}

ShiftDown() {
    global ShiftToggled
    SendInput("{Shift down}")
    ShiftLabel.Text := "Shift: ON ***"
    ShiftLabel.SetFont("cRed")
    ShiftToggled := true
}

ShiftUp() {
    global ShiftToggled
    SendInput("{Shift up}")
    ShiftLabel.Text := "Shift: OFF"
    ShiftLabel.SetFont("cWhite")
    ShiftToggled := false
}

StopSpam2() {
    global ScrollSpam, SpamLabel
    ScrollSpam := false
    SpamLabel.Text := ""
}

StopSpam(keepToggled) {
    global ScrollSpam, SpamLabel
    ScrollSpam := false

    Sleep(100) ;fixes if this func is programmed to wheelup/down
    if (keepToggled == "ctrl") {
        ShiftUp()
    } else if (keepToggled == "shift") {
        CtrlUp()
    } else {
        CtrlUp()
        ShiftUp()
    }
    SpamLabel.Text := ""
}

StartSpam() {
    global ScrollSpam, SpamLabel
    ScrollSpam := true

    ShiftUp()
    CtrlDown()
    SpamLabel.Text := "SPAM!"

    fn() {
        if (ScrollSpam) {
            SendInput("{LButton}")
        } else {
            SpamLabel.Text := ""
        }
    }
    SetTimer(fn, Random(30, 50))
}

CtrlClickSpamToggle(*) {
    global ScrollSpam
    ScrollSpam := !ScrollSpam

    if (ScrollSpam) {
        StartSpam()
    } else {
        StopSpam("")
    }
}

PerformDivinationTrading(*) {
    global CtrlToggled, mousePos

    BlockInput("MouseMove")
    mousePos.SavePosition()
    ResetToggle()
    CtrlDown()

    buttonResolution := ParseResolution(Extra["PerformDivinationTrading_TradeButton"])
    areaResolution := ParseResolution(Extra["PerformDivinationTrading_TradeArea"])

    Click("left")
    MouseMove(buttonResolution.width, buttonResolution.height, 25)
    Sleep(Random(175, 225))
    Click("left")
    MouseMove(areaResolution.width, areaResolution.height, 25)
    Sleep(Random(175, 225))
    Click("left")

    if (CtrlToggled) {
        CtrlUp()
    }

    mousePos.RestorePosition()
    BlockInput("MouseMoveOff")
}

OpenStackedDivinationDeck(*) {
    global mousePos

    mousePos.SavePosition()
    ResetToggle()

    Click("right")
    MouseMove(Game.ScreenMiddleWithInventoryX, Game.ScreenMiddleWithInventoryY, 1)
    Sleep(150)
    Click("left")
    Sleep(75)
    mousePos.RestorePosition()
    Sleep(10)
}

DropItem(*) {
    global mousePos, clipboard

    ResetToggle()
    mousePos.SavePosition()

    Click("left")
    MouseMove(Game.ScreenMiddleWithInventoryX, Game.ScreenMiddleWithInventoryY, 1)
    Sleep(150)
    Click("left")
    Sleep(75)
    mousePos.RestorePosition()
    Sleep(10)
}

OpenHideout(*) {
    ResetToggle()
    SendInput("{Enter}/hideout{Enter}")
}

OpenKingsmarch(*) {
    ResetToggle()
    SendInput("{Enter}/kingsmarch{Enter}")
}

OpenCurrencyTab() {
    global mousePos
    mousePos.SavePosition()
    CurrencyTabX := Game.BlackBarSize + 985
    CurrencyTabY := 160
    MouseMove(CurrencyTabX, CurrencyTabY, 1)
    Sleep(200)
    Click("left")
    mousePos.RestorePosition()
}

CraftAlchemyOrb(*) {
    CraftWithOrb("Alchemy Orb", "AlchemyOrbPixel")
}
CraftOrbOfChance(*) {
    CraftWithOrb("Orb of Chance", "OrbOfChancePixel")
}
CraftOrbOfScouring(*) {
    CraftWithOrb("Orb of Scouring", "OrbOfScouringPixel")
}
ChaosOrb(*) {
    CraftWithOrb("Chaos Orb", "ChaosOrbPixel")
}
OrbOfTransmutation(*) {
    CraftWithOrb("Orb of Transmutation", "OrbOfTransmutationPixel")
}
OrbOfAlteration(*) {
    CraftWithOrb("Orb of Alteration", "OrbOfAlterationPixel")
}

CraftWithOrb(name, key) {
    global mousePos

    if (!Extra.Has(key)) {
        MsgBox("Set pixel for " name ". Use the Pixel Search button in Configuration Window.")
        return
    }

    resolution := ParseResolution(Extra[key])
    if (!resolution) {
        MsgBox("Invalid resolution for " name ". Please set a valid resolution in the format 'widthxheight' (e.g., 1920x1080).")
        return
    }
    
    BlockInput("MouseMove")
    mousePos.SavePosition()
    MouseMove(resolution.width, resolution.height, 0)
    Sleep(50)
    Click("right")
    Sleep(75)
    mousePos.RestorePosition()
    Sleep(75)
    Click("left")
    BlockInput("MouseMoveOff")
}

ParseResolution(resolution) {
    if (!resolution || !RegExMatch(resolution, "^\d+x\d+$")) {
        return false
    }

    parts := StrSplit(resolution, "x")
    return {width: parts[1], height: parts[2]}
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
    clipboard.Set(Extra.Get("HighlightShopItems", "-\\w-.-|(-\\w){4}|(-\\w){5}|[gr]-[gr]-[gr]|nne|rint"))

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
global ShipmentData := [
    {name: "Crimson Iron Ore", var: "CrimsonIronOre", value: 0},
    {name: "Orichalcum Ore", var: "OrichalcumOre", value: 0},
    {name: "Petrified Amber Ore", var: "PetrifiedAmberOre", value: 0},
    {name: "Bishmut Ore", var: "BishmutOre", value: 0},
    {name: "Verisium Ore", var: "VerisiumOre", value: 0},
    {name: "Crimson Iron Bar", var: "CrimsonIronBar", value: 0},
    {name: "Orichalcum Bar", var: "OrichalcumBar", value: 0},
    {name: "Petrified Amber Bar", var: "PetrifiedAmberBar", value: 0},
    {name: "Bishmut Bar", var: "BishmutBar", value: 0},
    {name: "Verisium Bar", var: "VerisiumBar", value: 0},
    {name: "Wheat", var: "Wheat", value: 0},
    {name: "Corn", var: "Corn", value: 0},
    {name: "Pumpkin", var: "Pumpkin", value: 0},
    {name: "Orgourd", var: "Orgourd", value: 0},
    {name: "Blue Zanthimum", var: "BlueZanthimum", value: 0},
    {name: "Thaumaturgic Dust", var: "ThaumaturgicDust", value: 0},
]
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
    global INI_FILE, ShipmentData
    controls := ShipmentGui.Submit()

     for data in ShipmentData {
        IniWrite(controls.%data.var%, INI_FILE, "Shipment", data.var)
    }
    LoadShipmentValues()
}
LoadShipmentValues() {
     global INI_FILE, ShipmentData

    for data in ShipmentData {
        shipmentValue := IniRead(INI_FILE, "Shipment", data.var, 0)
        data.value := shipmentValue
    }
}
openSettlersShipmentUI(*) {
    global ShipmentData
    ShipmentGui := Gui(, "Shipment Manager")
    x := 10
    y := 20
    w := 100

    for data in ShipmentData {
        ShipmentGui.Add("Text", "x" x " y" y " w" w, data.name ":")
        control := ShipmentGui.Add("Edit", "v" data.var " x" x + 100 " y" y " w" w, data.value)
        y := y + 30
    }

    ShipmentGui.Add("Button", "Default", "Save Shipment Values").OnEvent("Click", (*) => SaveShipmentValues(ShipmentGui))
    ShipmentGui.Add("Button", , "Close").OnEvent("Click", (*) => ShipmentGui.Destroy())

    ShipmentGui.Show()
}

LoadConfigurations()
LoadShipmentValues()
CreateOverlay()

global clientFile

Main() {
    global Game, clientFile

    if (!Game.GameClientExists()) {
        HideOverlay()
        Game := GameInfo()
    }
    CoordMode("Menu", "Client")
    CoordMode("Mouse", "Client")

    WinWaitActive(Game.Hwnd)
    if (Game.GameClientExists()) {
        ShowOverlay()
    }
    
    FindPoELogFile() {
        ProcessPath := ProcessGetPath(Game.PID)
        logFilePath := RegExReplace(ProcessPath, "\\[^\\]*$", "\logs\Client.txt")

        if FileExist(logFilePath) {
            return logFilePath
        }
    
        return ""
    }
    logFile := FindPoELogFile()  ; Adjust path if needed

    if (logFile) {
        ; Open the file in read mode without locking it
        clientFile := FileOpen(logFile, "r")
        clientFile.Seek(0, 2)  ; Move to the end of the file
        SetTimer(ReadLogFile, 1000)  ; Call ReadLogFile every 1000ms (1 second)
    }

    if (WinWaitNotActive(Game.Hwnd)) {
        ResetToggle()
        Main()
    }
}
Main()

ReadLogFile() {
    global clientFile, Remember, Hotkeys

    if !IsObject(clientFile) {
        return  ; Ensure the file object is valid
    }

    ; Read new lines from the file
    if (newLines := clientFile.Read()) {
        ; Process new lines
        if RegExMatch(newLines, "You have entered .*") {
            ResetToggle()

            if RegExMatch(newLines, "You have entered .* Hideout.") {
                for key, config in Remember.OwnProps() {
                    if (config.HasOwnProp("toggleOnInstance") and Hotkeys[key]) {
                        Hotkey("*" Hotkeys[key], config.func, "On")
                    }
                }
            } else {
                for key, config in Remember.OwnProps() {
                    if (config.HasOwnProp("toggleOnInstance") and Hotkeys[key]) {
                        Hotkey("*" Hotkeys[key], config.func, "Off")
                    }
                }
            }
        }
        
    }
}