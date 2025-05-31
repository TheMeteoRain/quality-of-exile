#Requires AutoHotkey v2.0

CreateProgramPathDir() {
  if (!DirExist(Q_ProgramPathDir)) {
    DirCreate(Q_ProgramPathDir)
  }
}

DestroyGui(GuiCtrl, *) {
  if (IsSet(GuiCtrl)) {
    GuiCtrl.gui.Destroy()
  }
}

DownloadCports() {
  if FileExist(Q_CportsPath) {
    LogInfo("CurrPorts already exists at: " Q_CportsPath)
    return
  }

  ; if last download made some progress, start from clean slate
  if (DirExist(Q_CportsPathDir)) {
    DirDelete(Q_CportsPathDir, true)
  }

  ; Download cports
  try {
    Download(Q_CportsDownloadLink, Q_CportsZipPath)
  } catch Error as e {
    LogError("Failed to download CurrPorts. Please check your internet connection and try again.", e, true)
  }

  ; Wait for download
  timeout := 30000
  startTime := A_TickCount
  loop 30 {
    if FileExist(Q_CportsZipPath) && FileGetSize(Q_CportsZipPath) > 0 {
      break
    }
    if (A_TickCount - startTime > timeout) {
      LogError(
        "Downloading CurrPorts timedout. Please check your internet connection or try again later.",
        e,
        true
      )
      ExitApp()
    }
    Sleep(1000)
  }

  ; Create dir
  DirCreate(Q_CportsPathDir)
  if (!DirExist(Q_CportsPathDir)) {
    MsgBox("Something went wrong")
    LogError("Could not create dir for cports", e)
    ExitApp()
  }

  ; Extract zip
  tarCommand := Format("tar -xf {} -C {}", Q_CportsZipPath, Q_CportsPathDir)
  RunWait(A_ComSpec . " /c " . tarCommand, "", "Hide")
  FileDelete(Q_CportsZipPath)

  if !FileExist(Q_CportsPath) {
    LogError(
      "Error downloading or extracting CurrPorts. Please ensure you have internet access and try again.",
      ,
      true
    )
    ExitApp()
  }
}

GetNewerReleaseBodies(json, currentVersion) {
  bodies := "No changelog available."

  try {
    pos := 1
    while RegExMatch(json, '"tag_name"\s*:\s*"v([^"]+)"[\s\S]+?"body"\s*:\s*"((?:[^"\\]|\\.)*)"', &m,
      pos) {
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
    LogError("Failed to parse changelog.", e, false)
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
    DownloadPath := Q_ProgramPathDir "\QualityOfExile.tmp.exe"
  } else {
    ; file is .ahk
    DownloadURL := "https://github.com/TheMeteoRain/quality-of-exile/releases/download/v" LATEST_VERSION "/quality-of-exile-" LATEST_VERSION ".zip"
    DownloadPath := Q_ProgramPathDir "\qualityofexile.zip"
  }

  LogInfo("Download update. DownloadURL: " DownloadURL ", DownloadPath: " DownloadPath)
  try {
    Download(DownloadURL, DownloadPath)
  } catch Error as e {
    LogError(
      "Failed to download update. Please check your internet connection and try again. Optionally send an issue at: " Q_GithubLink,
      e,
      true
    )
    ExitApp()
  }

  if (A_IsCompiled) {
    helperPath := Q_ProgramPathDir "\update_helper.ahk"
    if (FileExist(helperPath)) {
      LogInfo("Delete old helper file.")
      FileDelete(helperPath)
    }

    try {
      LogInfo("Creating a helper file for updating .exe file.")
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

      LogInfo("Running helper file to update .exe file.")
      Run(helperPath)
    } catch Error as e {
      LogError("Failed to update. Try again or send an issue at: " Q_GithubLink, e, true)
    } finally {
      ExitApp()
    }
  }

  try {
    ; TODO: fix path
    tarCommand := Format("tar -xf {} -C {}", DownloadPath, A_ScriptDir)
    LogInfo("Running tar command: " tarCommand)
    RunWait(A_ComSpec . " /c " . tarCommand, "", "Hide")
    LogInfo("Tar command completed.")
  } catch Error as e {
    LogError(
      "Failed to extract updated files from .zip. Try again or send an issue at: " Q_GithubLink,
      e,
      true
    )
    ExitApp()
  } finally {
    if (FileExist(DownloadPath)) {
      LogInfo("Delete .zip file.")
      FileDelete(DownloadPath)
    }
  }

  try {
    LogInfo("Running updated file.")
    Run(A_ScriptFullPath)
  } catch Error as e {
    LogError("Failed to run updated file. Try again or send an issue at: " Q_GithubLink, e, true)
  } finally {
    ExitApp()
  }
}

CheckForUpdates() {
  global LATEST_VERSION

  try {
    LogInfo("Checking for updates.")
    releasesFile := Q_ProgramPathDir . "\releases.json"

    if (FileExist(releasesFile)) {
      LogInfo("Delete old release.json file.")
      FileDelete(releasesFile)
    }

    LogInfo("Downloading releases.json.")
    Download(
      "https://api.github.com/repos/themeteorain/quality-of-exile/releases",
      Q_ProgramPathDir . "\releases.json"
    )
    Releases := FileRead(Q_ProgramPathDir . "\releases.json")

    LogInfo("Parsing version.")
    if (RegExMatch(Releases, '"tag_name"\s*:\s*"v([^"]+)"', &match)) {
      LATEST_VERSION := Trim(match[1])
      LogInfo("Latest version fetched: " LATEST_VERSION)
    }

    if (VerCompare(LATEST_VERSION, VERSION) == 1) {
      LogInfo("Parsing changelog.")
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
    LogError(
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
      LogInfo("Delete release.json file.")
      FileDelete(releasesFile)
    }
  }

}

CreateProgramPathDir()
CheckForUpdates()
DownloadCports()