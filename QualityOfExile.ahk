#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2
#Include "MousePositionSaver.ahk"
#Include "ClipboardSaver.ahk"
#Include "GameInfo.ahk"

SetTitleMatchMode("3")
ScriptVersion := "0.1.0-beta.9"
GithubLink := "https://github.com/TheMeteoRain/quality-of-exile"
DEBUG := false
; https://www.autohotkey.com/docs/v2/misc/DPIScaling.htm#Workarounds
DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")

if (A_Args.Length > 0) {
    ; debug
    if (RegExMatch(A_Args[1], "DEBUG=(true|false)", &match)) {
        DEBUG := (match[1] = "true")
    }
}

DocumentPath := A_MyDocuments "\QualityOfExile"
ErrorPath := A_MyDocuments "\QualityOfExile\error.txt"
cportsPath := DocumentPath . "\cports"
cportsExecutable := cportsPath . "\cports.exe" ; Check in the script's directory
cportsDownloadURL := "https://www.nirsoft.net/utils/cports.zip" ; URL to the ZIP file
cportsZipPath := DocumentPath . "\cports.zip"
INI_FILE := DocumentPath "\data.ini"
STATE_FILE := DocumentPath "\state.ini"

; Initialize variables
global LastExecutionTime := {
    TerminateTCP: 0,
    CraftWithCurrency: 0,
    PerformDivinationTrading: 0,
    DropItem: 0,
    OpenStackedDivinationDeck: 0,
}
global CtrlToggled := false
global ShiftToggled := false
global ScrollSpam := false
global OverlayGui, CtrlLabel, ShiftLabel, SpamLabel, HotkeyGui, HUDGui
global clientFilePath, clientFile, clientFileReadFunc
global DynamicHotkeysActivated := false
global DynamicHotkeysState := "OFF"
global RegExpCharacterLimit := 48
global Game := GameInfo()
global mousePos := MousePositionSaver()
global clipboard := ClipboardSaver()
global Hotkeys := Map()
global Extra := Map()
global Options :=  Map()
global MouseDropdownOptions := ["", "MButton", "XButton1", "XButton2"]
global Configs := {
    EnterHideout: {
        name: "Enter Hideout",
        var: "OpenHideout",
        defaultHotkey: "F5",
        func: OpenHideout,
        blockKeyNativeFunction: true,
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
        blockKeyNativeFunction: true,
        mouseBind: false,
        tooltip: "How to use: press hotkey to enter Kingsmarch.",
        toggleOnInstance: false,
        tab: "Tab1",
        section: "Hotkey",
        coords: { x: 175, y: 0 }
    },
    OpenStackedDivinationDeck: {
        name: "Open Stacked Divination Deck",
        defaultHotkey: "",
        func: OpenStackedDivinationDeck,
        blockKeyNativeFunction: true,
        mouseBind: true,
        tooltip: "How to use: hover over the desired divination stack in your inventory and press this hotkey. Only usable in outdoor areas, since you cannot drop cards in hideout or similar areas.",
        toggleOnInstance: false,
        tab: "Tab3",
        section: "Hotkey",
        coords: { x: 175, y: 0 }
    },
    TradeDivinationCard: {
        name: "Trade Divination Card",
        defaultHotkey: "",
        func: PerformDivinationTrading,
        blockKeyNativeFunction: true,
        extraField: true,
        mouseBind: false,
        tooltip: "How to use: open divination card trade screen and press this hotkey, while hovering over the desired full divination card stack in your inventory.",
        toggleOnInstance: false,
        tab: "Tab3",
        section: "Hotkey",
        coords: { x: 350, y: 0 },
        pixelSelect: true,
        vars: ["TradeDivinationCardButton", "TradeDivinationCardItemArea"]
    },
    DropItem: {
        name: "Drop Item From Inventory",
        defaultHotkey: "",
        func: DropItem,
        mouseBind: true,
        blockKeyNativeFunction: true,
        tooltip: "How to use: hover over item in your inventory and press this hotkey.",
        toggleOnInstance: false,
        tab: "Tab3",
        section: "Hotkey",
        coords: { x: 0, y: 0 }
    },
    FillShipment: {
        name: "Fill Shipments",
        var: "FillShipment",
        defaultHotkey: "",
        func: FillShipments,
        blockKeyNativeFunction: true,
        mouseBind: true,
        tooltip: "TODO",
        toggleOnInstance: false,
        tab: "Tab3",
        section: "Hotkey",
        coords: { x: 0, y: 90 }
    },
    HighlightShopItems: {
        name: "Enter RegExp",
        defaultHotkey: "",
        func: HighlightShopItems,
        blockKeyNativeFunction: true,
        extraField: true,
        mouseBind: true,
        tooltip: "TODO",
        toggleOnInstance: false,
        tab: "Tab3",
        section: "Hotkey",
        coords: { x: 175, y: 90 }
    },
    OrbOfTransmutation: {
        name: "Orb of Transmutation (D)",
        defaultHotkey: "",
        func: OrbOfTransmutation,
        blockKeyNativeFunction: true,
        extraField: true,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: true,
        tab: "Tab2",
        section: "Hotkey",
        coords: { x: 0, y: 0 },
        pixelSelect: true
    },
    OrbOfAlteration: {
        name: "Orb of Alteration (D)",
        defaultHotkey: "",
        func: OrbOfAlteration,
        blockKeyNativeFunction: true,
        extraField: true,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: true,
        tab: "Tab2",
        section: "Hotkey",
        coords: { x: 175, y: 0 },
        pixelSelect: true
    },
    OrbOfChance: {
        name: "Orb of Chance (D)",
        defaultHotkey: "",
        func: CraftOrbOfChance,
        blockKeyNativeFunction: true,
        extraField: true,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: true,
        tab: "Tab2",
        section: "Hotkey",
        coords: { x: 350, y: 0 },
        pixelSelect: true
    },
    AlchemyOrb: {
        name: "Alchemy Orb (D)",
        defaultHotkey: "",
        func: CraftAlchemyOrb,
        blockKeyNativeFunction: true,
        extraField: true,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: true,
        tab: "Tab2",
        section: "Hotkey",
        coords: { x: 0, y: 120 },
        pixelSelect: true
    },
    OrbOfScouring: {
        name: "Orb of Scouring (D)",
        defaultHotkey: "",
        func: CraftOrbOfScouring,
        blockKeyNativeFunction: true,
        extraField: true,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: true,
        tab: "Tab2",
        section: "Hotkey",
        coords: { x: 175, y: 120 },
        pixelSelect: true
    },
    ChaosOrb: {
        name: "Chaos Orb (D)",
        defaultHotkey: "",
        func: ChaosOrb,
        extraField: true,
        blockKeyNativeFunction: true,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: true,
        tab: "Tab2",
        section: "Hotkey",
        coords: { x: 350, y: 120 },
        pixelSelect: true
    },
    KillSwitch: {
        name: "Kill Switch",
        defaultHotkey: "Home",
        func: KillSwitch,
        blockKeyNativeFunction: true,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: false,
        tab: "Tab1",
        section: "Hotkey",
        coords: { x: 175, y: 60 }
    },
    Settings: {
        name: "Settings (This GUI)",
        defaultHotkey: "F10",
        func: Settings,
        blockKeyNativeFunction: true,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: false,
        tab: "Tab1",
        section: "Hotkey",
        coords: { x: 0, y: 60 }
    },
    ToggleCtrlKeybind: {
        name: "Toggle CTRL Hotkey",
        defaultHotkey: "",
        func: ToggleCtrl,
        blockKeyNativeFunction: true,
        mouseBind: true,
        tooltip: "TODO",
        toggleOnInstance: false,
        tab: "Tab1",
        section: "Hotkey",
        coords: { x: 175, y: 240 }
    },
    ToggleShiftKeybind: {
        name: "Toggle SHIFT Hotkey",
        defaultHotkey: "",
        func: ToggleShift,
        blockKeyNativeFunction: true,
        mouseBind: true,
        tooltip: "TODO",
        toggleOnInstance: false,
        tab: "Tab1",
        section: "Hotkey",
        coords: { x: 350, y: 240 }
    },
    CtrlClickSpamToggle: {
        name: "Spam Ctrl Click",
        defaultHotkey: "",
        func: CtrlClickSpamToggle,
        blockKeyNativeFunction: true,
        mouseBind: true,
        tooltip: "TODO",
        toggleOnInstance: false,
        coords: { x: 0, y: 240 },
        tab: "Tab1",
        section: "Hotkey"
    },
    ForceLogout: {
        name: "Force Logout",
        defaultHotkey: "",
        func: TerminateTCP,
        blockKeyNativeFunction: true,
        mouseBind: false,
        tooltip: "TODO",
        toggleOnInstance: false,
        tab: "Tab1",
        section: "Hotkey",
        coords: { x: 350, y: 0 }
    },
    ToggleCtrl: {
        name: "Toggle CTRL",
        defaultValue: 0, 
        func: ToggleCtrl, 
        tooltip: "TODO", 
        section: "Toggle", 
        tab: "Tab1", 
        toggleOnInstance: false, 
        coords: { x: 175, y: 150 }
    },
    ToggleShift: {
        name: "Toggle SHIFT",
        defaultValue: 0,
        func: ToggleShift,
        tooltip: "TODO",
        section: "Toggle",
        tab: "Tab1",
        toggleOnInstance: false,
        coords: { x: 350, y: 150 }
    },
    ToggleOverlayPosition: {
        field: "SelectPixel",
        name: "Toggle Overlay Position",
        tooltip: "TODO",
        section: "Options",
        tab: "Tab1",
        toggleOnInstance: false,
        pixelSelect: true,
        coords: { x: 0, y: 150 }
    },
}

