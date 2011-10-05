# DotNET and MSI version checking macro.
# Written by AnarkiNet(AnarkiNet@gmail.com) originally
# modified by eyal0 in 2007 and sevenalive in 2010
# Installs the Microsoft .NET Framework version 3.5 SP1 if the required .NET runtime is not installed
# To use, call the macro with a string:
# Example: non real version numbers
#   !insertmacro CheckDotNET 3.5
#   !insertmacro CheckDotNET 3.5sp1
# (Version 2.0.9 is less than version 2.0.10.)
# Example: latest real version number at time of writing
# !insertmacro CheckDotNET "2.0.50727"
# All register variables are saved and restored by CheckDotNet
# No output
 Var DN3Dir
 Var dotnet3 ; is .NET 3 installed?
 Var dotnet35 ; is .NET 3.5 installed?
 Var dotnet35ver ; 3.5 version
 Var dotnet35sp1 ; sp1
!macro CheckDotNET DotNetReqVer
  !define DOTNET_URL "http://download.microsoft.com/download/2/0/e/20e90413-712f-438c-988e-fdaa79a8ac3d/dotnetfx35.exe"
  DetailPrint "Checking your .NET Framework version..."
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $5
  Push $6 ;backup of intsalled ver
  Push $7 ;backup of DoNetReqVer
 
# NSIS
 
  ReadRegStr $dotnet3 HKEY_LOCAL_MACHINE "Software\Microsoft\NET Framework Setup\NDP\v3.0\Setup" "InstallSuccess"
  ReadRegStr $dotnet35 HKEY_LOCAL_MACHINE "Software\Microsoft\NET Framework Setup\NDP\v3.5" "Install"
  ReadRegStr $dotnet35ver HKEY_LOCAL_MACHINE "Software\Microsoft\NET Framework Setup\NDP\v3.5" "Version"
  ReadRegStr $dotnet35sp1 HKEY_LOCAL_MACHINE "Software\Microsoft\NET Framework Setup\NDP\v3.5" "SP"
  StrCpy $7 ${DotNetReqVer}
 
  System::Call "mscoree::GetCORVersion(w .r0, i ${NSIS_MAX_STRLEN}, *i r2r2) i .r1 ?u"
  DetailPrint ".NET Framework Version $0 found"
  ${If} $0 == 0
        DetailPrint ".NET Framework not found, download is required for program to run."
    Goto NoDotNET
  ${EndIf}
  ${If} $0 == ""
        DetailPrint ".NET Framework not found, download is required for program to run."
    Goto NoDotNET
  ${EndIf}
 
  ;at this point, $0 has maybe v2.345.678.
  StrCpy $0 $0 $2 1 ;remove the starting "v", $0 has the installed version num as a string
  StrCpy $6 $0
  StrCpy $1 $7 ;$1 has the requested verison num as a string
 
  ;now let's compare the versions, installed against required <part0>.<part1>.<part2>.
  ${Do}
    StrCpy $2 "" ;clear out the installed part
    StrCpy $3 "" ;clear out the required part
 
    ${Do}
      ${If} $0 == "" ;if there are no more characters in the version
        StrCpy $4 "." ;fake the end of the version string
      ${Else}
        StrCpy $4 $0 1 0 ;$4 = character from the installed ver
        ${If} $4 != "."
          StrCpy $0 $0 ${NSIS_MAX_STRLEN} 1 ;remove that first character from the remaining
        ${EndIf}
      ${EndIf}
 
      ${If} $1 == ""  ;if there are no more characters in the version
        StrCpy $5 "." ;fake the end of the version string
      ${Else}
        StrCpy $5 $1 1 0 ;$5 = character from the required ver
        ${If} $5 != "."
          StrCpy $1 $1 ${NSIS_MAX_STRLEN} 1 ;remove that first character from the remaining
        ${EndIf}
      ${EndIf}
      ${If} $4 == "."
      ${AndIf} $5 == "."
        ${ExitDo} ;we're at the end of the part
      ${EndIf}
 
      ${If} $4 == "." ;if we're at the end of the current installed part
        StrCpy $2 "0$2" ;put a zero on the front
      ${Else} ;we have another character
        StrCpy $2 "$2$4" ;put the next character on the back
      ${EndIf}
      ${If} $5 == "." ;if we're at the end of the current required part
        StrCpy $3 "0$3" ;put a zero on the front
      ${Else} ;we have another character
        StrCpy $3 "$3$5" ;put the next character on the back
      ${EndIf}
    ${Loop}
 
    ${If} $0 != "" ;let's remove the leading period on installed part if it exists
      StrCpy $0 $0 ${NSIS_MAX_STRLEN} 1
    ${EndIf}
    ${If} $1 != "" ;let's remove the leading period on required part if it exists
      StrCpy $1 $1 ${NSIS_MAX_STRLEN} 1
    ${EndIf}
 
    ;$2 has the installed part, $3 has the required part
    ${If} $2 S< $3
      IntOp $0 0 - 1 ;$0 = -1, installed less than required
      ${ExitDo}
    ${ElseIf} $2 S> $3
      IntOp $0 0 + 1 ;$0 = 1, installed greater than required
      ${ExitDo}
    ${ElseIf} $2 == ""
    ${AndIf} $3 == ""
      IntOp $0 0 + 0 ;$0 = 0, the versions are identical
      ${ExitDo}
    ${EndIf} ;otherwise we just keep looping through the parts
  ${Loop}
  ;check to see if v3 and/or v3.5 is installed
 
 
  ${If} $0 < 0
    ${If} $dotnet3 == "1"
          DetailPrint ".NET Framework Version 3 found"
          ${If} $dotnet35 == "1"
                DetailPrint ".NET Framework Version 3.5 found"
                             ${If} $dotnet35sp1 != "1"
                                  DetailPrint "SP1 needed. Installing..."
                                  Goto DownloadDotNET
                            ${EndIf}
                DetailPrint ".NET Framework Version 3.5 SP1 found"
                Goto NewDotNET
          ${EndIf}
    ${EndIf}
    DetailPrint ".NET Framework Version found: $6, but is older than the required version: $7"
    Goto OldDotNET
  ${Else}
    DetailPrint ".NET Framework Version found: $6, equal or newer to required version: $7."
    Goto NewDotNET
  ${EndIf}
 
