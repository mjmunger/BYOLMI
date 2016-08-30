!include LogicLib.nsh
!include nsDialogs.nsh
!include WinVer.nsh
!include ReplaceSubStr.nsh

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
OutFile "byolmi-x86.exe"

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
Var BootstrapURL
Var NetworkName
Var TincNetwork
Var TincNetmask
Var TincPort
Var UnwantedGuest

Page custom nsDialogsPage nsDialogsPageLeave
Page directory
Page components
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

Function .onInit

  ${If} ${AtLeastWinXP}
      System::Alloc 36
      pop $0
      ${If} $0 <> 0
          System::Call 'kernel32::GetNativeSystemInfo(i $0)'
          System::Call "*$0(&i2.r1)"
          ${If} $0 == 0
            MessageBox mb_ok "You're trying to run the x86 version of this installer on an x64 system. Install byolmi-x86 instead. (Code: $0)"
            Abort "Cannot Install."
          ${EndIf}
          System::Free $0
      ${EndIf}
  ${EndIf}

  ReadRegStr $0 HKLM "System\CurrentControlSet\Control\ComputerName\ActiveComputerName" "ComputerName"
  StrCmp $0 "" win9x
  StrCpy $1 $0 4 3
  StrCpy $Name $0
  goto done
win9x:
  ReadRegStr $0 HKLM "System\CurrentControlSet\Control\ComputerName\ComputerName" "ComputerName"
  StrCpy $1 $0 4 3
  StrCpy $Name $0
done:

  ;Read the INI file.

  ReadINIStr $0 "$EXEDIR\byolmi.ini" setup IP
  StrCpy $IP $0

  ReadINIStr $0 "$EXEDIR\byolmi.ini" setup BootstrapURL
  StrCpy $BootstrapURL $0

  ReadINIStr $0 "$EXEDIR\byolmi.ini" setup NetworkName
  StrCpy $NetworkName $0

  ReadINIStr $0 "$EXEDIR\byolmi.ini" setup UnwantedGuest
  StrCpy $UnwantedGuest $0

  ReadINIStr $0 "$EXEDIR\byolmi.ini" setup TincNetwork
  StrCpy $TincNetwork $0

  ReadINIStr $0 "$EXEDIR\byolmi.ini" setup TincNetmask
  StrCpy $TincNetmask $0  

  ReadINIStr $0 "$EXEDIR\byolmi.ini" setup TincPort
  StrCpy $TincPort $0

FunctionEnd

Function nsDialogsPage
  nsDialogs::Create 1018
  Pop $Dialog
  ${IF} $Dialog == error
    Abort
  ${EndIf}

  ;Machine Name
  ${NSD_CreateLabel} 0 0 50% 12u "Enter your machine name"
  Pop $Label

  ${NSD_CreateText} 50% 0 50% 12u $Name
  Pop $Name

  ;VPN IP Address
  ${NSD_CreateLabel} 0 12u 50% 12u "Enter the assigned VPN IP address"
  Pop $Label

  ${NSD_CreateText} 50% 12u 50% 12u $IP
  Pop $IP

  ;VPN Endpoint
  ${NSD_CreateLabel} 0 24u 50% 12u "VPN hub endpoint IP address or URL"
  Pop $Label

  ${NSD_CreateText} 50% 24u 50% 12u $BootstrapURL
  Pop $BootstrapURL

  ;Network Name
  ${NSD_CreateLabel} 0 36u 50% 12u "Tinc Network to Join"
  Pop $Label

  ${NSD_CreateText} 50% 36u 50% 12u $NetworkName
  Pop $NetworkName

  ;Network (for firewall configuration)
  ${NSD_CreateLabel} 0 48u 50% 12u "Network / Prefix"
  Pop $Label

  ${NSD_CreateText} 50% 48u 50% 12u $TincNetwork
  Pop $TincNetwork

  ;Netmask
  ${NSD_CreateLabel} 0 60u 50% 12u "Netmask"
  Pop $Label

  ${NSD_CreateText} 50% 60u 50% 12u $TincNetmask
  Pop $TincNetmask

  ;Port
  ${NSD_CreateLabel} 0 72u 50% 12u "Port (Default: 655)"
  Pop $Label

  ${NSD_CreateText} 50% 72u 50% 12u $TincPort
  Pop $TincPort

  nsDialogs::SHow
