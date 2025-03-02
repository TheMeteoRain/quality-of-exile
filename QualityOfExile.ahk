#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2
#Include "MousePositionSaver.ahk"
#Include "ClipboardSaver.ahk"

; Initialize variables
global GameTitles := ["PathOfExile.exe", "PathOfExileSteam.exe"]
global CtrlToggled := false
global ShiftToggled := false
global ScrollSpam := false
global PoEMaxWidth := 3460
; GetWindowSize(WinTitle) {
;     WinGetPos(&x, &y, &width, &height, WinTitle)
    

; screenWidth := SysGet(78) ; 78 = SM_CXSCREEN (Primary monitor width)
;     screenHeight := SysGet(79) ; 79 = SM_CYSCREEN (Primary monitor height)
;     workAreaX := SysGet(48) ;48 = SM_XVIRTUALSCREEN
;     workAreaY := SysGet(49) ;49 = SM_YVIRTUALSCREEN
;     workAreaWidth := SysGet(76) ; // 76 is SM_CXVIRTUALSCREEN
;     workAreaHeight := SysGet(77) ; // 77 is SM_CYVIRTUALSCREEN

;     return {
;         x: x,
;         y: y,
;         width: width,
;         height: height,
;         screenWidth: screenWidth,
;         screenHeight: screenHeight,
;         workAreaX: workAreaX,
;         workAreaY: workAreaY,
;         workAreaWidth: workAreaWidth,
;         workAreaHeight: workAreaHeight
;     }
; }
GetGameInfo(WinTitles := GameTitles) {
    global GameTitle
    POE_HWND := 0

    for index, title in WinTitles {
        exe := "ahk_exe " title
        if (WinExist(exe)) {
            POE_HWND := WinWaitActive(exe)
            GameTitle := exe
            break
        }

        Sleep 1000
    }

    WinGetPos(&x, &y, &width, &height, POE_HWND)

    fullHD := width == 1920 and height == 1080

    centeredUI := false
    gameSizeX := width >= PoEMaxWidth ? PoEMaxWidth : width
    blackBarSize := width > PoEMaxWidth ? (width - PoEMaxWidth) / 2 : 0
    screenMiddleX := (blackBarSize * 2 + gameSizeX) / 2
    screenMiddleY := height / 2
    screenMiddleWithInventoryX := screenMiddleX - 450
    screenMiddleWithInventoryY :=screenMiddleY - 150
    overlayPosX := centeredUI ? blackBarSize + 1200 : blackBarSize + 600
    overlayPosY := height - 250
    divTradeAreaX := 1200
    divTradeAreaY := 600
    divTradeButtonX := divTradeAreaX
    divTradeButtonY := 955


    if (fullHD) {
        overlayPosX := 450
        overlayPosY := height - 200
        divTradeAreaX := 630
        divTradeAreaY := height - 630
        divTradeButtonX := divTradeAreaX
        divTradeButtonY := height - 340
        screenMiddleWithInventoryX := screenMiddleX - 325
        screenMiddleWithInventoryY := screenMiddleY - 75
    }

    return {
        HWND: POE_HWND,
        TITLE: GameTitle,
        GAME_X: gameSizeX,
        GAME_Y: height,
        SCREEN_MIDDLE_X: screenMiddleX,
        SCREEN_MIDDLE_Y: screenMiddleY,
        SCREEN_MIDDLE_WITH_INVENTORY_X: screenMiddleWithInventoryX,
        SCREEN_MIDDLE_WITH_INVENTORY_Y: screenMiddleWithInventoryY,
        BLACK_BAR_SIZE: blackBarSize,
        OVERLAY_X: overlayPosX,
        OVERLAY_Y: overlayPosY,
        OVERLAY_WIDTH: 200,
        OVERLAY_HEIGHT: 200,
        DIV_TRADE_AREA_X: divTradeAreaX,
        DIV_TRADE_AREA_Y: divTradeAreaY,
        DIV_TRADE_BUTTON_X: divTradeButtonX,
        DIV_TRADE_BUTTON_Y: divTradeButtonY,
        CENTER_UI: centeredUI,
    }
}

global GAME_INFO := GetGameInfo()


; while (GAME_INFO) {

; }
; if GAME_INFO {
;     MsgBox("Window Position: X=" GAME_INFO.GAME_X ", Y=" GAME_INFO.GAME_Y "`nWindow Size: Width=" GAME_INFO.GAME_X ", Height=" GAME_INFO.GAME_Y "`nScreen Size: Width=" GAME_INFO.SCREENWIDTH ", Height=" GAME_INFO.SCREENHEIGHT "`nWork Area: X=" GAME_INFO.WORKAREAX ", Y=" GAME_INFO.WORKAREAY ", Width=" GAME_INFO.WORKAREAWIDTH ", Height=" GAME_INFO.WORKAREAHEIGHT)
; }
; MainhWnd := WinExist("ahk_class Path of Exile")

