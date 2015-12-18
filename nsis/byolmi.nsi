!include LogicLib.nsh
!include nsDialogs.nsh
; BYOLMI
;
; This script is perhaps one of the simplest NSIs you can make. All of the
; optional settings are left to their default settings. The installer simply 
; prompts the user asking them where to install, and drops a copy of example1.nsi
; there. 

;--------------------------------

; The name of the installer
Name "BYOLMI"

; The file to write
OutFile "byolmi.exe"

; The default installation directory
InstallDir C:\BYOLMI

; Request application privileges for Windows Vista
RequestExecutionLevel admin


;--------------------------------

; Pages
Var Dialog
Var Label
Var Name
Var IP
Var VPNIP
Var TincNetwork

Page custom nsDialogsPage 
Page directory
Page instfiles

;--------------------------------
Function nsDialogsPage
  nsDialogs::Create 1018
  Pop $Dialog
  ${IF} $Dialog == error
    Abort
  ${EndIf}

  ;Machine Name
  ${NSD_CreateLabel} 0 0 50% 12u "Enter your machine name"
  Pop $Label

  ${NSD_CreateText} 50% 0 50% 12u ""
  Pop $Name

  ;VPN IP Address
  ${NSD_CreateLabel} 0 12u 50% 12u "Enter the assigned VPN IP address"
  Pop $Label

  ${NSD_CreateText} 50% 12u 50% 12u "192.168.98."
  Pop $IP

  ;VPN Endpoint
  ${NSD_CreateLabel} 0 24u 50% 12u "VPN hub endpoint IP address or URL"
  Pop $Label

  ${NSD_CreateText} 50% 24u 50% 12u ""
  Pop $VPNIP

  ;Network Name
  ${NSD_CreateLabel} 0 36u 50% 12u "Tinc Network to Join"
  Pop $Label

  ${NSD_CreateText} 50% 36u 50% 12u ""
  Pop $TincNetwork

  nsDialogs::SHow
FunctionEnd

Function nsDialogsPageLeave
  ${NSD_GetText} $Name $0
  ${NSD_GetText} $IP $1
  MessageBox MB_OK "Your machine ($0)"
FunctionEnd
;--------------------------------

; The stuff to install
Section "" ;No components page, name is not important

  DetailPrint "Hellow world"

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR

  File OemWin2k.inf
  File tap0901.cat
  File tap0901.sys
  File tapinstall.exe
  File tincd.exe
  File libeay32.dll
  File libiconv2.dll
  File libintl3.dll
  File libssl32.dll
  File PSCP.EXE
  File setup.inf
  File UltraVNC_1_2_09_X64_Setup.exe

  ExecWait "$INSTDIR\tincd.exe -K" 
  ExecWait "$INSTDIR\UltraVNC_1_2_09_X64_Setup.exe /versilent /loadinf=setup.inf" 

  ;Copy the ini file to the UltraVNC dir.
  SetOutPath $INSTDIR\UltraVNC
  File UltraVNC.ini


  ; Put file there
  ;File example1.nsi
  
SectionEnd ; end the section

