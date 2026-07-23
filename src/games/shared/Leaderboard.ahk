#Requires AutoHotkey v2.0

; Scrapes the public ladder HTML pages and pushes the character's rank into
; the HUD. League names are pulled from the index page so the Settings
; dropdown stays in sync with whatever leagues are currently active.

class Leaderboard {
  static _REFRESH_MS := 300000   ; refresh every 5 minutes

  ; PoE1 ladders index is server-rendered HTML — league names live in <h2>.
  ; PoE2's index is a JS SPA, but the SPA fetches league names from this JSON
  ; endpoint behind the scenes.
  static _LADDERS_URL := Map(
    "PoE1", "https://www.pathofexile.com/ladders",
    "PoE2", "https://pathofexile2.com/internal-api/content/game-ladders",
  )

  ; PoE1 still scrapes the server-rendered HTML page; PoE2 hits the per-league
  ; JSON endpoint behind the SPA (returns the full 1000-entry ladder).
  static _LADDER_URL := Map(
    "PoE1", "https://www.pathofexile.com/ladder/{1}",
    "PoE2", "https://pathofexile2.com/internal-api/content/game-ladder/id/{1}",
  )

  ; Disk cache lives in DATA_FILE [Leagues] and is refreshed at most once per
  ; NZ day (rolls over at 08:00 NZ — see _LastNzRefreshUtc).
  static _LEAGUES_SECTION := "Leagues"
  ; NZST baseline (UTC+12). DST adds an hour, ignored — the rollover ends up
  ; firing at 07:00 NZDT during summer, which is close enough.
  static _NZ_OFFSET_HOURS := 12

  static _timer := (*) => Leaderboard._Refresh()

  ; --- Public ---

  static Start() {
    Leaderboard._Refresh()
    SetTimer(Leaderboard._timer, Leaderboard._REFRESH_MS)
  }

  static Stop() {
    SetTimer(Leaderboard._timer, 0)
    HUD.SetRank("--")
  }

  ; Returns an Array of league names for the current game variant. Cached
  ; on disk and refreshed at most once per NZ day at 08:00 (GGG's office hours
  ; — most league launches/closures roll out around then).
  static FetchLeagues(variant := Game.Variant) {
    if (!Leaderboard._LADDERS_URL.Has(variant)) {
      return []
    }

    cached := Leaderboard._ReadLeagueCache(variant)
    if (cached.Length > 0 and !Leaderboard._ShouldRefetchLeagues(variant)) {
      return cached
    }

    body := Leaderboard._Get(Leaderboard._LADDERS_URL[variant])
    if (body == "") {
      ; Network failed — fall back to whatever's on disk rather than blanking
      ; the dropdown.
      return cached
    }
    leagues := variant == "PoE2"
      ? Leaderboard._ParseLeaguesJson(body)
      : Leaderboard._ParseLeaguesHtml(body)
    Leaderboard._WriteLeagueCache(variant, leagues)
    return leagues
  }

  ; --- Internal ---

  static _Refresh() {
    char   := Storage.UserValues.Get("LeaderboardCharacter", "")
    league := Storage.UserValues.Get("LeaderboardLeague", "")
    if (char == "" or league == "" or !Leaderboard._LADDER_URL.Has(Game.Variant)) {
      HUD.SetRank("--")
      return
    }

    ; PoE1 ladder HTML parsing not implemented yet — the league dropdown still
    ; works (same fetch logic), but rank lookup is PoE2-only for now.
    if (Game.Variant == "PoE1") {
      HUD.SetRank("--")
      return
    }

    url := Format(Leaderboard._LADDER_URL[Game.Variant], Leaderboard._UrlEncode(league))
    body := Leaderboard._Get(url)
    if (body == "") {
      HUD.SetRank("?")
      return
    }
    rank := Game.Variant == "PoE2"
      ? Leaderboard._FindRankJson(body, char)
      : Leaderboard._FindRank(body, char)
    HUD.SetRank(rank > 0 ? "#" rank : "—")
  }

