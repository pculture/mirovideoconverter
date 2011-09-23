; Passed in from command line:
;  CONFIG_VERSION        eg, "0.8.0"

; TODO: Add MIROBAR_EXE
!define CONFIG_PROJECT_URL "http://www.mirovideoconverter.com/"
!define CONFIG_SHORT_APP_NAME "MVC"
!define CONFIG_LONG_APP_NAME  "Miro Video Converter"
!define CONFIG_PUBLISHER "Participatory Culture Foundation"
!define CONFIG_EXECUTABLE "MiroConverter.exe"
!define CONFIG_OUTPUT_FILE "MiroConverter-${CONFIG_VERSION}.exe"
!define CONFIG_ICON "converter3.ico"

!define INST_KEY "Software\${CONFIG_PUBLISHER}\${CONFIG_LONG_APP_NAME}"
!define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${CONFIG_LONG_APP_NAME}"

!define RUN_SHORTCUT "${CONFIG_LONG_APP_NAME}.lnk"
!define UNINSTALL_SHORTCUT "Uninstall ${CONFIG_SHORT_APP_NAME}.lnk"
!define MUI_ICON "${CONFIG_ICON}"
!define MUI_UNICON "${CONFIG_ICON}"

Name "${CONFIG_LONG_APP_NAME}"
OutFile "${CONFIG_OUTPUT_FILE}"
InstallDir "$PROGRAMFILES\${CONFIG_PUBLISHER}\${CONFIG_LONG_APP_NAME}"
InstallDirRegKey HKLM "${INST_KEY}" "Install_Dir"
SetCompressor lzma

SetOverwrite on
CRCCheck on

Icon "${CONFIG_ICON}"

Var STARTMENU_FOLDER
Var ZUGO_HOMEPAGE
Var ZUGO_TOOLBAR
Var ZUGO_DEFAULT_SEARCH
Var ZUGO_FLAGS
Var ZUGO_COUNTRY
Var ZUGO_PROVIDER
Var ZUGO_TERMS

!define MUI_WELCOMEPAGE_TITLE "Welcome to ${CONFIG_LONG_APP_NAME}!"
;!define MUI_WELCOMEPAGE_TEXT "To get started, choose an easy or a custom install process and then click 'Install'."

!include "MUI.nsh"
!include "FileFunc.nsh"
!include nsDialogs.nsh

!insertmacro GetParameters
!insertmacro GetOptions
!insertmacro un.GetParameters
!insertmacro un.GetOptions

!ifdef MIROBAR_EXE
  ReserveFile "${MIROBAR_EXE}"
!endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pages                                                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Welcome page
!define MUI_PAGE_CUSTOMFUNCTION_PRE   "add_radio_buttons"
!define MUI_PAGE_CUSTOMFUNCTION_SHOW  "fix_background_color"
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE "check_radio_buttons"

!define MUI_COMPONENTSPAGE_NODESC
!insertmacro MUI_PAGE_WELCOME

Function add_radio_buttons
; if no reinstall or advanced, just start right up
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Settings" "NumFields" "14"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Settings" "NextButtonText" "Next >"

  !ifdef MIROBAR_EXE

  StrCmp $ZUGO_COUNTRY "US" +5
  StrCpy $ZUGO_TOOLBAR "0"
  StrCpy $ZUGO_DEFAULT_SEARCH "0"
  StrCpy $ZUGO_HOMEPAGE "0"
  Goto after_zugo
  StrCmp "$ZUGO_TOOLBAR$ZUGO_DEFAULT_SEARCH$ZUGO_HOMEPAGE" "" 0 toolbar_options

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "${MIROBAR_EXE}"
  StrCmp $ZUGO_COUNTRY "US" 0 zugo_int
  ;MessageBox MB_OK "$PLUGINSDIR\${MIROBAR_EXE} /OFFERED /TOOLBAR /DEFAULTSTART /DEFAULTSEARCH $ZUGO_FLAGS"
  Exec "$PLUGINSDIR\${MIROBAR_EXE} /OFFERED /TOOLBAR /DEFAULTSTART /DEFAULTSEARCH $ZUGO_FLAGS"
  StrCpy $ZUGO_TOOLBAR "1"
  StrCpy $ZUGO_DEFAULT_SEARCH "1"
  StrCpy $ZUGO_HOMEPAGE "1"
  Goto toolbar_options
  
