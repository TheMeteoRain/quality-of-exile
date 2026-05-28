#Requires AutoHotkey v2.0
; VERSION is included from QualityOfExile.ahk (root) so the path doesn't
; depend on this file's location. CI's `sed -i version.ahk` bump targets
; the root file directly.

DATA_DIR := A_MyDocuments "\QualityOfExile"
LOG_PATH := DATA_DIR "\log.txt"
GITHUB_URL := "https://github.com/TheMeteoRain/quality-of-exile"

DEBUG := false
AHK_VERSION_REQUIRED := "2.0.0"
DATA_FILE := DATA_DIR "\data.ini"
STATE_FILE := DATA_DIR "\state.ini"
BOOT_FILE := DATA_DIR "\boot.ini"
LATEST_VERSION := VERSION
MAIN_COLOR := "20283f"
REGEXP_CHARACTER_LIMIT := 248
MSGBOX_TOPMOST := "Iconx 0x40000"   ; no-icon + MB_TOPMOST