NoDotNET:
    goto DownloadDotNET
OldDotNET:
    ReadRegStr $DN3Dir HKLM "SOFTWARE\Microsoft\.NETFramework" "InstallRoot"
    StrCpy $DN3Dir "$DN3Dir\v3.5\csc.exe"
 
    IfFileExists $DN3Dir NewDotNET
    goto DownloadDotNET
 
DownloadDotNET:
  DetailPrint "Beginning download of latest .NET Framework version."
  inetc::get /TIMEOUT=30000 ${DOTNET_URL} "$TEMP\dotnetfx35.exe" /END
  Pop $0
  DetailPrint "Result: $0"
  StrCmp $0 "OK" InstallDotNet
  StrCmp $0 "cancelled" GiveUpDotNET
  inetc::get /TIMEOUT=30000 /NOPROXY ${DOTNET_URL} "$TEMP\dotnetfx35.exe" /END
  Pop $0
  DetailPrint "Result: $0"
  StrCmp $0 "OK" InstallDotNet
 
  MessageBox MB_ICONSTOP "Download failed: $0"
  Abort
  InstallDotNet:
  DetailPrint "Completed download."
  Pop $0
  ${If} $0 == "cancel"
    MessageBox MB_YESNO|MB_ICONEXCLAMATION \
    "Download cancelled.  Continue Installation?" \
    IDYES NewDotNET IDNO GiveUpDotNET
  ${EndIf}
;  TryFailedDownload:
  DetailPrint "Pausing installation while downloaded .NET Framework installer runs."
  ExecWait '$TEMP\dotnetfx35.exe /q /norestart /c:"install /q"'
  DetailPrint "Completed .NET Framework install/update. Removing .NET Framework installer."
  Delete "$TEMP\dotnetfx35.exe"
  DetailPrint ".NET Framework installer removed."
  goto NewDotNet
 
GiveUpDotNET:
  Abort "Installation cancelled by user."
 
NewDotNET:
  Pop $7
  Pop $6
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Pop $0
!macroend