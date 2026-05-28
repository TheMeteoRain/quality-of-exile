#Requires AutoHotkey v2.0

for _, arg in A_Args {
  if RegExMatch(arg, "i)^DEBUG=(true|false)$", &m)
    DEBUG := (m[1] = "true")
}

OnError((thrown, mode) => Log._OnError(thrown, mode))
OnExit((reason, code) => Log._OnExit(reason, code))

class Log {
  static Info(msg, showMsgBox := false) {
    Log._Write("Info", msg, , showMsgBox)
  }

  static Error(msg, err?, showMsgBox := false) {
    Log._Write("Error", msg, err?, showMsgBox)
  }

  static Debug(msg, showMsgBox := false) {
    if (DEBUG) {
      Log._Write("Debug", msg, , showMsgBox)
    }
  }

  static _Write(level, msg, err?, showMsgBox := false) {
    if (showMsgBox) {
      MsgBox(msg)
    }
    text := IsSet(err)
      ? Format("Level: {}, Version: {}, Time: {}, A_IsCompiled: {}, Message: {}, Error::: {} `n",
        level, VERSION, A_NowUTC, A_IsCompiled, Log._OneLine(msg), Log._Stringify(err))
      : Format("Level: {}, Version: {}, Time: {}, A_IsCompiled: {}, Message: {} `n",
        level, VERSION, A_NowUTC, A_IsCompiled, Log._OneLine(msg))
    FileAppend(text, LOG_PATH)
  }

  static _Stringify(e) {
    errStr := ""
    for key, val in e.OwnProps() {
      errStr .= Format('{}: "{}", ', key, RegExReplace(val, "[\r\n\t]", ""))
    }
    return Trim(errStr, ", ")
  }

  static _OneLine(text) {
    return RegExReplace(text, "[\r\n\t]", "")
  }

  static _OnExit(ExitReason, ExitCode) {
    Log.Info(Format("Exiting Quality of Exile with reason: {} and code: {}", ExitReason, ExitCode))
    if (ExitReason != "Reload" and FileExist(STATE_FILE)) {
      FileDelete(STATE_FILE)
    }
    IniWrite(ExitReason, BOOT_FILE, "BOOT", "ExitReason")
  }

  static _OnError(ThrownValue, ErrorMode) {
    Log._Write("Fatal", "An error occurred in the script.", ThrownValue)
  }
}