  ; HTTP GET with a browser User-Agent. AHK's Download() uses a default UA
  ; that pathofexile2.com returns short / placeholder HTML for. Returns "" on
  ; any failure (network error, non-200 status) and logs — callers branch on
  ; the empty string rather than wrapping every call in try/catch.
  static _Get(url) {
    try {
      req := ComObject("WinHttp.WinHttpRequest.5.1")
      req.Open("GET", url, false)
      req.SetRequestHeader("User-Agent",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36")
      req.Send()
      if (req.Status != 200) {
        Log.Error(Format("Leaderboard HTTP {} from {}", req.Status, url))
        return ""
      }
      return req.ResponseText
    } catch Error as e {
      Log.Error("Leaderboard request failed: " url, e)
      return ""
    }
  }

  ; PoE1: <h2> elements in the ladders index page hold league names.
  static _ParseLeaguesHtml(html) {
    leagues := []
    pos := 1
    while (pos := RegExMatch(html, "i)<h2[^>]*>([\s\S]*?)</h2>", &m, pos)) {
      name := Trim(RegExReplace(RegExReplace(m[1], "<[^>]+>", ""), "\s+", " "))
      if (name != "") {
        leagues.Push(name)
      }
      pos += m.Len()
    }
    return leagues
  }

  ; PoE2: response is `{ "context": { "ladders": [ { "league": { "id": ..., "name": ... }, ... }, ... ] } }`.
  ; Each ladder block opens with `"league":{...}` containing `"name":"..."`; we
  ; grab the first name inside each block.
  static _ParseLeaguesJson(json) {
    leagues := []
    pos := 1
    while (pos := RegExMatch(json, '"league"\s*:\s*\{[^}]*?"name"\s*:\s*"([^"]+)"', &m, pos)) {
      leagues.Push(m[1])
      pos += m.Len()
    }
    return leagues
  }

  ; Scan rows of the form:
  ;   <tr class="league-ladder__entry">
  ;     <td>{rank}</td>
  ;     <td><a ...>{account}</a></td>
  ;     <td>{character} <!----><!----></td>   ← 3rd td, what we match on
  ;     <td ...>{ascendancy}</td>
  ;     <td>{level}</td>
  ;     <td>{exp}</td>
  ;   </tr>
  static _FindRank(html, name) {
    pos := 1
    while (pos := RegExMatch(html, 'i)<tr\s+class="league-ladder__entry">([\s\S]*?)</tr>', &row, pos)) {
      tds := Leaderboard._ExtractTds(row[1])
      if (tds.Length >= 3 and tds[3] == name) {
        return Integer(tds[1])
      }
      pos += row.Len()
    }
    return 0
  }

  ; PoE2: entries look like
  ;   { "rank": N, "dead": false, [...], "character": { "id": "...", "name": "...", ... }, "account": {...} }
  ; Pair each rank with the next character.name (non-greedy stays within the
  ; same entry since rank precedes character in every block).
  static _FindRankJson(json, name) {
    pos := 1
    while (pos := RegExMatch(json, '"rank"\s*:\s*(\d+)[\s\S]*?"character"\s*:\s*\{[^}]*?"name"\s*:\s*"([^"]+)"', &m, pos)) {
      if (m[2] == name) {
        return Integer(m[1])
      }
      pos += m.Len()
    }
    return 0
  }

  static _ExtractTds(rowHtml) {
    cells := []
    pos := 1
    while (pos := RegExMatch(rowHtml, 'i)<td[^>]*>([\s\S]*?)</td>', &td, pos)) {
      content := RegExReplace(td[1], "<!--[\s\S]*?-->", "")    ; drop HTML comments
      content := RegExReplace(content, "<[^>]+>", "")           ; drop nested tags
      cells.Push(Trim(content))
      pos += td.Len()
    }
    return cells
  }

  static _UrlEncode(s) {
    return StrReplace(s, " ", "%20")
  }

  static _ReadLeagueCache(variant) {
    names := IniRead(DATA_FILE, Leaderboard._LEAGUES_SECTION, variant "_Names", "")
    return names == "" ? [] : StrSplit(names, "|")
  }

  static _WriteLeagueCache(variant, leagues) {
    joined := ""
    for i, name in leagues {
      joined .= (i > 1 ? "|" : "") . name
    }
    IniWrite(joined,    DATA_FILE, Leaderboard._LEAGUES_SECTION, variant "_Names")
    IniWrite(A_NowUTC,  DATA_FILE, Leaderboard._LEAGUES_SECTION, variant "_FetchedAt")
  }

  static _ShouldRefetchLeagues(variant) {
    last := IniRead(DATA_FILE, Leaderboard._LEAGUES_SECTION, variant "_FetchedAt", "")
    if (last == "") {
      return true
    }
    return last < Leaderboard._LastNzRefreshUtc()
  }

  ; UTC timestamp of the most recent 08:00 NZ rollover (today's if we're past
  ; it, otherwise yesterday's). YYYYMMDDHH24MISS strings compare correctly,
  ; so the caller just does a string comparison against last-fetch time.
  static _LastNzRefreshUtc() {
    nzNow := DateAdd(A_NowUTC, Leaderboard._NZ_OFFSET_HOURS, "Hours")
    nz8am := SubStr(nzNow, 1, 8) "080000"
    if (nzNow < nz8am) {
      nz8am := DateAdd(nz8am, -24, "Hours")
    }
    return DateAdd(nz8am, -Leaderboard._NZ_OFFSET_HOURS, "Hours")
  }
}