FunctionEnd

Function nsDialogsPageLeave
  ${NSD_GetText} $Name $0
  ${NSD_GetText} $IP $1
  ${NSD_GetText} $BootstrapURL $2
  ${NSD_GetText} $NetworkName $3
  ${NSD_GetText} $TincNetwork $4
  ${NSD_GetText} $TincNetmask $5
  ${NSD_GetText} $TincPort $6

  StrCpy $Name $0
  StrCpy $IP $1
  StrCpy $BootstrapURL $2
  StrCpy $NetworkName $3
  StrCpy $TincNetwork $4
  StrCpy $TincNetmask $5
  StrCpy $TincPort $6

FunctionEnd
;--------------------------------

; The stuff to install
Section "Webservices" ;No components page, name is not important

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR

  File putty\libeay32.dll
  File putty\libiconv2.dll
  File putty\libintl3.dll
  File putty\libssl32.dll
  File putty\PSCP.EXE
  File ultravnc\setup.inf
  File ultravnc\UltraVNC_1_2_11_X86_Setup.exe
  File tinc\changeVPNAdapter.vbs
  File tinc\MakeNetworkKnown.bat
  ;We are no longer copying this file. We are writing it on the fly to support different networks / network names.
  ;File tinc\webservices\tinc.conf

  WriteUninstaller uninstall_webservices.exe

SectionEnd ; end the section

;--------------------------------
Section "Install UltraVNC Remote Support"
  ;SETUP UVNC
  ExecWait "$INSTDIR\UltraVNC_1_2_11_X86_Setup.exe /VERYSILENT /LOADINF=$INSTDIR\setup.inf"

  ;Copy the ini file to the UltraVNC dir.
  SetOutPath $INSTDIR\UltraVNC
  File ultravnc\UltraVNC.ini

  DetailPrint "Stopping uvnc server"
  nsExec::ExecToLog "net stop uvnc_service"
  DetailPrint "Starting uvnc server"
  nsExec::ExecToLog "net start uvnc_service"
SectionEnd
;--------------------------------
Section "Automatically configure firewall"
  ;Setup the firewall
  nsExec::ExecToLog 'netsh advfirewall firewall add rule name="Webservices" dir=in action=allow enable=yes remoteip=$TincNetwork'
SectionEnd

