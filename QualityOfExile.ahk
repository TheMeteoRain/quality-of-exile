#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2
#Include "MousePositionSaver.ahk"
#Include "ClipboardSaver.ahk"
#Include "GameInfo.ahk"

; Initialize variables
global CtrlToggled := false
global ShiftToggled := false
global ScrollSpam := false
global OverlayGui, CtrlLabel, ShiftLabel, SpamLabel

global Game := GameInfo()

global mousePos := MousePositionSaver()
global clipboard := ClipboardSaver()
global INI_FILE := "data.ini"
global Hotkeys := Map()
global Extra := Map()
global Options := {
    CenterUI: { value: 0, field: "Checkbox", name: "Center UI", tooltip: "TODO"},
}
global HotkeyData := [
    {name: "Enter Hideout", var: "OpenHideout", defaultHotkey: "F5",func: OpenHideout, extraField: false, tooltip: "How to use: press hotkey to enter hideout."},
    {name: "Enter Kingsmarch", var: "OpenKingsmarch", defaultHotkey: "F6",func: OpenKingsmarch, extraField: false, tooltip: "How to use: press hotkey to enter Kingsmarch."},
    {name: "Trade Divination Card", var: "PerformDivinationTrading", defaultHotkey: "",func: PerformDivinationTrading, extraField: false, tooltip: "How to use: open divination card trade screen and press this hotkey, while hovering over the desired full divination card stack in your inventory."},
    {name: "Drop Divination Card From Stack", var: "OpenDivinationStackCard", defaultHotkey: "",func: OpenDivinationStackCard, extraField: false, tooltip: "How to use: hover over the desired divination stack in your inventory and press this hotkey. Only usable in outdoor areas, since you cannot drop cards in hideout or similar areas."},
    {name: "Drop Item From Inventory", var: "DropItem", defaultHotkey: "",func: DropItem, extraField: false, tooltip: "How to use: hover over item in your intentory and press this hotkey."},
    {name: "Fill Shipments", var: "FillShipment", defaultHotkey: "",func: FillShipments, extraField: false, tooltip: "TODO"},
    {name: "Spam Ctrl Click", var: "CtrlClickSpamToggle", defaultHotkey: "",func: CtrlClickSpamToggle, extraField: false, tooltip: "TODO"},
    {name: "Enter Shop RegExp", var: "HighlightShopItems", defaultHotkey: "",func: HighlightShopItems, extraField: true, tooltip: "TODO", },
    {name: "Options (This GUI) ", var: "OpenHotkeyUI", defaultHotkey: "F10",func: OpenHotkeyUI, extraField: false, tooltip: "TODO"}
]
global HotkeyCustomData := [
    {name: "Toggle CTRL", var: "ToggleCtrl", defaultValue: 0,func: ToggleCtrl, tooltip: "TODO"},
    {name: "Toggle SHIFT", var: "ToggleShift", defaultValue: 0,func: ToggleShift, tooltip: "TODO"}
]
global MouseDropdownOptions := ["", "MButton", "XButton1", "XButton2", "WheelDown", "WheelUp"]

INS::KillSwitch()
KillSwitch() {
    ExitApp()
}

