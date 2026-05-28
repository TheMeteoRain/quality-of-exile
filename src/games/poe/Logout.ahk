#Requires AutoHotkey v2.0

; Kill every TCP connection owned by the game process via Iphlpapi.dll.
; <5 ms typical — vital when escaping a fatal hit. Requires admin.
;
; The previous cports.exe shell-out cost ~500 ms — too slow when a character
; is one tick from dying. Native API does what the third-party tool did
; internally.

class Logout {
  static Force(*) {
    Critical
    if (Debounce("Logout.Force", 200)) {
      return
    }
    if (DEBUG) {
      MsgBox("TCP connections terminated.")
      return
    }

    pid := Game.PID
    if (!pid) {
      return
    }

    try {
      killed := Logout._KillTCP(pid)
      Log.Debug(Format("Logout: killed {} connection(s) for PID {}", killed, pid))
    } catch Error as e {
      ; Last-resort fallback: closing the process disconnects the user.
      Log.Error("Logout via SetTcpEntry failed; falling back to ProcessClose", e)
      ProcessClose(pid)
    }
  }

  ; Enumerate the IPv4 TCP table via GetExtendedTcpTable, then SetTcpEntry
  ; with state = MIB_TCP_STATE_DELETE_TCB on every row whose PID matches.
  ; IPv4 only; PoE / LE use IPv4 game servers today.
  static _KillTCP(targetPid) {
    static AF_INET := 2
    static TCP_TABLE_OWNER_PID_ALL := 5
    static MIB_TCP_STATE_DELETE_TCB := 12
    static ROW_SIZE := 24   ; sizeof(MIB_TCPROW_OWNER_PID)
    static SET_ROW_SIZE := 20   ; sizeof(MIB_TCPROW) — no PID field

    ; Sizing call: null buffer → required bytes written to `size`.
    size := 0
    DllCall("Iphlpapi\GetExtendedTcpTable",
      "Ptr", 0, "UInt*", &size, "Int", false,
      "UInt", AF_INET, "Int", TCP_TABLE_OWNER_PID_ALL, "UInt", 0
    )
    if (size == 0) {
      throw Error("GetExtendedTcpTable sizing returned 0")
    }

    buf := Buffer(size, 0)
    rc := DllCall("Iphlpapi\GetExtendedTcpTable",
      "Ptr", buf, "UInt*", &size, "Int", false,
      "UInt", AF_INET, "Int", TCP_TABLE_OWNER_PID_ALL, "UInt", 0
    )
    if (rc != 0) {
      throw Error("GetExtendedTcpTable failed: code " rc)
    }

    numEntries := NumGet(buf, 0, "UInt")
    killed := 0
    setRow := Buffer(SET_ROW_SIZE, 0)

    loop numEntries {
      rowOff := 4 + (A_Index - 1) * ROW_SIZE
      if (NumGet(buf, rowOff + 20, "UInt") != targetPid) {
        continue
      }
      ; MIB_TCPROW: { state, localAddr, localPort, remoteAddr, remotePort }.
      NumPut("UInt", MIB_TCP_STATE_DELETE_TCB, setRow, 0)
      NumPut("UInt", NumGet(buf, rowOff + 4, "UInt"), setRow, 4)
      NumPut("UInt", NumGet(buf, rowOff + 8, "UInt"), setRow, 8)
      NumPut("UInt", NumGet(buf, rowOff + 12, "UInt"), setRow, 12)
      NumPut("UInt", NumGet(buf, rowOff + 16, "UInt"), setRow, 16)
      if (DllCall("Iphlpapi\SetTcpEntry", "Ptr", setRow) == 0) {
        killed++
      }
    }

    return killed
  }
}
