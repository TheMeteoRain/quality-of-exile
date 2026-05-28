#Requires AutoHotkey v2.0

CreateProgramPathDir() {
  if (!DirExist(DATA_DIR)) {
    DirCreate(DATA_DIR)
  }
}

DestroyGui(GuiCtrl, *) {
  if (IsSet(GuiCtrl)) {
    GuiCtrl.gui.Destroy()
  }
}

GetNewerReleaseBodies(json, currentVersion) {
  bodies := "No changelog available."

  try {
    pos := 1
    while RegExMatch(
      json, '"tag_name"\s*:\s*"v([^"]+)"[\s\S]+?"body"\s*:\s*"((?:[^"\\]|\\.)*)"',
      &m,
      pos
    ) {
      version := m[1]
      body := m[2]
      pos := m.Pos(0) + m.Len(0)

      if (VerCompare(version, currentVersion) == 1) {
        body := StrReplace(body, '\r\n', "`n")
        body := StrReplace(body, '\n', "`n")
        body := StrReplace(body, '\"', '"')

        if (A_Index == 1) {
          bodies := body
        } else {
          bodies := bodies "`n`n`n" body
        }
      } else {
        break
      }
    }
  } catch Error as e {
    Log.Error("Failed to parse changelog.", e, false)
  }

  return bodies
}

UpdateScript(GuiCtrl, *) {
  DestroyGui(GuiCtrl)
  DownloadURL := ""
  DownloadPath := ""

  if (A_IsCompiled) {
    ; file is .exe
    DownloadURL := "https://github.com/TheMeteoRain/quality-of-exile/releases/download/v" LATEST_VERSION "/QualityOfExile.exe"
    DownloadPath := DATA_DIR "\QualityOfExile.tmp.exe"
  } else {
    ; file is .ahk
    DownloadURL := "https://github.com/TheMeteoRain/quality-of-exile/releases/download/v" LATEST_VERSION "/quality-of-exile-" LATEST_VERSION ".zip"
    DownloadPath := DATA_DIR "\qualityofexile.zip"
  }

  Log.Info("Download update. DownloadURL: " DownloadURL ", DownloadPath: " DownloadPath)
  try {
    Download(DownloadURL, DownloadPath)
  } catch Error as e {
    Log.Error(
      "Failed to download update. Please check your internet connection and try again. Optionally send an issue at: " GITHUB_URL,
      e,
      true
    )
    ExitApp()
  }

  if (A_IsCompiled) {
    helperPath := DATA_DIR "\update_helper.ahk"
    if (FileExist(helperPath)) {
      Log.Info("Delete old helper file.")
      FileDelete(helperPath)
    }

    try {
      Log.Info("Creating a helper file for updating .exe file.")
      currentExePath := A_ScriptFullPath
      helperScript := Format('
                    (
                        #Requires AutoHotkey v2.0
                        SetTitleMatchMode("2")
                        DetectHiddenWindows(true)
                        WinWaitClose("{}")
                        Sleep 1000
                        FileMove("{}", "{}", true)
                        Run("{}")
                    )',
        A_ScriptName, DownloadPath, currentExePath, currentExePath)
      FileAppend(helperScript, helperPath)

      Log.Info("Running helper file to update .exe file.")
      Run(helperPath)
    } catch Error as e {
      Log.Error("Failed to update. Try again or send an issue at: " GITHUB_URL, e, true)
    } finally {
      ExitApp()
    }
  }

  ; Pre-extract cleanup: tar -xf only creates and overwrites — it never
  ; deletes — so a release that removed or renamed a file/folder would
  ; otherwise leave dead artifacts in the install dir.
  ;
  ; 1. Every top-level *.ahk is deleted; the new zip re-supplies whatever
  ;    should still exist. The currently-running script's own file may
  ;    refuse deletion (held open) — that's fine, the extract overwrites it.
  ; 2. Known project subdirs are wiped recursively. Clearing them
  ;    wipes old installs cleanly.
  loop files, A_ScriptDir "\*.ahk" {
    try FileDelete(A_LoopFilePath)
  }
  for _, dir in ["src"] {
    fullPath := A_ScriptDir "\" dir
    if (DirExist(fullPath)) {
      try DirDelete(fullPath, true)
    }
  }

  try {
    ; Paths are quoted in case A_ScriptDir contains spaces (Program Files etc).
    tarCommand := Format('tar -xf "{}" -C "{}"', DownloadPath, A_ScriptDir)
    Log.Info("Running tar command: " tarCommand)
    RunWait(A_ComSpec . " /c " . tarCommand, "", "Hide")
    Log.Info("Tar command completed.")
  } catch Error as e {
    Log.Error(
      "Failed to extract updated files from .zip. Try again or send an issue at: " GITHUB_URL,
      e,
      true
    )
    ExitApp()
  } finally {
    if (FileExist(DownloadPath)) {
      Log.Info("Delete .zip file.")
      FileDelete(DownloadPath)
    }
  }

  try {
    Log.Info("Running updated file.")
    Run(A_ScriptFullPath)
  } catch Error as e {
    Log.Error("Failed to run updated file. Try again or send an issue at: " GITHUB_URL, e, true)
  } finally {
    ExitApp()
  }
}

CheckForUpdates() {
  global LATEST_VERSION

  try {
    Log.Info("Checking for updates.")
    releasesFile := DATA_DIR . "\releases.json"

    if (FileExist(releasesFile)) {
      Log.Info("Delete old release.json file.")
      FileDelete(releasesFile)
    }

    Log.Info("Downloading releases.json.")
    Download(
      "https://api.github.com/repos/themeteorain/quality-of-exile/releases",
      DATA_DIR . "\releases.json"
    )
    Releases := FileRead(DATA_DIR . "\releases.json")

    Log.Info("Parsing version.")
    if (RegExMatch(Releases, '"tag_name"\s*:\s*"v([^"]+)"', &match)) {
      LATEST_VERSION := Trim(match[1])
      Log.Info("Latest version fetched: " LATEST_VERSION)
    }

    if (VerCompare(LATEST_VERSION, VERSION) == 1) {
      Log.Info("Parsing changelog.")
      Changelog := GetNewerReleaseBodies(Releases, VERSION)

      VersionGui := Gui("", "Quality of Exile - Update Available")
      VersionGui.Add(
        "Text",
        "",
        "Update Available.`nCurrent version: " VERSION "`nNew version available: " LATEST_VERSION "`n`nContinue with update? It will only take a moment, and the script will automatically restart."
      )
      VersionGui.Add("Edit", "w600 h300 +ReadOnly +VScroll +HScroll", Changelog)
      UpdateButton := VersionGui.Add("Button", "Default Section", "Update")
      UpdateButton.OnEvent("Click", UpdateScript)
      SkipButton := VersionGui.Add("Button", "YS", "Skip")
      SkipButton.OnEvent("Click", DestroyGui)
      VersionGui.Show()
    }
  } catch Error as e {
    Log.Error(
      Format("
        (
          Failed to check for updates.
          Please check your internet connection and try again by starting the application again.
          Program will continue to run with current version: '{}'
        )",
        VERSION
      ),
      e,
      true
    )
  } finally {
    if (FileExist(releasesFile)) {
      Log.Info("Delete release.json file.")
      FileDelete(releasesFile)
    }
  }

}

ExitReason := IniRead(BOOT_FILE, "BOOT", "ExitReason", "")
CreateProgramPathDir()
if (ExitReason != "Reload") {
  CheckForUpdates()
}
if (FileExist(BOOT_FILE)) {
  FileDelete(BOOT_FILE)
}
