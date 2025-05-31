#Requires AutoHotkey v2.0
#Include "version.ahk"

Q_ProgramPathDir := A_MyDocuments "\QualityOfExile"
Q_LogPath := A_MyDocuments "\QualityOfExile\log.txt"
Q_GithubLink := "https://github.com/TheMeteoRain/quality-of-exile"
Q_CportsPathDir := Q_ProgramPathDir "\cports"
Q_CportsPath := Q_CportsPathDir "\cports.exe" ; Check in the script's directory
Q_CportsDownloadLink := "https://www.nirsoft.net/utils/cports.zip" ; URL to the ZIP file
Q_CportsZipPath := Q_ProgramPathDir "\cports.zip"

DEBUG := false
AHK_VERSION_REQUIRED := "2.0.0"
INI_FILE := Q_ProgramPathDir "\data.ini"
STATE_FILE := Q_ProgramPathDir "\state.ini"
LATEST_VERSION := VERSION
MAIN_COLOR := "20283f"