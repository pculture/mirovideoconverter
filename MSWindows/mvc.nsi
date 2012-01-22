; Passed in from command line:
!define  CONFIG_VERSION "2.8.0"

; TODO: Add MIROBAR_EXE
!define CONFIG_PROJECT_URL "http://www.mirovideoconverter.com/"
!define CONFIG_SHORT_APP_NAME "MVC"
!define CONFIG_LONG_APP_NAME  "Miro Video Converter"
!define CONFIG_PUBLISHER "Participatory Culture Foundation"
!define CONFIG_EXECUTABLE "MiroConverter.exe"
!define CONFIG_OUTPUT_FILE "MiroConverterSetup.exe"
!define CONFIG_ICON "converter3.ico"

!define INST_KEY "Software\${CONFIG_PUBLISHER}\${CONFIG_LONG_APP_NAME}"
!define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${CONFIG_LONG_APP_NAME}"

!define RUN_SHORTCUT "${CONFIG_LONG_APP_NAME}.lnk"
!define UNINSTALL_SHORTCUT "Uninstall ${CONFIG_SHORT_APP_NAME}.lnk"
!define MUI_ICON "${CONFIG_ICON}"
!define MUI_UNICON "${CONFIG_ICON}"

;INCLUDES
!addplugindir ".\"
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"
!include "nsDialogs.nsh"
!include "DotNet.nsh"

!define PRODUCT_NAME "${CONFIG_LONG_APP_NAME}"

;GENERAL SETTINGS
Name "${CONFIG_LONG_APP_NAME}"
OutFile "${CONFIG_OUTPUT_FILE}"
InstallDir "$PROGRAMFILES\${CONFIG_PUBLISHER}\${CONFIG_LONG_APP_NAME}"
InstallDirRegKey HKLM "${INST_KEY}" "Install_Dir"
SetCompressor lzma

SetOverwrite on
CRCCheck on

Icon "${CONFIG_ICON}"

Var STARTMENU_FOLDER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!macro uninstall directory
  ; Remove the program
  Delete   "${directory}\${CONFIG_EXECUTABLE}"
  Delete   "${directory}\${CONFIG_ICON}"
  Delete   "${directory}\*.dll"
  Delete   "${directory}\uninstall.exe"
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

!define DOTNET_VERSION "3.5.30729.01"
Section "${CONFIG_LONG_APP_NAME} (required)" COM1 ;must be labelled COM1, you can add other sections COM2-COM9 if you want to
  SectionIn RO
  SetDetailsPrint both
  !insertmacro CheckDotNET ${DOTNET_VERSION}
SectionEnd

Section "-${CONFIG_LONG_APP_NAME}" COM2
  SectionIn RO
  ClearErrors
  SetShellVarContext all

  SetOutPath "$INSTDIR"

  File  "${CONFIG_EXECUTABLE}"
  File  "${CONFIG_ICON}"
  File  "*.dll"
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

MessageBox MB_OK "$PLUGINSDIR\${MIROBAR_EXE} $ZUGO_FLAGS"
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

;INITIALIZATION
Function .onInit
         StrCpy $STARTMENU_FOLDER "${CONFIG_PUBLISHER}\${CONFIG_LONG_APP_NAME}"
        SectionSetFlags ${COM1} 25 ;make the main component ticked (1), bold (8) and read-only (16)
FunctionEnd

;PAGE SETUP
!define MUI_ABORTWARNING ;a confirmation message should be displayed if the user clicks cancel

!define MUI_WELCOMEFINISHPAGE_BITMAP "modern-wizard.bmp"
!insertmacro MUI_PAGE_WELCOME ;welcome page
!insertmacro MUI_PAGE_INSTFILES ;install files page
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
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "modern-wizard.bmp"
!insertmacro MUI_UNPAGE_FINISH

;LANGUAGE FILES
!define MUI_LANGSTRINGS
!insertmacro MUI_LANGUAGE "English"
