; Passed in from command line:
;  CONFIG_VERSION        eg, "0.8.0"

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
!define MUI_ICON "${MIRO_INSTALL_ICON}"
!define MUI_UNICON "${MIRO_INSTALL_ICON}"

!define OLD_INST_KEY "Software\Participatory Culture Foundation\Democracy Player"
!define OLD_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\Democracy Player"
!define OLD_RUN_SHORTCUT1 "Democracy Player.lnk"
!define OLD_RUN_SHORTCUT2 "Democracy.lnk"
!define OLD_UNINSTALL_SHORTCUT1 "Uninstall Democracy Player.lnk"
!define OLD_UNINSTALL_SHORTCUT2 "Uninstall Democracy.lnk"

Name "$APP_NAME"
OutFile "${CONFIG_OUTPUT_FILE}"
InstallDir "$PROGRAMFILES\${CONFIG_PUBLISHER}\${CONFIG_LONG_APP_NAME}"
InstallDirRegKey HKLM "${INST_KEY}" "Install_Dir"
SetCompressor lzma

SetOverwrite ifnewer
CRCCheck on

Icon "${CONFIG_ICON}"

Var STARTMENU_FOLDER
Var APP_NAME ; Used in text within the program
Var REINSTALL
Var ADVANCED
Var SIMPLE_INSTALL
Var PUBLISHER
Var PROJECT_URL
Var ZUGO_HOMEPAGE
Var ZUGO_TOOLBAR
Var ZUGO_DEFAULT_SEARCH
Var ZUGO_FLAGS
Var ZUGO_COUNTRY
Var ZUGO_PROVIDER
Var ZUGO_TERMS

!define MUI_WELCOMEPAGE_TITLE "Welcome to $APP_NAME!"
!define MUI_WELCOMEPAGE_TEXT "To get started, choose an easy or a custom install process and then click 'Install'."

!include "MUI.nsh"
!include "Sections.nsh"
!include zipdll.nsh
!include nsProcess.nsh
!include "TextFunc.nsh"
!include "WordFunc.nsh"
!include "FileFunc.nsh"
!include "WinMessages.nsh"
!include Locate.nsh
!include nsDialogs.nsh

!insertmacro TrimNewLines
!insertmacro WordFind
!insertmacro GetParameters
!insertmacro GetOptions
!insertmacro un.TrimNewLines
!insertmacro un.WordFind
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
!define MUI_WELCOMEFINISHPAGE_BITMAP "${MIRO_INSTALL_IMAGE}"
!insertmacro MUI_PAGE_WELCOME

Function add_radio_buttons
; if no reinstall or advanced, just start right up
  StrCmp "$REINSTALL$ADVANCED" "00" start
  StrCmp $ADVANCED "0" abort ; not advanced, just abort
  StrCpy $SIMPLE_INSTALL "0" ; otherwise, advanced install and then abort
abort:
  Abort
start:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Settings" "NumFields" "14"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Settings" "NextButtonText" "Next >"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 2" "Top" "10"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 2" "Bottom" "28"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 2" "Right" "325"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 3" "Text" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 3" "Top" "35"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 3" "Bottom" "45"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 3" "Right" "325"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 11" "Type"   "label"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 11" "Text"   "Installation Type"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 11" "Left"   "120"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 11" "Right"  "315"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 11" "Top"    "45"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 11" "Bottom" "55"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "Type"   "radiobutton"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "Text"   "Easy Install"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "Left"   "120"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "Right"  "315"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "Top"    "60"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "Bottom" "70"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 5" "Type"   "radiobutton"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 5" "Text"   "Custom Install"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 5" "Left"   "120"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 5" "Right"  "315"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 5" "Top"    "70"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 5" "Bottom" "80"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 13" "Type"   "label"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 13" "Text"   "Options: installation directory and file-type associations."
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 13" "Left"   "132"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 13" "Right"  "315"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 13" "Top"    "80"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 13" "Bottom" "95"

  !ifdef MIROBAR_EXE

  StrCmp "$THEME_NAME" "" 0 after_zugo
