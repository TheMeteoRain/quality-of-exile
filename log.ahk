#Requires AutoHotkey v2.0
#Include "globals.ahk"

for _, arg in A_Args {
  if RegExMatch(arg, "i)^DEBUG=(true|false)$", &m)
    DEBUG := (m[1] = "true")
}

OnError(OnErrorCallback)
OnExit(OnExitCallback)

OnExitCallback(ExitReason, ExitCode) {
  LogInfo(Format("Exiting Quality of Exile with reason: {} and code: {}", ExitReason, ExitCode))
}

ErrorStringify(e) {
  errStr := ""
  for key, val in e.OwnProps() {
    errStr .= Format('{}: "{}", ', key, RegExReplace(val, "[\r\n\t]", ""))
  }
  errStr := Trim(errStr, ", ")

  return errStr
}
OnErrorCallback(e, mode) {
  LogMessage("Fatal", "An error occurred in the script.", e)
}

LogMessage(level := "Info", msg := unset, err := unset, showMsgBox := false) {
  if (IsSet(msg)) {
    text := unset

    if (showMsgBox) {
      MsgBox(msg)
    }

    if (IsSet(err)) {
      text := Format(
        "Level: {}, Version: {}, Time: {}, A_IsCompiled: {}, Message: {}, Error::: {} `n",
        level, VERSION, A_NowUTC, A_IsCompiled, msg, ErrorStringify(err)
      )
    } else {
      text := Format(
        "Level: {}, Version: {}, Time: {}, A_IsCompiled: {}, Message: {} `n",
        level, VERSION, A_NowUTC, A_IsCompiled, msg
      )
    }

    FileAppend(text, Q_LogPath)
  }
}
LogError(msg := unset, err := unset, showMsgBox := false) {
  LogMessage("Error", msg, err, showMsgBox)
}
LogDebug(msg := unset, showMsgBox := false) {
  if (DEBUG) {
    LogMessage("Debug", msg, , showMsgBox)
  }
}
LogInfo(msg := unset, showMsgBox := false) {
  LogMessage("Info", msg, , showMsgBox)
}