; Max values officially supported
; 5120-3460
;PoEMaxWidth := 1920
;PoEWindowMaxY := 1080



; MsgBox(BlackBarsPaddingX)

global OverlayGui, CtrlLabel, ShiftLabel, SpamLabel

INS::KillSwitch()
KillSwitch() {
    ExitApp()
}



; hwndPoe := DllCall("GetForegroundWindow")
; MsgBox(WinGetTitle(hwndPoe) " " GetWindowSize(hwndPoe).width "x" GetWindowSize(hwndPoe).height)

; GAME_ACTIVE := false
; EVENT_SYSTEM_FOREGROUND := 0x0003
; WINEVENT_OUTOFCONTEXT := 0x0000

; global hHook := 0

; OnExit(UnhookEvent)

; SetHook() {
;     global hHook

;     callbackAddress := CallbackCreate(ForegroundChanged, "StdCall")
;     hHook := DllCall("SetWinEventHook", "uint", EVENT_SYSTEM_FOREGROUND, "uint", EVENT_SYSTEM_FOREGROUND, "ptr", 0, "ptr", callbackAddress, "uint", 0, "uint", 0, "uint", WINEVENT_OUTOFCONTEXT, "ptr")

;     if (!hHook) {
;         MsgBox("Failed to set event hook.")
;         ExitApp()
;     } else {
;         MsgBox("Event hook set successfully.")
;     }
; }

; ForegroundChanged(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
;     global GAME_ACTIVE
;     if (event = EVENT_SYSTEM_FOREGROUND) {
;         if (!GAME_ACTIVE and WinActive(hwndPoe)) {
;             GAME_ACTIVE := true
;         } else {
;             if (GAME_ACTIVE) {
;                 ResetToggle()
;                 GAME_ACTIVE := false
;             }
;         }
;     }
; }

; UnhookEvent(*) {
;     global hHook
;     if (hHook) {
;         DllCall("UnhookWinEvent", "ptr", hHook)
;         MsgBox("Event hook unhooked.")
;     }
; }


global mousePos := MousePositionSaver()
global clipboard := ClipboardSaver()
global INI_FILE := "data.ini"
global Hotkeys := Map()
global Extra := Map()
global Options := [{
    value: 0, field: "Checkbox", name: "Center UI", var: "CenterUI", tooltip: "TODO"
}]
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
global MouseDropdownOptions := ["", "MButton", "XButton1", "XButton2", "WheelDown", "WheelUp"]
; Load saved hotkeys
LoadHotkeys()
LoadShipmentValues()
ShowOverlay()

; SetHook() ;
Main() {
    global GAME_INFO

    HWND := WinWaitActive(GAME_INFO.HWND)
    
    if (HWND and WinWaitNotActive(GAME_INFO.HWND)) {
        ResetToggle()
        Main()
    }
}
Main()
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

    
    for data in Options {
        HotkeyGui.Add("Text", "x" x " y" y " w" w, data.name ":")
        control := HotkeyGui.Add(data.field, "v" data.var " x" x + 200 " y" y)
        control.Value := Hotkeys.Get(data.var, 0)
        control.Tooltip := data.tooltip
        y := y + 30
    }

    HotkeyGui.Add("Text", "w200", "Resolution: " GAME_INFO.GAME_X "x" GAME_INFO.GAME_Y)
    HotkeyGui.Add("Button", "Default", "Save And Reload").OnEvent("Click", (*) => SaveHotkeys(HotkeyGui))
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
    ; dont know how to call multiple functions within callback, passing the gui instead :clown_emoji:
    ShipmentGui.Add("Button", , "Close").OnEvent("Click", (*) => LoadShipmentValues(ShipmentGui))

    ShipmentGui.Show()
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

SaveShipmentValues(ShipmentGui) {
    global INI_FILE, ShipmentData
    controls := ShipmentGui.Submit()

     for data in ShipmentData {
        IniWrite(controls.%data.var%, INI_FILE, "Shipment", data.var)
    }
}

SaveHotkeys(HotkeyGui) {
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

    for data in Options {
        IniWrite(controls.%data.var%, INI_FILE, "Options", data.var)
    }

    ;MsgBox("Hotkeys Saved! Restarting script to apply changes.", "Success", "OK")
    Reload() ; Restart script to apply new hotkeys
}

LoadShipmentValues(ShipmentGui := 0) {
     global INI_FILE, ShipmentData

    if (ShipmentGui) {
        ShipmentGui.Destroy()
    }

    for data in ShipmentData {
        shipmentValue := IniRead(INI_FILE, "Shipment", data.var, 0)
        data.value := shipmentValue
    }
}