Initialize() {
    if (!FileExist(DocumentPath)) {
        DirCreate(DocumentPath)
    }
    
    If !FileExist(cportsExecutable) {
        ; Download cports
        try {
            Download(cportsDownloadURL, cportsZipPath)
        } catch Error as e {
            LogError("Failed to download CurrPorts. Please check your internet connection and try again.", e, true)
        }
    
        ; Wait for download
        timeout := 30000
        startTime := A_TickCount
        loop 30 {
            if FileExist(cportsZipPath) && FileGetSize(cportsZipPath) > 0 {
                break
            }
            if (A_TickCount - startTime > timeout) {
                LogError("Downloading CurrPorts timedout. Please check your internet connection or try again later.", e, true)
                ExitApp()
            }
            Sleep(1000)
        }
    
        ; Create dir
        DirCreate(cportsPath)
        if (!FileExist(cportsPath)) {
            MsgBox("Something went wrong")
            LogError("Could not create dir for cports", e)
            ExitApp()
        }
    
        ; Extract zip
        tarCommand := Format("tar -xf {} -C {}", cportsZipPath, cportsPath)
        RunWait(A_ComSpec . " /c " . tarCommand, "", "Hide")
        FileDelete(cportsZipPath)
    
        if !FileExist(cportsExecutable) {
            MsgBox("Error downloading or extracting CurrPorts. Please ensure you have internet access and try again.")
            ExitApp()
        }
    }

    if (!DEBUG) {
        full_command_line := DllCall("GetCommandLine", "str")
        if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
        {
            try {
                if A_IsCompiled
                    Run '*RunAs "' A_ScriptFullPath '" /restart'
                else
                    Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
            }
            ExitApp
        }
    }
}