!ifdef MOZILLA_INSTALLER
  StrCmp $ZUGO_COUNTRY "US" +5
  StrCpy $ZUGO_TOOLBAR "0"
  StrCpy $ZUGO_DEFAULT_SEARCH "0"
  StrCpy $ZUGO_HOMEPAGE "0"
  Goto after_zugo
!endif
  StrCmp "$ZUGO_TOOLBAR$ZUGO_DEFAULT_SEARCH$ZUGO_HOMEPAGE" "" 0 toolbar_options

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "${MIROBAR_EXE}"
  StrCmp $ZUGO_COUNTRY "US" 0 zugo_int
  ;MessageBox MB_OK "$PLUGINSDIR\${MIROBAR_EXE} /OFFERED /TOOLBAR /DEFAULTSTART /DEFAULTSEARCH $ZUGO_FLAGS"
  Exec "$PLUGINSDIR\${MIROBAR_EXE} /OFFERED /TOOLBAR /DEFAULTSTART /DEFAULTSEARCH $ZUGO_FLAGS"
  StrCpy $ZUGO_TOOLBAR "1"
  StrCpy $ZUGO_DEFAULT_SEARCH "1"
  StrCpy $ZUGO_HOMEPAGE "1"
  Goto toolbar_options
  
zugo_int:
  ;MessageBox MB_OK "$PLUGINSDIR\${MIROBAR_EXE} /OFFERED /DEFAULTSTART /DEFAULTSEARCH $ZUGO_FLAGS"
  Exec "$PLUGINSDIR\${MIROBAR_EXE} /OFFERED /DEFAULTSTART /DEFAULTSEARCH $ZUGO_FLAGS"
  StrCpy $ZUGO_TOOLBAR "0"
  StrCpy $ZUGO_DEFAULT_SEARCH "1"
  StrCpy $ZUGO_HOMEPAGE "1"
  StrCpy $ZUGO_PROVIDER "Yahoo"
  StrCpy $ZUGO_TERMS "http://www.startnow.com/terms/yahoo/"

toolbar_options:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 6" "Type"   "label"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 6" "Text"   "Included Components"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 6" "Left"   "120"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 6" "Right"  "315"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 6" "Top"    "100"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 6" "Bottom" "110"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 7" "Type"   "checkbox"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 7" "Text"   "$APP_NAME core (required)"
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
  StrCmp $SIMPLE_INSTALL "1" simple custom

  custom:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "State"  "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 5" "State"  "1"

  goto end

  simple:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "State"  "1"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 5" "State"  "0"
  goto end

  end:
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
  ReadINIStr $SIMPLE_INSTALL "$PLUGINSDIR\ioSpecial.ini" "Field 4" "State"
!ifdef MOZILLA_INSTALLER
  StrCmp $ZUGO_COUNTRY "US" 0 end
!endif
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

Function skip_if_simple_or_reinstall
  StrCmp $SIMPLE_INSTALL "1" skip_for_simple_or_reinstall
  StrCmp $REINSTALL "1" skip_for_simple_or_reinstall
  goto end
skip_for_simple_or_reinstall:
  Abort
end:
FunctionEnd

Function skip_if_simple
  StrCmp $SIMPLE_INSTALL "1" skip_for_simple
  goto end
  skip_for_simple:
  Abort
  end:
FunctionEnd

Function skip_if_advanced
  StrCmp $ADVANCED "1" skip_for_advanced
  goto end
  skip_for_advanced:
  Abort
  end:
FunctionEnd

; License page
; !insertmacro MUI_PAGE_LICENSE "license.txt"

; Component selection page
!define MUI_COMPONENTSPAGE_TEXT_COMPLIST \
  "Please choose which optional components to install."
!define MUI_PAGE_CUSTOMFUNCTION_PRE   "skip_if_simple_or_reinstall"
!insertmacro MUI_PAGE_COMPONENTS