;--------------------------------
Section "Tinc - Secure VPN"
; SETUP TINC

  ;Put this in the installation directory.
  SetOutPath $INSTDIR
  File tinc\restart-tinc.bat

  ;Setup output path to the tinc dir in program files.
  SetOutPath "$PROGRAMFILES\tinc"

  File tap\OemVista.inf
  File tap\tap0901.cat
  File tap\tap0901.sys
  File tap\devcon.exe
  File tinc\tincd.exe
  File tinc\nets.boot

  DetailPrint "Installing VPN Adapter"
  nsExec::ExecToLog '"$PROGRAMFILES\tinc\devcon.exe" install "$0\tinc\OemVista.inf" tap0901'

  DetailPrint "Setting up cscript preferences"
  nsExec::ExecToLog "cscript //h:cscript //s"

  DetailPrint "Changing adapter name to VPN"
  ExecWait 'cscript "$INSTDIR\changeVPNAdapter.vbs"'

  DetailPrint "Making the VPN a 'known' network"
  ExecWait "$INSTDIR\MakeNetworkKnown.bat"

  DetailPrint "Setting VPN adapter address to $IP / $TincNetmask"
  ExecWait 'netsh interface ip set address name="VPN" static $IP $TincNetmask'
  
  SetOutPath "$0\tinc\$NetworkName\hosts"
  File tinc\webservices\hosts\webservices
  File tinc\andretti\hosts\andretti
  
  SetOutPath "$0\tinc\$NetworkName\"

  DetailPrint "Writing $0\tinc\$NetworkName\tinc.conf"
  FileOpen $9 $0\tinc\$NetworkName\tinc.conf w

  FileWrite $9 "ConnectTo=$NetworkName$\n"
  DetailPrint "ConnectTo=$NetworkName"
  
  FileWrite $9 "Interface=VPN$\n"
  DetailPrint "Interface=VPN"

  FileWrite $9 "Name=$Name$\n"
  DetailPrint "Name=$Name"

  FileWrite $9 "Subnet=$IP$\n"  
  DetailPrint "Subnet=$IP"

  FileWrite $9 "Port=$TincPort$\n"
  DetailPrint "Port=$TincPort"

  FileClose $9

  SetOutPath "$0\tinc"

  ;CopyFiles "$0\tinc\rsa_key.priv" "$0\tinc\$NetworkName\rsa_key.priv"

  ;Read the public key file so we can append information to it to put it in the hosts file.

  ;Open the output file that will hold the host information.

  ;Open the dest file.
  FileOpen $9 "$0\tinc\$NetworkName\hosts\$Name" w

  ;Open the generated key so we can read it into the dest file after we put the stuff in there.
  ;FileOpen $8 "$0\tinc\rsa_key.pub" r

  IfErrors fileerrors
  FileWrite $9 "Name=$Name$\n"
  FileWrite $9 "Subnet=$IP"
  ClearErrors
  FileClose $9
  Goto done
fileerrors:
  DetailPrint "There was an error setting up the public host key for $Name"
done:

  ExecWait "$0\tinc\tincd.exe -n $NetworkName -K" 

  ;Copy the key to the server.
  ${If} $UnwantedGuest == "1"
    DetailPrint "Unwanted Guest Value: $UnwantedGuest"
    ExecWait '"$INSTDIR\pscp.exe" -i "$EXEDIR\unwantedguest.ppk" "$0\tinc\$NetworkName\hosts\$Name" unwantedguest@$BootstrapURL:/tmp/'
  ${Else}
    DetailPrint "Unwanted Guest Value: $UnwantedGuest"
    ExecWait '"$INSTDIR\pscp.exe" "$0\tinc\$NetworkName\hosts\$Name" root@$BootstrapURL:/etc/tinc/$NetworkName/hosts'
  ${EndIf}   

  ExecWait "$0\tinc\tincd.exe -n $NetworkName"

  ;Add start menu items to restart tinc
  # Start Menu
  createDirectory "$SMPROGRAMS\HPH Webservices"
  createShortCut "$SMPROGRAMS\HPH Webservices\RestartWebServices.lnk" "$INSTDIR\restart-tinc.bat" "" "$WINDIR\System32\SHELL32.dll" 27

SectionEnd
;--------------------------------

Section "Allow Safe Mode Recovery"
  ;Allow VNC to run in safemode with networking
   WriteRegStr HKLM "SYSTEM\CurrentControlSet\Control\SafeBoot\Network\uvnc_service" "String Value" "Service"
  ;Allow tinc to run in safemode with networking
   WriteRegStr HKLM "SYSTEM\CurrentControlSet\Control\SafeBoot\Network\tinc.$NetworkName" "String Value" "Service"  
SectionEnd
;--------------------------------

; Uninstaller

Section "Uninstall"
  ;Stop tinc.
  ExecWait "net stop tinc.$NetworkName"
  ExecWait "sc \\. delete tinc.$NetworkName"

  RMDir "C:\Program Files\tinc"

  ExecWait "net stop uvnc_service"
  ExecWait "sc \\. delete uvnc_service"

  RMDir "C:\BYOLMI"

SectionEnd ; end the Uninstall section