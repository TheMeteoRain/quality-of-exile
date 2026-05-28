#Requires AutoHotkey v2.0

; Manual single-instance: #SingleInstance Force doesn't survive UAC elevation
; (RestartAsAdmin re-runs us as a different process), so we keep a PID file.
KillOldRunningProcess() {
  mutexFile := DATA_DIR "\quality_of_exile.lock"

  if FileExist(mutexFile) {
    oldPID := Trim(FileRead(mutexFile), "`r`n ")
    try ProcessClose(oldPID)
    WinWaitClose("ahk_pid " oldPID, "", 2000)
  }

  PID := DllCall("GetCurrentProcessId")
  if FileExist(mutexFile) {
    FileDelete(mutexFile)
  }
  FileAppend(PID, mutexFile)
  OnExit((*) => FileDelete(mutexFile))
}

CheckAutoHotkeyVersion() {
  if (VerCompare(A_AhkVersion, AHK_VERSION_REQUIRED) == -1) {
    Log.Error(
      "You need AutoHotkey v" AHK_VERSION_REQUIRED " or later to run this script. `n`nPlease go to http://ahkscript.org/download and download a recent version.",
      true
    )
    ExitApp()
  }
}

CleanLogFileIfTooBig() {
  if (FileExist(LOG_PATH)) {
    fileSize := FileGetSize(LOG_PATH)
    if (fileSize > 536870912) {  ; 512 MB
      FileDelete(LOG_PATH)
      Log.Info("Log file was too big (" fileSize "), deleting it.")
    }
  }
}

; Only shown post-elevation so the user doesn't see two splashes.
SplashScreen() {
  if (!A_IsAdmin) {
    return
  }
  SplashGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Quality of Exile - Splash Screen")
  SplashGui.BackColor := MAIN_COLOR
  SplashGui.Add("Text", "Center cWhite", "Running Quality of Exile`nVersion: " VERSION)
  SplashGui.Show()
  Log.Info("################################### Starting Quality of Exile version: " VERSION)
  SetTimer(DestroySplashScreen, -2000)

  DestroySplashScreen() {
    if (IsSet(SplashGui)) {
      SplashGui.Destroy()
      SplashGui := unset
    }
  }
}

; AHK requires to run scripts that require elevated permissions.
; /restart with elevated privileges.
; guard prevents an infinite loop if the user denies UAC.
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