; Installation directory selection page
!define MUI_PAGE_CUSTOMFUNCTION_PRE   "skip_if_simple_or_reinstall"
!insertmacro MUI_PAGE_DIRECTORY

; Start menu folder name selection page
!define MUI_PAGE_CUSTOMFUNCTION_PRE   "skip_if_simple_or_reinstall"
!insertmacro MUI_PAGE_STARTMENU Application $STARTMENU_FOLDER

; Installation page
!insertmacro MUI_PAGE_INSTFILES


; Finish page
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_TITLE "$APP_NAME has been installed!"
!define MUI_FINISHPAGE_TEXT "$APP_NAME is a non-profit project and is free and open-source software.  Thanks for supporting an open internet!"
!define MUI_FINISHPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_RUN_TEXT "Run $APP_NAME"
!define MUI_FINISHPAGE_RUN_FUNCTION "LaunchLink"
!define MUI_FINISHPAGE_LINK \
  "$PUBLISHER homepage."
!define MUI_FINISHPAGE_LINK_LOCATION "$PROJECT_URL"
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!define MUI_PAGE_CUSTOMFUNCTION_PRE "skip_if_advanced"
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE "dont_leave_early"
Function dont_leave_early
  ReadINIStr $R0 "$PLUGINSDIR\ioSpecial.ini" "Settings" "State"
  StrCmp $R0 "4" dont_leave
  goto end
  dont_leave:
  Abort
  end:
FunctionEnd
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM
UninstPage custom un.pickThemesPage un.pickThemesPageAfter
; defined lower down

!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Languages                                                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!insertmacro MUI_LANGUAGE "English" # first language is the default language
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "TradChinese"
!insertmacro MUI_LANGUAGE "Japanese"
!insertmacro MUI_LANGUAGE "Korean"
!insertmacro MUI_LANGUAGE "Italian"
!insertmacro MUI_LANGUAGE "Dutch"
!insertmacro MUI_LANGUAGE "Danish"
!insertmacro MUI_LANGUAGE "Swedish"
!insertmacro MUI_LANGUAGE "Norwegian"
!insertmacro MUI_LANGUAGE "Finnish"
!insertmacro MUI_LANGUAGE "Greek"
!insertmacro MUI_LANGUAGE "Russian"
!insertmacro MUI_LANGUAGE "Portuguese"
!insertmacro MUI_LANGUAGE "Arabic"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reserve files (interacts with solid compression to speed up installation) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!insertmacro MUI_RESERVEFILE_LANGDLL
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!macro checkExtensionHandled ext sectionName
  Push $0
  ReadRegStr $0 HKCR "${ext}" ""
  StrCmp $0 "" +6
  StrCmp $0 "DemocracyPlayer" +5
  StrCmp $0 "${CONFIG_PROG_ID}" +4
    SectionGetFlags ${sectionName} $0
    IntOp $0 $0 & 0xFFFFFFFE
    SectionSetFlags ${sectionName} $0
  Pop $0
!macroend

; This does the oppsite of checkExtensionHandled
; it enables a section if the extension is already
; handled by Miro
!macro checkExtensionNotHandled ext sectionName
  Push $0
  ReadRegStr $0 HKCU "Software\\Classes\${ext}" ""
  StrCmp $0 "" +3 +6
  StrCmp $0 "DemocracyPlayer" +2 +5
  StrCmp $0 "${CONFIG_PROG_ID}" +1 +4
    SectionGetFlags ${sectionName} $0
    IntOp $0 $0 & 0xFFFFFFFE
    SectionSetFlags ${sectionName} $0
  Pop $0
!macroend

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

!macro GetConfigOptionsMacro trim find
ClearErrors
Push $R0
Push $R1
Push $R2
Push $R3

  FileOpen $R2 "$R1" r
config_loop:
  FileRead $R2 $R1
  IfErrors error_in_config
  ${trim} "$R1" $R1
  StrLen $R3 $R0
  StrCpy $R4 $R1 $R3
  StrCmp $R4 $R0 done_config_loop
  Goto config_loop
done_config_loop:
  FileClose $R2

  ${find} "$R1" "=" "+1}" $R0

