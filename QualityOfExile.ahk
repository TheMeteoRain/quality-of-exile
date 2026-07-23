#Requires AutoHotkey v2.0
#SingleInstance Off   ; handled manually in src/lib/boot.ahk
#MaxThreadsPerHotkey 2

FileEncoding("UTF-8")
SetTitleMatchMode("3")

; ---- Bootstrap ----
#Include "version.ahk"
#Include "src/constants.ahk"
#Include "src/lib/log.ahk"
#Include "src/lib/boot.ahk"

CheckAutoHotkeyVersion()
KillOldRunningProcess()
CleanLogFileIfTooBig()
SplashScreen()
RestartAsAdmin()

; https://www.autohotkey.com/docs/v2/misc/DPIScaling.htm#Workarounds
DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")

; ---- Singletons (class + global instance) ----
#Include "src/game.ahk"
#Include "src/lib/clipboard.ahk"
#Include "src/lib/mouse.ahk"

; ---- Lib ----
#Include "src/lib/helpers.ahk"
#Include "src/lib/storage.ahk"

; ---- Cross-game actions ----
#Include "src/games/shared/ClickSpam.ahk"
#Include "src/games/shared/Leaderboard.ahk"

; ---- Path of Exile ----
#Include "src/games/poe/ChatCommand.ahk"
#Include "src/games/poe/ClientLog.ahk"
#Include "src/games/poe/CraftCurrency.ahk"
#Include "src/games/poe/Divination.ahk"
#Include "src/games/poe/DropItem.ahk"
#Include "src/games/poe/Logout.ahk"
#Include "src/games/poe/RegexpShop.ahk"
#Include "src/games/poe/Shipments.ahk"
#Include "src/games/poe/WeaponDPS.ahk"
#Include "src/games/poe/CalculateWeaponDPS.ahk"

; ---- Last Epoch ----
#Include "src/games/lastepoch/Shatter.ahk"
#Include "src/games/lastepoch/TransferMaterials.ahk"

; ---- Hotkeys + on-screen UI ----
#Include "src/hotkeys/modifiers.ahk"
#Include "src/hotkeys/keybinds.ahk"
#Include "src/hud.ahk"
#Include "src/overlay.ahk"

; ---- Settings GUI ----
#Include "src/settings.ahk"

; ---- Config ----
#Include "src/config/factories.ahk"
#Include "src/config/configs.ahk"

; ---- Update + main ----
#Include "update.ahk"
#Include "src/app.ahk"