toolbar_options:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 6" "Type"   "label"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 6" "Text"   "Included Components"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 6" "Left"   "120"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 6" "Right"  "315"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 6" "Top"    "100"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 6" "Bottom" "110"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 7" "Type"   "checkbox"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 7" "Text"   "${CONFIG_LONG_APP_NAME} core (required)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 7" "Left"   "120"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 7" "Right"  "315"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 7" "Top"    "115"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 7" "Bottom" "125"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 7" "State"  "1"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 7" "Flags"  "DISABLED"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 8" "Type"   "checkbox"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 8" "Text"   "MSN Homepage (powered by $ZUGO_PROVIDER)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 8" "Left"   "120"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 8" "Right"  "315"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 8" "Top"    "125"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 8" "Bottom" "135"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 8" "State"  "0"
  StrCmp $ZUGO_HOMEPAGE "0" +2
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 8" "State"  "1"

  StrCmp $ZUGO_COUNTRY "US" 0 no_toolbar
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 9" "Type"   "checkbox"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 9" "Text"   "StartNow Toolbar (powered by $ZUGO_PROVIDER)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 9" "Left"   "120"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 9" "Right"  "315"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 9" "Top"    "145"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 9" "Bottom" "155"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 9" "State"  "0"
  StrCmp $ZUGO_TOOLBAR "0" +2
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 9" "State"  "1"

no_toolbar:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 10" "Type"   "checkbox"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 10" "Text"   "Set $ZUGO_PROVIDER as default search engine"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 10" "Left"   "120"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 10" "Right"  "315"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 10" "Top"    "135"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 10" "Bottom" "145"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 10" "State"  "0"
  StrCmp $ZUGO_DEFAULT_SEARCH "0" +2
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 10" "State"  "1"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 12" "Type"   "label"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 12" "Text"   "These optional search components help support our non-profit work and can be uninstalled at any time."
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 12" "Left"   "132"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 12" "Right"  "315"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 12" "Top"    "155"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 12" "Bottom" "175"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 13" "Type"   "label"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 13" "Text"   "By clicking 'Next' you are agreeing to our toolbar and search"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 13" "Left"   "132"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 13" "Right"  "315"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 13" "Top"    "175"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 13" "Bottom" "183"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 14" "Type"   "link"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 14" "Text"   "terms and conditions"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 14" "Left"   "132"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 14" "Right"  "315"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 14" "Top"    "183"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 14" "Bottom" "193"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 14" "State"  "$ZUGO_TERMS"



after_zugo:
!endif
FunctionEnd

Function fix_background_color

  Push $0
  StrCpy $R1 1203
  loop:
    GetDlgItem $0 $MUI_HWND $R1
    SetCtlColors $0 "" 0xFFFFFF
    IntOp $R1 $R1 + 1
    IntCmp $R1 1214 done
    Goto loop
  done:

  CreateFont $R1 "Arial" "10" "600" ; bold
  GetDlgItem $0 $MUI_HWND 1205
  SendMessage $0 ${WM_SETFONT} $R1 0
  GetDlgItem $0 $MUI_HWND 1210
  SendMessage $0 ${WM_SETFONT} $R1 0

  CreateFont $R1 "Arial" "7" "0" ; small
  GetDlgItem $0 $MUI_HWND 1211
  SendMessage $0 ${WM_SETFONT} $R1 0
  GetDlgItem $0 $MUI_HWND 1212
  SendMessage $0 ${WM_SETFONT} $R1 0

  CreateFont $R1 "Arial" "7" "0" /UNDERLINE
  GetDlgItem $0 $MUI_HWND 1213
  SendMessage $0 ${WM_SETFONT} $R1 0
  SetCtlColors $0 0x0000FF 0xFFFFFF
  Pop $0
FunctionEnd

Function check_radio_buttons
  StrCmp $ZUGO_COUNTRY "US" 0 end
  ReadINIStr $ZUGO_HOMEPAGE "$PLUGINSDIR\ioSpecial.ini" "Field 8" "State"
  StrCmp $ZUGO_COUNTRY "US" 0 +2 ; skip toolbar options if we're international
  ReadINIStr $ZUGO_TOOLBAR "$PLUGINSDIR\ioSpecial.ini" "Field 9" "State"
  ReadINIStr $ZUGO_DEFAULT_SEARCH "$PLUGINSDIR\ioSpecial.ini" "Field 10" "State"
  StrCmp "$ZUGO_HOMEPAGE$ZUGO_TOOLBAR$ZUGO_DEFAULT_SEARCH" "000" 0 end
  StrCpy $R1 "search toolbar"
  StrCmp "$ZUGO_COUNTRY" "US" +2
  StrCpy $R1 "start page"
  MessageBox MB_YESNO|MB_USERICON|MB_TOPMOST "Help Support Miro!$\r$\n$\r$\nMiro is a non-profit organization, making free and open software for a better internet.  To afford to keep Miro available, we rely on partnerships with search engines.$\r$\n$\r$\nBy trying a Miro $R1, you can support our open mission; we get a bit of revenue for each install.$\r$\n$\r$\nWould you be willing to try this optional $R1? You can uninstall it at any time." IDNO end
  StrCmp "$ZUGO_COUNTRY" "US" +3
  StrCpy $ZUGO_HOMEPAGE "1"
  Goto +2
  StrCpy $ZUGO_TOOLBAR "1"