trim_spaces_loop:
  StrCpy $R2 $R0 1
  StrCmp $R2 " " 0 done_config
  StrCpy $R0 "$R0" "" 1
  Goto trim_spaces_loop

error_in_config:
  StrCpy $R0 ""
  FileClose $R2
  ClearErrors

done_config:
Pop $R3
Pop $R2
Pop $R1
Exch $R0
!macroend

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Author: Lilla (lilla@earthlink.net) 2003-06-13
; function IsUserAdmin uses plugin \NSIS\PlusgIns\UserInfo.dll
; This function is based upon code in \NSIS\Contrib\UserInfo\UserInfo.nsi
; This function was tested under NSIS 2 beta 4 (latest CVS as of this writing).
;
; Removed a bunch of comments --Ben
;
; Usage:
;   Call IsUserAdmin
;   Pop $R0   ; at this point $R0 is "true" or "false"
;
Function IsUserAdmin
  Push $R0
  Push $R1
  Push $R2

  ClearErrors
  UserInfo::GetName
  IfErrors Win9x
  Pop $R1
  UserInfo::GetAccountType
  Pop $R2

  StrCmp $R2 "Admin" 0 Continue
  ; Observation: I get here when running Win98SE. (Lilla)
  ; The functions UserInfo.dll looks for are there on Win98 too,
  ; but just don't work. So UserInfo.dll, knowing that admin isn't required
  ; on Win98, returns admin anyway. (per kichik)
  StrCpy $R0 "true"
  Goto Done

  Continue:
  ; You should still check for an empty string because the functions
  ; UserInfo.dll looks for may not be present on Windows 95. (per kichik)
  StrCmp $R2 "" Win9x
  StrCpy $R0 "false"
  Goto Done

  Win9x:
  StrCpy $R0 "true"

  Done:
  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd

; Set $R0 to the config option and $R1 to the config file name
; puts the value of the config option on the stack
Function GetConfigOption
  !insertmacro GetConfigOptionsMacro "${TrimNewLines}" "${WordFind}"
FunctionEnd
Function un.GetConfigOption
  !insertmacro GetConfigOptionsMacro "${un.TrimNewLines}" "${un.WordFind}"
FunctionEnd

; Set $R0 to the theme directory
; Returns the theme version string
Function GetThemeVersion
  Push $R0
  Push $R1
  Push $R2

  FileOpen $R1 "$R0\version.txt" r
  IfErrors errors_in_version
  FileRead $R1 $R0
  FileClose $R1
  ${TrimNewLines} "$R0" $R0
  Goto done_version

errors_in_version:
  StrCpy $R0 ""
done_version:
  Push $R2
  Push $R1
  Exch $R0
FunctionEnd

; Sets $R0 to icon, $R1 to parameters, $R2 to the shortcut name,
; $R3 uninstall shortcut name
Function GetShortcutInfo
  StrCpy $R0 "$INSTDIR\${CONFIG_ICON}"
  StrCpy $R1 ""
  StrCpy $R2 "${RUN_SHORTCUT}"
  StrCpy $R3 "${UNINSTALL_SHORTCUT}"

  StrCmp $THEME_NAME "" done
  ; theme specific icons
  StrCpy $R0 "longAppName"
  StrCpy $R1 "$THEME_TEMP_DIR\app.config"
  Call GetConfigOption
  Pop $R0
  StrCpy $R2 "$R0.lnk"
  StrCpy $R3 "Uninstall $R0.lnk"

  StrCpy $R1 "--theme $\"$THEME_NAME$\""

  Push $R1
  StrCpy $R0 "windowsIcon"
  StrCpy $R1 "$THEME_TEMP_DIR\app.config"
  Call GetConfigOption
  Pop $R0
  Pop $R1
  StrCmp $R0 "" done
  StrCpy $R0 "$APPDATA\Participatory Culture Foundation\Miro\Themes\$THEME_NAME\$R0"

done:

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

