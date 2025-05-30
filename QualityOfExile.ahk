#Requires AutoHotkey v2.0
; SingleInstance is handled manually
; 'Force' does not kill the previous instance when script is elavated to admin privileges
#SingleInstance Off
#MaxThreadsPerHotkey 2

FileEncoding("UTF-8")
SetTitleMatchMode("3")
#Include "log.ahk"
#Include "GameInfo.ahk"
#Include "ClipboardSaver.ahk"
#Include "MousePositionSaver.ahk"

CheckAutoHotkeyVersion() {
  if (VerCompare(A_AhkVersion, AHK_VERSION_REQUIRED) == -1) {
    LogError(
      "You need AutoHotkey v" AHK_VERSION_REQUIRED " or later to run this script. `n`nPlease go to http://ahkscript.org/download and download a recent version.",
      true
    )
    ExitApp()
  }
}

CleanLogFileIfTooBig() {
  if (FileExist(Q_LogPath)) {
    fileSize := FileGetSize(Q_LogPath)
    if (fileSize > 536870912) { ; 512MB
      FileDelete(Q_LogPath)
      LogInfo("Log file was too big (" fileSize "), deleting it.")
    }
  }
}

SplashScreen() {
  SplashGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Quality of Exile - Splash Screen")
  SplashGui.Add("Text", "Center", "Running Quality of Exile`nVersion: " VERSION)
  SplashGui.Show()
  LogInfo("################################### Starting Quality of Exile version: " VERSION)
  Sleep(2000)
  SplashGui.Destroy()
  SplashGui := unset
}

CheckAutoHotkeyVersion()
CleanLogFileIfTooBig()
SplashScreen()

; https://www.autohotkey.com/docs/v2/misc/DPIScaling.htm#Workarounds
DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")

#Include "update.ahk"
#Include "main.ahk"