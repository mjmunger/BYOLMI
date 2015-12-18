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
OutFile "byolmi-x64.exe"

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

Page custom nsDialogsPage nsDialogsPageLeave
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
  ${NSD_GetText} $VPNIP $2
  ${NSD_GetText} $TincNetwork $3

  StrCpy $Name $0
  StrCpy $IP $1
  StrCpy $VPNIP $2
  StrCpy $TincNetwork $3

FunctionEnd
;--------------------------------

; The stuff to install
Section "" ;No components page, name is not important

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR

  File libeay32.dll
  File libiconv2.dll
  File libintl3.dll
  File libssl32.dll
  File PSCP.EXE
  File setup.inf
  File UltraVNC_1_2_09_X64_Setup.exe
  File changeVPNAdapter.vbs
  File webservices\tinc.conf

  ;SETUP UVNC
  ExecWait '$INSTDIR\UltraVNC_1_2_09_X64_Setup.exe /VERYSILENT /LOADINF="$INSTDIR\setup.inf"' 

  ;Copy the ini file to the UltraVNC dir.
  SetOutPath $INSTDIR\UltraVNC
  File UltraVNC.ini

  DetailPrint "Stopping uvnc server"
  ExecWait "net stop uvnc_service"
  DetailPrint "Starting uvnc server"
  ExecWait "net start uvnc_service"

; SETUP TINC

  ;Setup output path to the tinc dir in program files.
  ExpandEnvStrings $0 "C:\Program Files"
  SetOutPath "$0\tinc"

  File tap\addtap.bat
  File tap\OemWin2k.inf
  File tap\tap0901.cat
  File tap\tap0901.sys
  File tap\tapinstall.exe
  File tincd.exe
  File nets.boot

  DetailPrint "Installing VPN Adapter"
  ExecWait "$0\tinc\addtap.bat"

  DetailPrint "Setting up cscript preferences"
  ExecWait "cscript //h:cscript //s"

  DetailPrint "Changing adapter name to VPN"
  ExecWait "cscript $INSTDIR\changeVPNAdapter.vbs"

  DetailPrint "Setting VPN adapter address to $IP"
  ExecWait 'netsh interface ip set address name="VPN" static $IP 255.255.255.0'
  
  SetOutPath "$0\tinc\webservices\hosts"
  File webservices\hosts\webservices
  
  SetOutPath "$0\tinc\webservices\"
  
  ExecWait "$0\tinc\tincd.exe -K" 

  FileOpen $9 "$0\tinc\webservices\tinc.conf" w
  FileOpen $8 "$INSTDIR\tinc.conf" r

  FileWrite $9 "Name=$Name$\n"
  DetailPrint "Name=$Name"
  FileWrite $9 "Subnet=$IP$\n"  
  DetailPrint "Subnet=$IP"  
  ClearErrors

LOOP1:
  IfErrors exit_conf_loop
  FileRead $8 $7
  DetailPrint $7
  FileWrite $9 $7
  Goto LOOP1
exit_conf_loop:
  FileClose $9
  FileClose $8

  SetOutPath "$0\tinc"

  CopyFiles "$0\tinc\rsa_key.priv" "$0\tinc\webservices\rsa_key.priv"

  ;Read the public key file so we can append information to it to put it in the hosts file.

  ;Open the output file that will hold the host information.

  ;Open the dest file.
  FileOpen $9 "$0\tinc\webservices\hosts\$Name" w

  ;Open the generated key so we can read it into the dest file after we put the stuff in there.
  FileOpen $8 "$0\tinc\rsa_key.pub" r

  IfErrors fileerrors
  FileWrite $9 "Name=$Name$\n"
  FileWrite $9 "Subnet=$IP"
  ClearErrors
LOOP2:
  IfErrors exit_loop
  FileRead $8 $7
  DetailPrint $7
  FileWrite $9 $7
  Goto LOOP2
exit_loop:
  FileClose $9
  FileClose $8
  Goto done
fileerrors:
  DetailPrint "There was an error setting up the public host key for $Name"
done:


  ;Copy the key to the server.
  ExecWait '$INSTDIR\pscp.exe "$0\tinc\webservices\hosts\$Name" root@$VPNIP:/etc/tinc/webservices/hosts'

  ExecWait "$0\tinc\tincd.exe -n webservices"

  ;Setup the firewall
  ExecWait 'netsh advfirewall firewall add rule name="Webservices" dir=in action=allow enable=yes remoteip=192.168.98.0/24'

SectionEnd ; end the section