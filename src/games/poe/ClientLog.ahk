#Requires AutoHotkey v2.0

; PoE writes every area transition to Client.txt. We tail that file, classify
; each "Generating level" line as a safe zone (town / hideout) vs an instance,
; and gate the dynamic hotkeys (crafting orbs) accordingly so users can't fire
; them in combat.

class ClientLog {
  static _IDLE_THRESHOLD_S := 300     ; seconds: skip auto-rearm if log untouched this long
  static _STARTUP_TAIL_BYTES := 100000  ; how much of the log we read on startup
  static _TAIL_INTERVAL_MS := 1000    ; tail polling cadence

  static _path := ""
  static _file := 0
  static _readFunc := 0
  static Activated := false       ; persisted via Storage
  static LastLocation := "other"  ; persisted via Storage

  ; ---- Public ----

  static Start() {
    ClientLog._GetPath()
    ClientLog._Listen()
    ClientLog._Bootstrap()
  }

  static Stop() {
    ClientLog._Unlisten()
    ClientLog.SetDynamic(0)
  }

  ; Re-arm or disable the dynamic hotkeys (crafting orbs etc.). `persist`
  ; controls whether the change is saved to STATE_FILE.
  static SetDynamic(enabled, persist := true) {
    if (Keybinds.IsSuspended()) {
      return
    }

    ; Dynamic hotkeys may only ever live in "safe" zones — even when the
    ; caller asks to enable, suppress if we're elsewhere.
    enabled := !!(enabled and ClientLog.LastLocation == "safe")
    action := enabled ? "On" : "Off"

    for key, config in Configs {
      if (!ConfigBool(config, "toggleOnInstance") or !Storage.Bindings.Get(key, "")) {
        continue
      }
      Keybinds.Register("*" . Storage.Bindings[key], config.func, action, config.canBeDisabled)
    }

    if (persist and ClientLog.Activated != enabled) {
      ClientLog.Activated := enabled
      Storage.SaveState()
    }
  }

  ; ---- Internal ----

  static _GetPath() {
    if (ClientLog._path) {
      return
    }
    processPath := ProcessGetPath(Game.PID)
    logFilePath := RegExReplace(processPath, "\\[^\\]*$", "\logs\Client.txt")
    if FileExist(logFilePath) {
      ClientLog._path := logFilePath
    }
  }

  static _Listen() {
    if (!ClientLog._file and ClientLog._path) {
      ; Open in read mode without locking.
      ClientLog._file := FileOpen(ClientLog._path, "r")
    }
    if (ClientLog._file and !ClientLog._readFunc) {
      ClientLog._readFunc := (*) => ClientLog._ReadLog()
      ; On startup, read the tail so the last known location is known and
      ; dynamic hotkeys can re-arm immediately if appropriate.
      pos := Max(0, ClientLog._file.Length - ClientLog._STARTUP_TAIL_BYTES)
      ClientLog._file.Seek(pos, 0)
      ClientLog._ReadLog()

      ClientLog._file.Seek(0, 2)  ; Seek to end for tailing.
      SetTimer(ClientLog._readFunc, ClientLog._TAIL_INTERVAL_MS)
    }
  }

  static _Unlisten() {
    if (ClientLog._readFunc) {
      SetTimer(ClientLog._readFunc, 0)
      ClientLog._readFunc := 0
    }
  }

  ; Decide whether to immediately re-arm dynamic hotkeys based on the saved
  ; activation flag + how recently Client.txt was last touched.
  static _Bootstrap() {
    if (!ClientLog._path) {
      return
    }
    lastModified := DateDiff(A_Now, FileGetTime(ClientLog._path, "M"), "Seconds")

    if (ClientLog.Activated) {
      ClientLog.SetDynamic(ClientLog.Activated, true)
      return
    }

    if (lastModified > ClientLog._IDLE_THRESHOLD_S or Game.PreviousAttachTime) {
      ClientLog.SetDynamic(0, true)
    } else {
      ClientLog.SetDynamic(1, true)
    }
  }

  static _ReadLog() {
    if (!IsObject(ClientLog._file)) {
      return
    }
    if (newLines := ClientLog._file.Read()) {
      ClientLog._Process(newLines)
    }
  }

  static _Process(text) {
    if (!text) {
      return
    }

    localLast := ClientLog.LastLocation
    for index, line in StrSplit(text, "`n") {
      line := RegExReplace(line, "`r$")

      if (RegExMatch(line, "\[STARTUP\] Game Start|Connected to")) {
        localLast := "other"
        continue
      }

      if (RegExMatch(line, "Generating level")) {
        localLast := (ClientLog._MatchPoe1(line) or ClientLog._MatchPoe2(line)) ? "safe" : "other"
      }
    }

    ClientLog.LastLocation := localLast
    Storage.SaveState()
    ClientLog.SetDynamic(localLast == "safe" ? 1 : 0, true)
  }

  ; PoE2 town / hideout area names: "C_G1_town", "G2_town", "...Hideout..."
  static _MatchPoe2(line) {
    return !!RegExMatch(line, "Generating level \d+ area `"(?:C_)?G\d_town|.*Hideout.*`"")
  }

  ; PoE1 town / hideout / event-specific safe areas.
  static _MatchPoe1(line) {
    return !!RegExMatch(line,
      "Generating level \d+ area `"(?:\d+_\d+?(?:_.*)?_town|.*Hideout.*|KalguuranSettlersLeague|ChayulaLeague)`"")
  }
}