LoadState() {
    global DynamicHotkeysActivated, DynamicHotkeysState

    if (FileExist(STATE_FILE)) {
        DynamicHotkeysActivated := IniRead(STATE_FILE, "STATE", "DynamicHotkeysActivated", 0)
        DynamicHotkeysState := IniRead(STATE_FILE, "STATE", "DynamicHotkeysState", "Off")
        FileDelete(STATE_FILE)
    }
}

KillSwitch(*) {
    ExitApp()
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
    
    tempFile := cportsPath "\temp.txt"

    try {
        loop 5 {
            cportsCommand := Format("{} /close * * * * {}", cportsExecutable, Game.PID)
            Run(A_ComSpec . " /c " . cportsCommand, "", "Hide")
        }

        cportsCommand := Format("{} /filter include:process:{} /stext {}", cportsExecutable, Game.PID, tempFile)
        Run(A_ComSpec . " /c " . cportsCommand, "", "Hide")

        found := false
        Loop 200 {
            if (FileExist(tempFile)) {
                found := true
                break
            }
            Sleep(10)
        }

        if (found) {
            if (FileGetSize(tempFile) > 0) {
                ; if log file has content it, then the tcp connection is still alive, close the game
                ProcessClose(Game.PID)
                MsgBox("Could not terminate TCP connections with cports. Closing game to be safe. This should not happen. Send an issue in: " GithubLink)
            }
        } else {
            ; if log file is not found then the cports commands did not work, close the game
            ProcessClose(Game.PID)
            MsgBox("Could not terminate TCP connections with cports. Closing game to be safe. This should not happen. Send an issue in: " GithubLink)
        }
    } catch Error as e {
        ; close the game if something goes wrong
        ProcessClose(Game.PID)
        LogError("Something went wrong when trying to close TCP connections. Closing game to be safe. This should not happen. Send an issue in: " GithubLink, e)
    } finally {
        Loop 20 {
            if (FileExist(tempFile)) {
                FileDelete(tempFile)
            }
            Sleep(100)
        }
    }
}