end:
FunctionEnd

; License page
; !insertmacro MUI_PAGE_LICENSE "license.txt"

; Installation page
!insertmacro MUI_PAGE_INSTFILES

; Finish page
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_TITLE "${CONFIG_LONG_APP_NAME} has been installed!"
!define MUI_FINISHPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_RUN_TEXT "Run ${CONFIG_LONG_APP_NAME}"
!define MUI_FINISHPAGE_RUN_FUNCTION "LaunchLink"
!define MUI_FINISHPAGE_LINK "${CONFIG_PUBLISHER} homepage."
!define MUI_FINISHPAGE_LINK_LOCATION "${CONFIG_PROJECT_URL}"
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM

!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Languages                                                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!insertmacro MUI_LANGUAGE "English" # first language is the default language

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reserve files (interacts with solid compression to speed up installation) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!macro uninstall directory
  ; Remove the program
  Delete   "${directory}\${CONFIG_EXECUTABLE}"
  Delete   "${directory}\${CONFIG_ICON}"
  Delete   "${directory}\*.dll"
  Delete   "${directory}\uninstall.exe"
  Delete   "${directory}\mvc_install.jpg"
  Delete   "${directory}\${CONFIG_EXECUTABLE}.config"
  Delete   "${directory}\lib\*.dll"
  Delete   "${directory}\ffmpeg-bin\ffmpeg.exe"
  Delete   "${directory}\ffmpeg-bin\ffmpeg2theora.exe"
  Delete   "${directory}\ffmpeg-bin\*.ffpreset"

  RMDir /r "${directory}\lib"
  RMDir /r "${directory}\ffmpeg-bin"
  RMDIR ${directory}
!macroend

; Sets $R0 to icon, $R1 to parameters, $R2 to the shortcut name,
; $R3 uninstall shortcut name
Function GetShortcutInfo
  StrCpy $R0 "$INSTDIR\${CONFIG_ICON}"
  StrCpy $R1 ""
  StrCpy $R2 "${RUN_SHORTCUT}"
  StrCpy $R3 "${UNINSTALL_SHORTCUT}"
FunctionEnd

Function LaunchLink
  SetShellVarContext all
  Call GetShortcutInfo
  ExecShell "" "$SMPROGRAMS\$STARTMENU_FOLDER\$R2"
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sections                                                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Section "-${CONFIG_LONG_APP_NAME}"

  ClearErrors
  SetShellVarContext all

  SetOutPath "$INSTDIR"

  File  "${CONFIG_EXECUTABLE}"
  File  "${CONFIG_ICON}"
  File  "*.dll"
  File  "mvc_install.jpg"
  File  "${CONFIG_EXECUTABLE}.config"
  File  /r lib
  File  /r ffmpeg-bin

  IfErrors 0 files_ok

  MessageBox MB_OK|MB_ICONEXCLAMATION "Installation failed.  An error occured writing to the ${CONFIG_SHORT_APP_NAME} Folder."
  Quit
files_ok:
  Call GetShortcutInfo

  CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER"
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\$R2" \
    "$INSTDIR\${CONFIG_EXECUTABLE}" "$R1" "$R0"
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\$R3" \
    "$INSTDIR\uninstall.exe" "$R1"

SectionEnd

Function un.onInit
  StrCpy $STARTMENU_FOLDER "${CONFIG_PUBLISHER}\${CONFIG_LONG_APP_NAME}"
FunctionEnd