OpenHotkeyUI(*) {
    global Hotkeys, HotkeyData, Extra, HotkeyCustomData, Options
    x := 10
    y := 40
    w := 175
    colSize := 200

    HotkeyGui := Gui(, "Hotkey Manager")
    HotkeyGui.Add("Text", "w200", "Set Hotkeys for Actions:")
    HotkeyGui.Add("Text", "x" x+colSize " y20", "Keyboard Hotkey")
    HotkeyGui.Add("Text", "x" x+(colSize*2) " y20", "Mouse Hotkey")

    for index, data in HotkeyData {
        HotkeyGui.Add("Text", "x" x " y" y " w" w, data.name ":")
        controlHotkey := HotkeyGui.Add("Hotkey", "v" data.var " x" x + colSize " y" y " w" w)
        controlHotkey.Tooltip := data.tooltip
        controlDropdown := HotkeyGui.AddDropDownList("v" data.var "_mouseDropdownOptions x" x + 400 " y" y " w" 100, MouseDropdownOptions)
        controlDropdown.OnEvent("Change", onChangeDropdownToHotkey.Bind(controlHotkey))
        controlHotkey.OnEvent("Change", onChangeHotkeyToDropdown.Bind(controlDropdown))

        storedValue := Hotkeys.Get(data.var, "")
        if (storedValue != "" and index := hasKey(MouseDropdownOptions, storedValue)) {
            controlDropdown.Value := index
        } else {
            controlHotkey.Value := storedValue
        }

        if (data.var == "FillShipment") {
            y := y + 30
            control := HotkeyGui.Add("Button", "v" data.var "_extra x" x + colSize " y" y, "Shipment values")
            control.OnEvent("Click", openSettlersShipmentUI)
        }

        y := y + 30

        if (data.extraField and data.var == "HighlightShopItems") {
            control := HotkeyGui.Add("Edit", "v" data.var "_extra Limit50 -VScroll h60 x" x + 200 " y" y " w" w, Extra.Get(data.var, ""))
            y := y + 70
        }
 
        ;control.To := data.tooltip
        ;HotkeyGui.Add("DropDownList", "v" data.name, ["WheelUp","WheelDown","XButton1","XButton2"]).Value := Hotkeys.Get(data.name, "XButton2")

    }

    for data in HotkeyCustomData {
        HotkeyGui.Add("Text", "x" x " y" y " w" w, data.name ":")
        control := HotkeyGui.Add("Checkbox", "v" data.var " x" x + 200 " y" y)
        control.Value := Hotkeys.Get(data.var, 0)
        control.Tooltip := data.tooltip
        y := y + 30
    }

    
    for key, data in Options.OwnProps() {
        HotkeyGui.Add("Text", "x" x " y" y " w" w, data.name ":")
        control := HotkeyGui.Add(data.field, "v" key " x" x + 200 " y" y)
        control.Value := data.value
        control.Tooltip := data.tooltip
        y := y + 30
    }

    HotkeyGui.Add("Text", "w200", "Resolution: " Game.GameWidth "x" Game.GameHeight)
    HotkeyGui.Add("Button", "Default", "Save And Reload").OnEvent("Click", (*) => SaveConfigurations(HotkeyGui))
    HotkeyGui.Add("Button", , "Close").OnEvent("Click", (*) => HotkeyGui.Destroy())

    HotkeyGui.Show()
    OnMessage(0x0200, On_WM_MOUSEMOVE)
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

SaveConfigurations(HotkeyGui) {
    global INI_FILE, Hotkeys, HotkeyData, HotkeyCustomData, Options
    controls := HotkeyGui.Submit()

    for data in HotkeyData {
        val := controls.%data.var%

        if (val == "") {
            val := controls.%data.var "_mouseDropdownOptions"%
        }
        
        IniWrite(val, INI_FILE, "Hotkeys", data.var)

        if (data.extraField) {
            IniWrite(controls.%data.var "_extra"%, INI_FILE, "Extra", data.var)
            Extra.Set(data.var, controls.%data.var "_extra"%)
        }
    }

    for data in HotkeyCustomData {
        IniWrite(controls.%data.var%, INI_FILE, "Toggle", data.var)
    }

    for key, data in Options.OwnProps() {
        IniWrite(controls.%key%, INI_FILE, "Options", key)
    }

    Reload()
}



LoadConfigurations() {
    global INI_FILE, Hotkeys, HotkeyData, HotkeyCustomData, Options, Game

    For data in HotkeyData {
        hotkeyValue := IniRead(INI_FILE, "Hotkeys", data.var, data.defaultHotkey)
        Hotkeys.Set(data.var, hotkeyValue)

        if (data.extraField) {
            extraValue := IniRead(INI_FILE, "Extra", data.var, "-\\w-.-|(-\\w){4}|(-\\w){5}|[gr]-[gr]-[gr]|nne|rint")
            Extra.Set(data.var, extraValue)
        }

        if (hotkeyValue != "") {
            HotIfWinActive(Game.Title)
            Hotkey("*" hotkeyValue, data.func)
        }
    }


    for key, data in Options.OwnProps() {
        value := IniRead(INI_FILE, "Options", key, 0)
        data.value := value

        if (key == "CenterUI" and value == 1) {
            Game.CenterUi := value
        } else {
            Game.CenterUi := value
        }
    }

    for data in HotkeyCustomData {
        hotkeyValue := 0
        if (data.var == "ToggleCtrl") {
            hotkeyValue := IniRead(INI_FILE, "Toggle", data.var, data.defaultValue)
        }
        if (data.var == "ToggleShift") {
            hotkeyValue := IniRead(INI_FILE, "Toggle", data.var, data.defaultValue)
        }
        Hotkeys.Set(data.var, hotkeyValue)

        HotIfWinActive(Game.Title)
        if (hotkeyValue == 1) {
            if (data.var == "ToggleCtrl") {
                Hotkey("*Ctrl", data.func)
            }
            if (data.var == "ToggleShift") {
                Hotkey("*Shift", data.func)
            }
        }
        ;HotIfWinActive(Game.Title)
        ;Hotkey("*>", ResetToggle)
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
        Hotkey("*LWin", ResetToggleWin)
        HotIfWinActive(Game.Title)
        Hotkey("*!Tab", ResetToggleAltTab)
        HotIfWinActive(Game.Title)
        Hotkey("*Esc", ResetToggleEsc)
        ; HotIfWinActive(Game.Title)
        ; Hotkey("*Space", ResetToggleSpace)
    }
}


ShowOverlay() {
    global OverlayGui, CtrlLabel, ShiftLabel, SpamLabel

    if (Hotkeys["ToggleCtrl"] or Hotkeys["ToggleShift"] or Hotkeys["CtrlClickSpamToggle"]) {
        OverlayGui := Gui()
        OverlayGui.Title := "Toggle Overlay"
        OverlayGui.BackColor := "Black"
        OverlayGui.Opt("-Caption +AlwaysOnTop +ToolWindow")
        WinSetTransColor(OverlayGui.BackColor " 150", OverlayGui)
        CtrlLabel := OverlayGui.Add("Text", "x10 y10 w" Game.OverlayWidth / 2 " h30 vCtrlLabel", "Ctrl: OFF")
        CtrlLabel.SetFont("cWhite s12 w700 q4")
        ShiftLabel := OverlayGui.Add("Text", "x10 y40 w" Game.OverlayWidth / 2 " h30 vShiftLabel", "Shift: OFF")
        ShiftLabel.SetFont("cWhite s12 w700 q4")
        SpamLabel := OverlayGui.Add("Text", "x" Game.OverlayWidth / 2 " y10 w" Game.OverlayWidth / 2 " h30 vSpam")
        SpamLabel.SetFont("cRed s12 w700 q4")
        OverlayGui.Show("x" Game.OverlayPosX " y" Game.OverlayPosY " w" Game.OverlayWidth " h" Game.OverlayHeight " NoActivate")
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
    mousePos.SavePosition()

    ResetToggle()
    CtrlDown()

    Click("left")
    MouseMove(Game.DivTradeButtonX, Game.DivTradeButtonY, 25)
    Sleep(Random(175, 225))
    Click("left")
    MouseMove(Game.DivTradeAreaX, Game.DivTradeAreaY, 25)
    Sleep(Random(175, 225))
    Click("left")

    if (CtrlToggled) {
        CtrlUp()
    }

    mousePos.RestorePosition()
}

OpenDivinationStackCard(*) {
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
    SendInput("{Enter}/hideout{Enter}")
}

OpenKingsmarch(*) {
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
ShowOverlay()

Main() {
    global game
Hwnd := WinWaitActive(Game.Hwnd)
    
    if (HWND and WinWaitNotActive(Game.Hwnd)) {
        ResetToggle()
        Main()
    }
}
Main()