LogError(msg, e, showMsgBox := false) {
    if (showMsgBox) {
        MsgBox(msg)
    }
    FileAppend("An error occurred while running the script:`n`n"
    . "Time: " A_NowUTC "`n"
    . "Message: " msg "`n"
    . "Error: " e.what "`n"
    . "Details: " e.message "`n"
    . "File: " e.file "`n"
    . "Line: " e.line "`n"
    . (e.extra ? "Additional Info: " e.extra "`n" : ""), ErrorPath, "UTF-16")
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
    TabControl := HotkeyGui.Add("Tab3", "", ["Tab1","Tab2","Tab3"])
    
    TabControl.UseTab("Tab1")
    textCtrl := HotkeyGui.Add("Text", Format("x{} y{} w500", pX, pY), "(K): Keyboard keybind | (M): Mouse keybind | (Px): Pixel | (D): Dynamic Hotkey")
    textCtrl.SetFont("w700")

    TabControl.UseTab("Tab2")
    textCtrl := HotkeyGui.Add("Text", Format("x{} y{} w500", pX, pY), "(K): Keyboard keybind | (M): Mouse keybind | (Px): Pixel | (D): Dynamic Hotkey")
    textCtrl.SetFont("w700")

    TabControl.UseTab("Tab3")
    textCtrl := HotkeyGui.Add("Text", Format("x{} y{} w500", pX, pY), "(K): Keyboard keybind | (M): Mouse keybind | (Px): Pixel | (D): Dynamic Hotkey")
    textCtrl.SetFont("w700")


    pixelSearchCtrls(conf, key, options, x1, y1, x2, y2) {
        HotkeyGui.Add("Text", Format("x{} y{} w{}", x1, y1+4, w), "Px")
        pixelTextCtrl := HotkeyGui.Add("Edit", Format("v{}Pixel x{} y{} w{} +Center {}", key, x1+20, y1, w-10, options), Extra.Get(key, ""))
        if (key == "ToggleOverlayPosition" and !pixelTextCtrl.Value) {
            pixelTextCtrl.Value := Format("{}x{}", Game.OverlayPosX, Game.OverlayPosY)
        } 
        pixelTextCtrl.OnEvent("Change", ValidatePixel.Bind(pixelTextCtrl.Value))
        pixelButtonCtrl := HotkeyGui.Add("Button", Format("v{}PixelSelect x{} y{} w{}", key, x2+20, y2, w-10), "Select Pixel")
        pixelButtonCtrl.OnEvent("Click", SelectPixel.Bind(pixelButtonCtrl, pixelTextCtrl, conf))

        return { text: pixelTextCtrl, button: pixelButtonCtrl }
    }

    for key, config in Configs.OwnProps() {
        TabControl.UseTab(config.tab)
        x := config.coords.x + pX
        y := config.coords.y + pY + rowSize

        textGuiControl := HotkeyGui.Add("Text", Format("x{} y{} w{}", x, y, w), config.name)
        textGuiControl.SetFont("bold")
        if (config.section == "Hotkey") {
            keyboardLabel := HotkeyGui.Add("Text", Format("x{} y{} Center", x, y+rowSize+3-gap), "K")
            mainGuiControl := HotkeyGui.Add("Hotkey", Format("v{} x{} y{} w{}", key, x+10, y+rowSize-gap, w), Hotkeys.Get(key, ""))
            hotkeyValue := Hotkeys.Get(key, "")
            mainGuiControl.Value := hotkeyValue
            y := y+rowSize*2
            ; if (key == "KillSwitch" or key == "Settings") {
            ;     mainGuiControl.
            ; }


            if (config.HasProp("mouseBind") and config.mouseBind) {
                mouseLabel := HotkeyGui.Add("Text", Format("x{} y{} Center", x, y+3-gap), "M")
                guiDropdown := HotkeyGui.Add("DropDownList", Format("v{} x{} y{} w{}", key "_mouseDropdownOptions", x+10, y-gap, w), MouseDropdownOptions)
                guiDropdown.OnEvent("Change", onChangeDropdownToHotkey.Bind(mainGuiControl))
                mainGuiControl.OnEvent("Change", onChangeHotkeyToDropdown.Bind(guiDropdown))

                hotkeyValue := Hotkeys.Get(key, "")
                if (hotkeyValue != "" and index := hasKey(MouseDropdownOptions, hotkeyValue)) {
                    guiDropdown.Value := index
                } else {
                    mainGuiControl.Value := hotkeyValue
                }
                y := y+rowSize
            }

            if (config.HasProp("pixelSelect") and config.pixelSelect) {
                if (config.HasProp("vars") and config.vars.Length > 0) {
                    for index, var in config.vars {
                        newY := index > 1 ? y+rowSize*index : y
                        pixelSearchCtrls(config, var, "Readonly", x, newY-gap, x, newY+rowSize-gap)
                    }
                } else {
                    pixelSearchCtrls(config, key, "Readonly", x, y-gap, x, y+rowSize-gap)
                }
                y := y+rowSize
            }

            if (key == "HighlightShopItems") {
                regexp := Extra.Get(key, "")
                characterLimitText := HotkeyGui.Add("Text", Format("x{} y{}", x+10, y+rowSize*2-gap), Format("{} / {}`ndon't include quotation marks", StrLen(regexp), RegExpCharacterLimit))
                extraGuiControl := HotkeyGui.Add("Edit", Format("v{}_extra x{} y{} w{} Limit{} -VScroll h60", key, x+10, y-gap, w, RegExpCharacterLimit), regexp)
                extraGuiControl.OnEvent("Change", UpdateCharacterLimit.Bind(characterLimitText))
            }

            if (key == "FillShipment") {
                control := HotkeyGui.Add("Button", Format("v{}_extra x{} y{} w{}", key, x+10, y-gap, w), "Shipment values")
                control.OnEvent("Click", openSettlersShipmentUI)
            }
        }

        if (config.section == "Options" or config.section == "Toggle") {
            if (key == "ToggleOverlayPosition") {
                pixelSearchCtrls(config, key, "", x, y+rowSize-gap, x, y+rowSize*2-gap)
            } else {
                HotkeyGui.Add("Text", Format("x{} y{} w{}", x, y+rowSize+4-gap, w), "Enabled")
                control := HotkeyGui.Add("Checkbox", Format("v{} x{} y{}", key, x+45, y+4+rowSize-gap))
                control.Value := Hotkeys.Get(key, 0)
                control.Tooltip := config.tooltip
            }
        }

        maxY := Max(y, maxY)
    }

    TabControl.UseTab("")

    HotkeyGui.Add("Text", Format("x{} y{} w{} Center", 0, maxY, 200), "QualityOfExile version:`n" ScriptVersion)
    HotkeyGui.Add("Link", Format("x{} y{} w{}", pX*2, maxY + 35, w), Format('<a href="{}">Github / Documentation</a>', GithubLink))

    HotkeyGui.Add("Button", Format("x{} y{} w{} Default", 550/2-200/2, maxY, 200), "Save And Reload").OnEvent("Click", SaveConfigurations)
    HotkeyGui.Add("Button", Format("x{} y{} w{}", 550/2-200/2, maxY + rowSize, 200), "Close").OnEvent("Click", CloseConfigurations)

    maxY := Max(maxY + rowSize*2, maxY)
    ;OnMessage(0x0200, On_WM_MOUSEMOVE)

    HotkeyGui.Show(Format("x{} y{} w{} h{}", Game.GameWindowCenterX-550/2, Game.GameWindowCenterY-475/2, 550, 475))
    ControlFocus(HotkeyGui, HotkeyGui.Title)
}