LoadHotkeys() {
    global INI_FILE, Hotkeys, HotkeyData, HotkeyCustomData, Options, GAME_INFO

    for data in HotkeyData {
        hotkeyValue := IniRead(INI_FILE, "Hotkeys", data.var, data.defaultHotkey)
        Hotkeys.Set(data.var, hotkeyValue)

        if (data.extraField) {
            extraValue := IniRead(INI_FILE, "Extra", data.var, "-\\w-.-|(-\\w){4}|(-\\w){5}|[gr]-[gr]-[gr]|nne|rint")
            Extra.Set(data.var, extraValue)
        }

        if (hotkeyValue != "") {
            HotIfWinActive(GAME_INFO.TITLE)
            Hotkey("*" hotkeyValue, data.func)
        }
    }


    for data in Options {
        value := IniRead(INI_FILE, "Options", data.var, 0)
        data.value := value

        if (data.var == "CenterUI" and value == 1) {
            GAME_INFO.CENTER_UI := value
            GAME_INFO.OVERLAY_X := GAME_INFO.BLACK_BAR_SIZE + 1200
        } else {
            GAME_INFO.CENTER_UI := value
            GAME_INFO.OVERLAY_X := GAME_INFO.BLACK_BAR_SIZE + 600
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

        HotIfWinActive(GAME_INFO.TITLE)
        if (hotkeyValue == 1) {
            if (data.var == "ToggleCtrl") {
                Hotkey("*Ctrl", data.func)
            }
            if (data.var == "ToggleShift") {
                Hotkey("*Shift", data.func)
            }
        }
        ;HotIfWinActive(GAME_INFO.TITLE)
        ;Hotkey("*>", ResetToggle)
    }

    if (Hotkeys["ToggleCtrl"] == 1 and Hotkeys["ToggleShift"] == 0) {
        HotIfWinActive(GAME_INFO.TITLE)
        Hotkey("*Shift", ResetToggle)
    }
    if (Hotkeys["ToggleCtrl"] == 0 and Hotkeys["ToggleShift"] == 1) {
        HotIfWinActive(GAME_INFO.TITLE)
        Hotkey("*Ctrl", ResetToggle)
    }

    if (Hotkeys["ToggleCtrl"] == 1 or Hotkeys["ToggleShift"] == 1) {
        HotIfWinActive(GAME_INFO.TITLE)
        Hotkey("*LWin", ResetToggleWin)
        HotIfWinActive(GAME_INFO.TITLE)
        Hotkey("*!Tab", ResetToggleAltTab)
        HotIfWinActive(GAME_INFO.TITLE)
        Hotkey("*Esc", ResetToggleEsc)
        ; HotIfWinActive(GAME_INFO.TITLE)
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
        CtrlLabel := OverlayGui.Add("Text", "x10 y10 w" GAME_INFO.OVERLAY_WIDTH / 2 " h30 vCtrlLabel", "Ctrl: OFF")
        CtrlLabel.SetFont("cWhite s12 w700 q4")
        ShiftLabel := OverlayGui.Add("Text", "x10 y40 w" GAME_INFO.OVERLAY_WIDTH / 2 " h30 vShiftLabel", "Shift: OFF")
        ShiftLabel.SetFont("cWhite s12 w700 q4")
        SpamLabel := OverlayGui.Add("Text", "x" GAME_INFO.OVERLAY_WIDTH / 2 " y10 w" GAME_INFO.OVERLAY_WIDTH / 2 " h30 vSpam")
        SpamLabel.SetFont("cRed s12 w700 q4")
        OverlayGui.Show("x" GAME_INFO.OVERLAY_X " y" GAME_INFO.OVERLAY_Y " w" GAME_INFO.OVERLAY_WIDTH " h" GAME_INFO.OVERLAY_HEIGHT " NoActivate")
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
    MouseMove(GAME_INFO.DIV_TRADE_BUTTON_X, GAME_INFO.DIV_TRADE_BUTTON_Y, 25)
    Sleep(Random(175, 225))
    Click("left")
    MouseMove(GAME_INFO.DIV_TRADE_AREA_X, GAME_INFO.DIV_TRADE_AREA_Y, 25)
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
    MouseMove(GAME_INFO.SCREEN_MIDDLE_WITH_INVENTORY_X, GAME_INFO.SCREEN_MIDDLE_WITH_INVENTORY_Y, 1)
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
    MouseMove(GAME_INFO.SCREEN_MIDDLE_WITH_INVENTORY_X, GAME_INFO.SCREEN_MIDDLE_WITH_INVENTORY_Y, 1)
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
    CurrencyTabX := GAME_INFO.BLACK_BAR_SIZE + 985
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