; Warn users of Windows 9x/ME that they're not supported
  Push $R0
  ClearErrors
  ReadRegStr $R0 HKLM \
    "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
  IfErrors 0 lbl_winnt
  MessageBox MB_ICONEXCLAMATION \
     "WARNING: $APP_NAME is not officially supported on this version of Windows$\r$\n$\r$\nVideo playback is known to be broken, and there may be other problems"
lbl_winnt:

  Pop $R0

  Call IsUserAdmin
  Pop $R0
  StrCmp $R0 "true" is_admin
  MessageBox MB_OK|MB_ICONEXCLAMATION "You must have administrator privileges to install $APP_NAME.  Please log in using an administrator account and try again."
  Quit

is_admin:
  !insertmacro clear_out_old_xulrunner $INSTDIR

  SetShellVarContext all

  SetOutPath "$INSTDIR"

StrCmp $ONLY_INSTALL_THEME "1" install_theme

!if ${CONFIG_TWOSTAGE} = "Yes"

  InetLoad::load http://ftp.osuosl.org/pub/pculture.org/democracy/win/${CONFIG_SHORT_APP_NAME}-Contents-${CONFIG_VERSION}.zip "$INSTDIR\${CONFIG_SHORT_APP_NAME}-Contents.zip"
  Pop $0
  StrCmp $0 "OK" dlok
  MessageBox MB_OK|MB_ICONEXCLAMATION "Download Error, click OK to abort installation: $0" /SD IDOK
  Abort
dlok:
  !insertmacro ZIPDLL_EXTRACT "$INSTDIR\${CONFIG_SHORT_APP_NAME}-Contents.zip" $INSTDIR <ALL>
  Delete "$INSTDIR\${CONFIG_SHORT_APP_NAME}-Contents.zip"
  Pop $0
  StrCmp $0 "success" unzipok
  MessageBox MB_OK|MB_ICONEXCLAMATION "Unzip error, click OK to abort installation: $0" /SD IDOK
  Abort
unzipok:

!else

  File  "${CONFIG_EXECUTABLE}"
  File  "${CONFIG_ICON}"
  File  "*.dll"
  File  "mvc_install.jpg"
  File  "${CONFIG_EXECUTABLE}.config"
  File  /r lib
  File  /r ffmpeg-bin
!endif

SectionEnd

Section "Desktop icon" SecDesktop
  Call GetShortcutInfo
  CreateShortcut "$DESKTOP\$R2" "$INSTDIR\${CONFIG_EXECUTABLE}" \
    "$R1" "$R0"
SectionEnd

Section /o "Quick launch icon" SecQuickLaunch
  Call GetShortcutInfo
  CreateShortcut "$QUICKLAUNCH\$R2" "$INSTDIR\${CONFIG_EXECUTABLE}" \
    "$R1" "$R0"
SectionEnd

Function un.onInit
  StrCpy $APP_NAME "${CONFIG_LONG_APP_NAME}"
  StrCpy $PUBLISHER "${CONFIG_PUBLISHER}"
FunctionEnd

Function .onInit
  ; Process the tacked on file
  StrCpy $THEME_NAME ""
  StrCpy $INITIAL_FEEDS ""
  StrCpy $ONLY_INSTALL_THEME ""
  StrCpy $THEME_TEMP_DIR ""
  StrCpy $APP_NAME "${CONFIG_LONG_APP_NAME}"
  StrCpy $REINSTALL "0"
  StrCpy $ADVANCED "0"
  StrCpy $SIMPLE_INSTALL "1"
  StrCpy $PUBLISHER "${CONFIG_PUBLISHER}"
  StrCpy $PROJECT_URL "${CONFIG_PROJECT_URL}"
  StrCpy $ZUGO_PROVIDER "Bing™"
  StrCpy $ZUGO_TERMS "http://www.startnow.com/terms/bing/"

  ; If it's already installed, change install dir to the current installation directroy.
  ReadRegStr $R0 HKLM "${INST_KEY}" "InstallDir"
  StrCmp $R0 "" SkipChangingInstDir
  StrCpy $INSTDIR $R0