ShowSettings(*) {
    HotkeyGui.Show(Format("x{} y{} w{} h{}", Game.GameWindowCenterX-550/2, Game.GameWindowCenterY-550/2, 550, 550))
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

UpdateCharacterLimit(LimitControl, RegExpControl, *) {
    ControlSetText(Format("{} / {}`ndon't include quotation marks", StrLen(RegExpControl.Value), RegExpCharacterLimit), LimitControl)
}

CloseConfigurations(*) {
    global Game
    HotkeyGui.Hide()
    Game.FocusGameWindow()
}

SaveConfigurations(*) {
    global Hotkeys, Options, Extra, Configs, DynamicHotkeysActivated, DynamicHotkeysState
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
                    parsedValues.Push([var, controls.%var "Pixel"%])
                }
            } else {
                parsedValues.Push([key, controls.%key "Pixel"%])
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

    IniWrite(DynamicHotkeysActivated, STATE_FILE, "STATE", "DynamicHotkeysActivated")
    IniWrite(DynamicHotkeysState, STATE_FILE, "STATE", "DynamicHotkeysState")
    Reload()
    Game.FocusGameWindow()
}

LoadConfigurations() {
    global Hotkeys, Options, Game, Configs

    try {
        for key, config in Configs.OwnProps() {
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
                    HotIf()
                    Hotkey("*" val, config.func)
                } else {
                    HotIfWinActive(Game.Title)
                    if (config.toggleOnInstance) {
                        ; dynamic hotkeys
                        Hotkey("*" val, config.func)
                    } else if (config.blockKeyNativeFunction) {
                        Hotkey("*" val, config.func)
                    } else {
                        Hotkey("~" val, config.func)
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
        LogError("Could not load configurations." e, true)
        KillSwitch()
    }
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
    ToolTip("`nSelect pixel for: " name "`nCurrent Mouse Position: X = " SelectedX ", Y = " SelectedY "`nClick to confirm.`nEsc to cancel.")
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
    global OverlayGui, CtrlLabel, ShiftLabel, SpamLabel

    if (IsSet(OverlayGui)) {
        return
    }

    if (Hotkeys["ToggleCtrl"] or Hotkeys["ToggleShift"] or Hotkeys["CtrlClickSpamToggle"] or Hotkeys["ToggleCtrlKeybind"] or Hotkeys["ToggleShiftKeybind"]) {
        OverlayGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x20")
        OverlayGui.Title := "Toggle Overlay"
        OverlayGui.BackColor := "Black"
        WinSetTransColor(OverlayGui.BackColor " 150", OverlayGui)
        CtrlLabel := OverlayGui.Add("Text", "x10 y10 w" Game.OverlayWidth / 2 " h30 vCtrlLabel", "Ctrl: OFF")
        CtrlLabel.SetFont("cWhite s12 w700 q2")
        ShiftLabel := OverlayGui.Add("Text", "x10 y40 w" Game.OverlayWidth / 2 " h30 vShiftLabel", "Shift: OFF")
        ShiftLabel.SetFont("cWhite s12 w700 q2")
        SpamLabel := OverlayGui.Add("Text", "x" Game.OverlayWidth / 2 " y10 w" Game.OverlayWidth / 2 " h30 vSpam")
        SpamLabel.SetFont("cRed s12 w700 q2")
    }
}
ShowToggleOverlay() {
    global OverlayGui, Extra
    
    if (IsSet(OverlayGui)) {
        val := Extra.Get("ToggleOverlayPosition", Format("{}x{}", Game.OverlayPosX, Game.OverlayPosY))
        resolution := ParseResolution(val)
        if (!resolution) {
            MsgBox("Invalid resolution for toggle overlay position. Please set a valid resolution in the format 'widthxheight' (e.g., 1920x1080).")
            return
        }

        OverlayGui.Show("x" resolution.width " y" resolution.height " w" Game.OverlayWidth " h" Game.OverlayHeight " NoActivate")
    }
}
HideToggleOverlay() {
    global OverlayGui

    if (IsSet(OverlayGui)) {
        OverlayGui.Hide()
    }
}

ResetToggle(*) {
    global Hotkeys

    if (Hotkeys["ToggleCtrl"] or Hotkeys["ToggleShift"] or Hotkeys["CtrlClickSpamToggle"] or Hotkeys["ToggleCtrlKeybind"] or Hotkeys["ToggleShiftKeybind"]) {
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

StartCtrlClickSpam() {
    global ScrollSpam, SpamLabel

    ScrollSpam := true
    SpamLabel.Text := "SPAM!"

    ShiftUp()
    CtrlDown()
    SetTimer(ClickSpam, Random(30, 50))
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
    if (Debounce("PerformDivinationTrading", rand1+rand2)) {
        return
    }

    buttonPixelKey := "TradeDivinationCardButton"
    areaPixelKey := "TradeDivinationCardItemArea"

    if (!Extra.Has(buttonPixelKey) or !Extra.Get(buttonPixelKey)) {
        MsgBox("Set pixel for divination trade button. Use the Pixel Search button in settings (" Hotkeys["Settings"] ").")
        return
    }

    if (!Extra.Has(areaPixelKey) or !Extra.Get(areaPixelKey)) {
        MsgBox("Set pixel for divination item area. Use the Pixel Search button in settings (" Hotkeys["Settings"] ").")
        return
    }

    buttonResolution := ParseResolution(Extra[buttonPixelKey])
    areaResolution := ParseResolution(Extra[areaPixelKey])
    if (!buttonResolution) {
        MsgBox("Invalid resolution for divination trade button. Please set a valid resolution in the format 'widthxheight' (e.g., 1920x1080).")
        return
    }
    if (!areaResolution) {
        MsgBox("Invalid resolution for divination item area. Please set a valid resolution in the format 'widthxheight' (e.g., 1920x1080).")
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
        MoveMouse(Game.ScreenMiddleWithInventoryX, Game.ScreenMiddleWithInventoryY)
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
        MoveMouse(Game.ScreenMiddleWithInventoryX, Game.ScreenMiddleWithInventoryY)
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

OpenCurrencyTab() {
    global mousePos
    mousePos.SavePosition()
    CurrencyTabX := Game.BlackBarSize + 985
    CurrencyTabY := 160
    MoveMouse(CurrencyTabX, CurrencyTabY)
    Sleep(200)
    Click("left")
    mousePos.RestorePosition()
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
        MsgBox("Invalid resolution for " name ". Please set a valid resolution in the format 'widthxheight' (e.g., 1920x1080).")
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
        MoveMouse(resolution.width, resolution.height)
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

MoveMouse(x, y) {
    DllCall("SetCursorPos", "int", x, "int", y)
}

SaveToggleState() {
    global CtrlToggled, ShiftToggled
    return {ctrl: CtrlToggled, shift: ShiftToggled}
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

    ShipmentGui.Add("Button", "Default", "Save Shipment Values").OnEvent("Click", (*) => SaveShipmentValues(ShipmentGui))
    ShipmentGui.Add("Button", , "Close").OnEvent("Click", (*) => ShipmentGui.Destroy())

    ShipmentGui.Show()
}

Initialize()
Game.AttachToGame()
LoadConfigurations()
LoadShipmentValues()
LoadState()
CreateToggleOverlay()
CreateHUD()

; Client.txt file behaves odd but for our advantage
; Client.txt file does not 
DynamicHotkeys() {
    global clientFilePath, DynamicHotkeysActivated, DynamicHotkeysState

    FileModificationTime := FileGetTime(clientFilePath, "M")

    LastModified := DateDiff(A_Now, FileModificationTime, "Seconds")
    HotIfWinActive(Game.Title)

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

Main() {
    global Game, clientFilePath, DynamicHotkeysActivated

    Game.AttachToGame()
    GetPoEClientFilePath()
    ListenToClientFile()
    DynamicHotkeys()
    ShowToggleOverlay()
    ShowHUD()
    SetTimer(Wrapper, 5000)
    

    if (Game.GameClientNotActive()) {
        HideToggleOverlay()
        HideHUD()
        ResetToggle()
        SetTimer(Wrapper, 0)

        if (!Game.GameClientExists()) {
            UnlistenClientFile()
            SetDynamicHotkeysState("Off")
        }

        Main()
    }
}
Wrapper(*) {
    Game.CalculatePixels()
    ShowToggleOverlay()
    ShowHUD()
}

Main()

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
    if (RegExMatch(line, "Generating level \d+ area `"\d+_\d+(?:_.*)?_town|.*Hideout.*|KalguuranSettlersLeague`"")){
        return true
    }
    return false
}
SetDynamicHotkeysState(state := "Off", setState := true) {
    global Configs, Hotkeys, DynamicHotkeysActivated, DynamicHotkeysState

    for key, config in Configs.OwnProps() {
        if (config.toggleOnInstance and Hotkeys[key]) {
            Hotkey("*" Hotkeys[key], config.func, state)
        }
    }
    if (setState) {
        DynamicHotkeysActivated := true
        DynamicHotkeysState := state
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