Function .onInit
  StrCpy $STARTMENU_FOLDER "${CONFIG_PUBLISHER}\${CONFIG_LONG_APP_NAME}"
  StrCpy $ZUGO_PROVIDER "Bing™"
  StrCpy $ZUGO_TERMS "http://www.startnow.com/terms/bing/"

  ${GetOptions} "$R0" "/FORCEUS" $R1
  IfErrors +4 0
  StrCpy $ZUGO_COUNTRY "US"
  StrCpy $ZUGO_FLAGS "/FORCEUS"
  ClearErrors
  ${GetOptions} "$R0" "/FORCESW" $R1
  IfErrors +3 0
  StrCpy $ZUGO_COUNTRY "SW"
  ClearErrors

  ; get the country Zugo thinks we're in
  StrCmp $ZUGO_COUNTRY "" 0 +8
  NSISdl::download_quiet /TIMEOUT=10000 /NOIEPROXY "http://track.zugo.com/getCountry/" "$PLUGINSDIR\getCountry" /END ; requires content length to be set!
  Pop $R0 ; pop the request status
  ClearErrors
  FileOpen $0 $PLUGINSDIR\getCountry r
  IfErrors +3
  FileRead $0 $ZUGO_COUNTRY
  FileClose $0

FunctionEnd

Function .onInstSuccess
!ifdef MIROBAR_EXE
;StrCmp "$ZUGO_COUNTRY" "US" 0 +2
;StrCpy $ZUGO_FLAGS "$ZUGO_FLAGS /OFFERED"

StrCpy $R1 "0"
StrCmp "$ZUGO_HOMEPAGE" "0" +3
StrCpy $ZUGO_FLAGS "$ZUGO_FLAGS /DEFAULTSTART"
IntOp $R1 $R1 | 1
StrCmp "$ZUGO_TOOLBAR" "0" +3
StrCpy $ZUGO_FLAGS "$ZUGO_FLAGS /TOOLBAR"
IntOp $R1 $R1 | 2
StrCmp "$ZUGO_DEFAULT_SEARCH" "0" +3
StrCpy $ZUGO_FLAGS "$ZUGO_FLAGS /DEFAULTSEARCH"
IntOp $R1 $R1 | 4

StrCmp "$R1" "0" zugo_install
StrCpy $ZUGO_FLAGS "$ZUGO_FLAGS /FINISHURL='http://www.getmiro.com/welcome/?$R1'"

zugo_install:
StrCmp "$ZUGO_FLAGS" "" end

;MessageBox MB_OK "$PLUGINSDIR\${MIROBAR_EXE} $ZUGO_FLAGS"
Exec "$PLUGINSDIR\${MIROBAR_EXE} $ZUGO_FLAGS"
end:
!endif
FunctionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${INST_KEY}" "InstallDir" $INSTDIR
  WriteRegStr HKLM "${INST_KEY}" "Version" "${CONFIG_VERSION}"
  WriteRegStr HKLM "${INST_KEY}" "" "$INSTDIR\${CONFIG_EXECUTABLE}"

  WriteRegStr HKLM "${UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr HKLM "${UNINST_KEY}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${UNINST_KEY}" "DisplayIcon" "$INSTDIR\${CONFIG_EXECUTABLE}"
  WriteRegStr HKLM "${UNINST_KEY}" "DisplayVersion" "${CONFIG_VERSION}"
  WriteRegStr HKLM "${UNINST_KEY}" "URLInfoAbout" "${CONFIG_PROJECT_URL}"
  WriteRegStr HKLM "${UNINST_KEY}" "Publisher" "${CONFIG_PUBLISHER}"

  ; We're Vista compatible now, so drop the compatability crap
  DeleteRegValue HKLM "Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" "$INSTDIR\${CONFIG_EXECUTABLE}"
SectionEnd

Section "Uninstall" SEC91

  SetShellVarContext all

  ${un.GetParameters} $R0

  Delete "$SMPROGRAMS\$STARTMENU_FOLDER\$R0.lnk"
  Delete "$SMPROGRAMS\$STARTMENU_FOLDER\Uninstall $R0.lnk"

  RMDir "$SMPROGRAMS\$STARTMENU_FOLDER"

  ClearErrors

  !insertmacro uninstall $INSTDIR
  RMDIR "$PROGRAMFILES\${CONFIG_PUBLISHER}"

  ; Remove Start Menu shortcuts
  Delete "$SMPROGRAMS\$STARTMENU_FOLDER\${RUN_SHORTCUT}"
  Delete "$SMPROGRAMS\$STARTMENU_FOLDER\${UNINSTALL_SHORTCUT}"
  RMDir "$SMPROGRAMS\$STARTMENU_FOLDER"

  SetAutoClose true
SectionEnd