SkipChangingInstDir:

  ; Check if we're reinstalling
  ${GetParameters} $R0
  ${GetOptions} "$R0" "/ADVANCED" $R1
  IfErrors +3 0
  SetSilent normal
  StrCpy $ADVANCED "1"
  ${GetOptions} "$R0" "/reinstall" $R1
  IfErrors +2 0
  StrCpy $REINSTALL "1"
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

  Call GetConfigOption
  Pop $APP_NAME

  Goto MoreAttributes

MoreAttributes:
  StrCpy $R0 "publisher"
  Call GetConfigOption
  Pop $0
  StrCmp $0 "" find_project_url
  StrCpy $PUBLISHER $0
  StrCpy $INSTDIR "$PROGRAMFILES\$PUBLISHER\$APP_NAME"
find_project_url:
  StrCpy $0 "projectURL"
  Call GetConfigOption
  Pop $0
  StrCmp $0 "" TestRunning
  StrCpy $PROJECT_URL $0


  ; Is the app running?  Stop it if so.
TestRunning:
  ${nsProcess::FindProcess} "MiroConverter.exe" $R0
  StrCmp $R0 0 0 NotRunning
  StrCmp $REINSTALL 1 0 ShowCloseBox
  Sleep 2000
  Goto TestRunning
ShowCloseBox:
  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
  "It looks like you're already running $APP_NAME.$\n\
Please shut it down before continuing." \
       IDOK TestRunning
  Quit
NotRunning:

NotCurrentInstalled:
  ; Is the app already installed? Bail if so.
  ReadRegStr $R0 HKLM "${OLD_INST_KEY}" "InstallDir"
  StrCmp $R0 "" NotOldInstalled
  !insertmacro uninstall $R0

  SetShellVarContext current
  ; Remove Start Menu shortcuts
  Delete "$SMPROGRAMS\Democracy Player\${OLD_RUN_SHORTCUT1}"
  Delete "$SMPROGRAMS\Democracy Player\${OLD_RUN_SHORTCUT2}"
  Delete "$SMPROGRAMS\Democracy Player\${OLD_UNINSTALL_SHORTCUT1}"
  Delete "$SMPROGRAMS\Democracy Player\${OLD_UNINSTALL_SHORTCUT2}"
  RMDir "$SMPROGRAMS\Democracy Player"

  ; Remove desktop and quick launch shortcuts
  Delete "$DESKTOP\${OLD_RUN_SHORTCUT1}"
  Delete "$DESKTOP\${OLD_RUN_SHORTCUT2}"
  Delete "$QUICKLAUNCH\${OLD_RUN_SHORTCUT1}"
  Delete "$QUICKLAUNCH\${OLD_RUN_SHORTCUT2}"

  SetShellVarContext all
  ; Remove Start Menu shortcuts
  Delete "$SMPROGRAMS\Democracy Player\${OLD_RUN_SHORTCUT1}"
  Delete "$SMPROGRAMS\Democracy Player\${OLD_RUN_SHORTCUT2}"
  Delete "$SMPROGRAMS\Democracy Player\${OLD_UNINSTALL_SHORTCUT1}"
  Delete "$SMPROGRAMS\Democracy Player\${OLD_UNINSTALL_SHORTCUT2}"
  RMDir "$SMPROGRAMS\Democracy Player"

  ; Remove desktop and quick launch shortcuts
  Delete "$DESKTOP\${OLD_RUN_SHORTCUT1}"
  Delete "$DESKTOP\${OLD_RUN_SHORTCUT2}"
  Delete "$QUICKLAUNCH\${OLD_RUN_SHORTCUT1}"
  Delete "$QUICKLAUNCH\${OLD_RUN_SHORTCUT2}"

  SetShellVarContext current

  ; Remove registry keys
  DeleteRegKey HKLM "${OLD_INST_KEY}"
  DeleteRegKey HKLM "${OLD_UNINST_KEY}"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "Democracy Player"
  DeleteRegKey HKCR "Democracy.Player.1"

