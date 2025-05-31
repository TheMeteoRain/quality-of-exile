#Requires AutoHotkey v2.0
; SingleInstance is handled manually
; 'Force' does not kill the previous instance when script is elavated to admin privileges
#SingleInstance Off
#MaxThreadsPerHotkey 2

FileEncoding("UTF-8")
SetTitleMatchMode("3")
#Include "globals.ahk"
#Include "log.ahk"
#Include "GameInfo.ahk"
#Include "ClipboardSaver.ahk"
#Include "MousePositionSaver.ahk"

KillOldRunningProcess() {
  mutexFile := Q_ProgramPathDir "\quality_of_exile.lock"

  if FileExist(mutexFile) {
    oldPID := Trim(FileRead(mutexFile), "`r`n ")
    ; Try to close the old process
    try ProcessClose(oldPID)
    WinWaitClose("ahk_pid " oldPID, "", 2000) ; Wait for the process to close
  }
  PID := DllCall("GetCurrentProcessId")
  ; Write our PID to the mutex file
  if FileExist(mutexFile) {
    FileDelete(mutexFile)
  }
  FileAppend(PID, mutexFile)
  ; Clean up the mutex file on exit
  OnExit((*) => FileDelete(mutexFile))
}

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
  if (!A_IsAdmin) {
    return
  }
  SplashGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Quality of Exile - Splash Screen")
  SplashGui.Add("Text", "Center", "Running Quality of Exile`nVersion: " VERSION)
  SplashGui.Show()
  LogInfo("################################### Starting Quality of Exile version: " VERSION)
  SetTimer(DestroySplashScreen, -2000)

  DestroySplashScreen() {
    if (IsSet(SplashGui)) {
      SplashGui.Destroy()
      SplashGui := unset
    }
  }
}

RestartAsAdmin() {
  if (!DEBUG) {
    full_command_line := DllCall("GetCommandLine", "str")
    if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
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

CheckAutoHotkeyVersion()
KillOldRunningProcess()
CleanLogFileIfTooBig()
SplashScreen()
RestartAsAdmin()

; https://www.autohotkey.com/docs/v2/misc/DPIScaling.htm#Workarounds
DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")

#Include "update.ahk"
#Include "main.ahk"