NotOldInstalled:
  ; Check if an old version is present, but no registry key exists
  ; Check for uninstall.exe.  That filename should be constant for all
  ; versions and themes.

  IfFileExists "$INSTDIR\uninstall.exe" 0 StartInstall
  !insertmacro uninstall $INSTDIR

StartInstall:
  StrCmp $REINSTALL "1" SkipLanguageDLL
  StrCmp "$ADVANCED" "1" SkipLanguageDLL
  !insertmacro MUI_LANGDLL_DISPLAY
SkipLanguageDLL:

  ; Make check boxes for unhandled file extensions.


  !insertmacro checkExtensionHandled ".torrent" ${SecRegisterTorrent}

  StrCpy $R0 "alwaysRegisterTorrents"
  StrCpy $R1 "$THEME_TEMP_DIR\app.config"
  Call GetConfigOption
  Pop $R0
  StrCmp $R0 "" DoneTorrentRegistration
  SectionGetFlags ${SecRegisterTorrent} $0
  IntOp $0 $0 | 17  ; Set register .torrents to selected and read only
  SectionSetFlags ${SecRegisterTorrent} $0

FunctionEnd

Function .onInstSuccess
  StrCmp $THEME_NAME "" 0 end
  StrCmp $REINSTALL "1" end
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
!endif

end:
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
  WriteRegStr HKLM "${UNINST_KEY}" "URLInfoAbout" "$PROJECT_URL"
  WriteRegStr HKLM "${UNINST_KEY}" "Publisher" "$PUBLISHER"

  ; We're Vista compatible now, so drop the compatability crap
  DeleteRegValue HKLM "Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" "$INSTDIR\${CONFIG_EXECUTABLE}"
SectionEnd

Section "Uninstall" SEC91

  SetShellVarContext all

  ${un.GetParameters} $R0
  ${un.GetOptions} "$R0" "--theme" $THEME_NAME
  IfErrors continue

  StrCmp "$THEME_NAME" "" continue

  StrCpy $R0 "longAppName"
  StrCpy $R1 "$APPDATA\Participatory Culture Foundation\Miro\Themes\$THEME_NAME\app.config"
  Call un.GetConfigOption
  Pop $R0
  Delete "$APPDATA\Participatory Culture Foundation\Miro\Themes\$THEME_NAME\*.*"
  RMDir "$APPDATA\Participatory Culture Foundation\Miro\Themes\$THEME_NAME"

  !insertmacro MUI_STARTMENU_GETFOLDER Application $R1
  Delete "$SMPROGRAMS\$R1\$R0.lnk"
  Delete "$SMPROGRAMS\$R1\Uninstall $R0.lnk"

  Delete "$DESKTOP\$R0.lnk"
  Delete "$QUICKLAUNCH\$R0.lnk"

  RMDir "$SMPROGRAMS\$R1"

continue:
  ClearErrors

  !insertmacro uninstall $INSTDIR
  RMDIR "$PROGRAMFILES\$PUBLISHER"

  ; Remove Start Menu shortcuts
  !insertmacro MUI_STARTMENU_GETFOLDER Application $R0
  Delete "$SMPROGRAMS\$R0\${RUN_SHORTCUT}"
  Delete "$SMPROGRAMS\$R0\${UNINSTALL_SHORTCUT}"
  RMDir "$SMPROGRAMS\$R0"

  ; Remove desktop and quick launch shortcuts
  Delete "$DESKTOP\${RUN_SHORTCUT}"
  Delete "$QUICKLAUNCH\${RUN_SHORTCUT}"

  ; Remove registry keys
  DeleteRegKey HKLM "Software\${CONFIG_PUBLISHER}"
  DeleteRegKey HKCU  "Software\${CONFIG_PUBLISHER}"
  DeleteRegKey HKLM "${UNINST_KEY}"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "${CONFIG_LONG_APP_NAME}"
  DeleteRegKey HKCR "${CONFIG_PROG_ID}"

done:
  SetAutoClose true
SectionEnd
