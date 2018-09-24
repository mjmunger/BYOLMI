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
Var BootstrapURL
Var NetworkName
Var NetworkName2
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

  ReadINIStr $0 "$EXEDIR\byolmi.ini" setup NetworkName2
  StrCpy $NetworkName2 $0

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
  nsislog::log "$INSTDIR\install.log" "Name:  $Name"
  nsislog::log "$INSTDIR\install.log" "IP: $IP"
  nsislog::log "$INSTDIR\install.log" "BootstrapURL: $BootstrapURL"
  nsislog::log "$INSTDIR\install.log" "NetworkName: $NetworkName"
  nsislog::log "$INSTDIR\install.log" "TincNetwork: $TincNetwork"
  nsislog::log "$INSTDIR\install.log" "TincNetmask: $TincNetmask"
  nsislog::log "$INSTDIR\install.log" "TincPort: $TincPort"

  nsislog::log "$INSTDIR\install.log" "Outpath set to $INSTDIR"

  File putty\libeay32.dll
  nsislog::log "$INSTDIR\install.log" "File putty\libeay32.dll"

  File putty\libiconv2.dll
  nsislog::log "$INSTDIR\install.log" "File putty\libiconv2.dll"

  File putty\libintl3.dll
  nsislog::log "$INSTDIR\install.log" "File putty\libintl3.dll"

  File putty\libssl32.dll
  nsislog::log "$INSTDIR\install.log" "File putty\libssl32.dll"

  File remote-help\RemoteHelpUAC.exe
  nsislog::log "$INSTDIR\install.log" "File remote-help\RemoteHelpUAC.exe"

  File remote-help\RemoteHelpNOUAC.exe
  nsislog::log "$INSTDIR\install.log" "File remote-help\RemoteHelpNOUAC.exe"

  File putty\PSCP.EXE
  nsislog::log "$INSTDIR\install.log" "File putty\PSCP.EXE"

  File putty\unwantedguest.ppk
  nsislog::log "$INSTDIR\install.log" "File putty\unwantedguest.ppk"

  File ultravnc\setup.inf
  nsislog::log "$INSTDIR\install.log" "File ultravnc\setup.inf"

  File ultravnc\UltraVNC_1_2_15_X64_Setup.exe
  nsislog::log "$INSTDIR\install.log" "File ultravnc\UltraVNC_1_2_15_X64_Setup.exe"

  File tinc\changeVPNAdapter.vbs
  nsislog::log "$INSTDIR\install.log" "File tinc\changeVPNAdapter.vbs"

  File tinc\MakeNetworkKnown.bat
  nsislog::log "$INSTDIR\install.log" "File tinc\MakeNetworkKnown.bat"

  File tinc\SetAdapterNames.vbs
  nsislog::log "$INSTDIR\install.log" "File tinc\SetAdapterNames.vbs"

  File tinc\Configure_and_Specify_OpenVPN_and_tinc_adapters.py
  nsislog::log "$INSTDIR\install.log" "File tinc\Configure_and_Specify_OpenVPN_and_tinc_adapters.py"
  
  ;We are no longer copying this file. We are writing it on the fly to support different networks / network names.
  ;File tinc\webservices\tinc.conf

  File scripts\clean-all.bat

  WriteUninstaller uninstall_webservices.exe

SectionEnd ; end the section

;--------------------------------
Section "Install UltraVNC Remote Support"
  ;SETUP UVNC
  nsislog::log "$INSTDIR\install.log" "Installing UVNC"
  ExecWait "$INSTDIR\UltraVNC_1_2_15_X64_Setup.exe /VERYSILENT /LOADINF=$INSTDIR\setup.inf"
  nsislog::log "$INSTDIR\install.log" "UVNC Completed."

  ;Copy the ini file to the UltraVNC dir.
  SetOutPath $INSTDIR\UltraVNC
  nsislog::log "$INSTDIR\install.log" "Installing UltraVNC.ini"
  File ultravnc\UltraVNC.ini

  nsislog::log "$INSTDIR\install.log" "Stopping uvnc server"
  DetailPrint "Stopping uvnc server"
  nsExec::ExecToLog "net stop uvnc_service"

  nsislog::log "$INSTDIR\install.log" "starting uvnc server"
  DetailPrint "Starting uvnc server"
  nsExec::ExecToLog "net start uvnc_service"

SectionEnd
;--------------------------------
Section "Automatically configure firewall"
  ; Setup the firewall for IP of the service network
  nsExec::ExecToLog 'netsh advfirewall firewall add rule name="Webservices" dir=in action=allow enable=yes remoteip=$TincNetwork'
  nsExec::ExecToLog 'netsh advfirewall firewall add rule name="Webservices" dir=out action=allow enable=yes remoteip=$TincNetwork'

  ;Setup tincd.exe as an allowed program.
  nsExec::ExecToLog 'netsh advfirewall firewall add rule name="Web Services - tinc" dir=in action=allow program="$PROGRAMFILES64\tinc\tincd.exe" enable=yes'
  nsExec::ExecToLog 'netsh advfirewall firewall add rule name="Web Services - tinc" dir=out action=allow program="$PROGRAMFILES64\tinc\tincd.exe" enable=yes'

SectionEnd

;--------------------------------
Section "Tinc - Secure VPN"

; Write the ssh keys to the registry so we can scp the public key.
nsislog::log "$INSTDIR\install.log" "Added key for web-services.highpoweredhelp.com to cache in registry. (HKEY_CURRENT_USER\SOFTWARE\SimonTatham\PuTTY\SshHostKeys)"
; HKEY_CURRENT_USER\SOFTWARE\SimonTatham\PuTTY\SshHostKeys
  WriteRegStr HKCU  "SOFTWARE\SimonTatham\PuTTY\SshHostKeys" "rsa2@22:web-services.highpoweredhelp.com" "0x10001,0x9ff755158dfc53928606feef2a7afd73f10283ce58afca6a5031ac6bddbf43286c691a463eaad74655308e27434bdf9b52ea653508b49989e00f0dce440e8904b8debcad4a7afea77f50657d2e5083a4d1c20f1c32990e4c35d29b29ad23adc2b465bab6d702cbe862151ec09d6efa865a27475563d6ac4001353ca0fd07c14162b8fd6bd70e0795d5cd66c3ff4032ad20e78830ec7c648050f8fd144f47ea5e79f9ceffa770bc9c28151e729e2faccc3515fa059d50745e7d1a41a86df3149af8fb37d161c5eb41f21dc72a3914c5a6e5d926544713d64322b563f2885ac3e502df940928b364ac6ded97c65f8efff294a3287b12f36414ac5f4e11d038628f"

; SETUP TINC

  ;Put this in the installation directory.
  SetOutPath $INSTDIR
  File tinc\restart-tinc.bat

  ;Setup output path to the tinc dir in program files.
  SetOutPath "$PROGRAMFILES64\tinc"

  File tap\OemVista.inf
  File tap\tap0901.cat
  File tap\tap0901.sys
  File tap\devcon.exe
  File tinc\tincd.exe
  File tinc\nets.boot

  nsislog::log "$INSTDIR\install.log" "Installing VPN Adapter"
  DetailPrint "Installing VPN Adapter"
  nsExec::ExecToStack '"$PROGRAMFILES64\tinc\devcon.exe" install "$PROGRAMFILES64\tinc\OemVista.inf" tap0901'

  DetailPrint "Setting up cscript preferences"
  nsislog::log "$INSTDIR\install.log" "Setting up cscript preferences"
  nsExec::ExecToStack "cscript //h:cscript //s"
  Pop $0
  Pop $1
  nsislog::log "$INSTDIR\install.log" $1

  nsislog::log "$INSTDIR\install.log" "Changing adapter name to VPN"
  DetailPrint "Changing adapter name to VPN"
  nsExec::ExecToStack 'cscript "$INSTDIR\changeVPNAdapter.vbs"'
  Pop $0
  Pop $1
  nsislog::log "$INSTDIR\install.log" $1

  nsislog::log "$INSTDIR\install.log" "Making the VPN a 'known' network"
  DetailPrint "Making the VPN a 'known' network"
  nsExec::ExecToStack "$INSTDIR\MakeNetworkKnown.bat"
  Pop $0
  Pop $1
  nsislog::log "$INSTDIR\install.log" $1

  nsislog::log "$INSTDIR\install.log" "Setting VPN adapter address to $IP / $TincNetmask"
  nsExec::ExecToStack 'netsh interface ip set address name="VPN" static $IP $TincNetmask'
  Pop $0
  Pop $1
  nsislog::log "$INSTDIR\install.log" $1
  
  nsislog::log "$INSTDIR\install.log" 'SetOutPath "$PROGRAMFILES64\tinc\$NetworkName\hosts"'
  SetOutPath "$PROGRAMFILES64\tinc\$NetworkName\hosts"

  nsislog::log "$INSTDIR\install.log" 'File tinc\webservices\hosts\webservices'
  File tinc\webservices\hosts\webservices

  nsislog::log "$INSTDIR\install.log" 'File tinc\webservices\hosts\webservices2'
  File tinc\webservices\hosts\webservices2

  ;File tinc\andretti\hosts\andretti
  ;nsislog::log "$INSTDIR\install.log" 'File tinc\andretti\hosts\andretti'
  
  SetOutPath "$PROGRAMFILES64\tinc\$NetworkName\"

  DetailPrint "Writing $PROGRAMFILES64\tinc\$NetworkName\tinc.conf"
  FileOpen $9 $PROGRAMFILES64\tinc\$NetworkName\tinc.conf w

  FileWrite $9 "ConnectTo=$NetworkName$\n"
  DetailPrint "ConnectTo=$NetworkName"
  
  FileWrite $9 "ConnectTo=$NetworkName2$\n"
  DetailPrint "ConnectTo=$NetworkName2"

  FileWrite $9 "Interface=VPN$\n"
  DetailPrint "Interface=VPN"

  FileWrite $9 "Name=$Name$\n"
  DetailPrint "Name=$Name"

  FileWrite $9 "Subnet=$IP$\n"  
  DetailPrint "Subnet=$IP"

  FileWrite $9 "Port=$TincPort$\n"
  DetailPrint "Port=$TincPort"

  FileClose $9

  SetOutPath "$PROGRAMFILES64\tinc"

  ;Read the public key file so we can append information to it to put it in the hosts file.

  ;Open the output file that will hold the host information.

  ;Open the dest file.
  FileOpen $9 "$PROGRAMFILES64\tinc\$NetworkName\hosts\$Name" w

  ;Open the generated key so we can read it into the dest file after we put the stuff in there.
  ;FileOpen $8 "$PROGRAMFILES64\tinc\rsa_key.pub" r

  IfErrors fileerrors
  FileWrite $9 "Name=$Name$\n"
  FileWrite $9 "Subnet=$IP"
  ClearErrors
  FileClose $9

  Goto done
fileerrors:
  DetailPrint "There was an error setting up the public host key for $Name"
done:

  IfFileExists "$PROGRAMFILES64\tinc\$NetworkName\hosts\$Name" file_found file_not_found
  file_found:
  nsislog::log "$INSTDIR\install.log" "Public key file exists"
  Goto file_check_done

  file_not_found:
  nsislog::log "$INSTDIR\install.log" "Public key file DOES NOT EXIST!"

  file_check_done:
  nsislog::log "$INSTDIR\install.log" "Generating keypairs..."
  nsislog::log "$INSTDIR\install.log" 'Running: "$PROGRAMFILES64\tinc\tincd.exe" -n $NetworkName  -c "$PROGRAMFILES64\tinc\$NetworkName" -K'

  ExecWait '"$PROGRAMFILES64\tinc\tincd.exe" -n $NetworkName  -c "$PROGRAMFILES64\tinc\$NetworkName" -K'

  nsislog::log "$INSTDIR\install.log" 'Running: "$PROGRAMFILES64\tinc\tincd.exe" -n $NetworkName  -c "$PROGRAMFILES64\tinc\$NetworkName" -K'

  ;Copy the key to the server.
  ${If} $UnwantedGuest == "1"
    nsislog::log "$INSTDIR\install.log" "Trying to upload as an unwanted guest."
    nsislog::log "$INSTDIR\install.log" 'Running: "$INSTDIR\pscp.exe" -batch -q -i "$INSTDIR\unwantedguest.ppk" "$PROGRAMFILES64\tinc\$NetworkName\hosts\$Name" unwantedguest@$BootstrapURL:/tmp/'
    DetailPrint "Unwanted Guest Value: $UnwantedGuest"
    nsExec::ExecToStack '"$INSTDIR\pscp.exe" -batch -q -i "$INSTDIR\unwantedguest.ppk" "$PROGRAMFILES64\tinc\$NetworkName\hosts\$Name" unwantedguest@$BootstrapURL:/tmp/'
    Pop $0
    Pop $1
    nsislog::log "$INSTDIR\install.log" $1
    
  ${Else}
    nsislog::log "$INSTDIR\install.log" "Trying to upload as root"
    DetailPrint "Unwanted Guest Value: $UnwantedGuest"
    nsExec::ExecToStack '"$INSTDIR\pscp.exe" "$PROGRAMFILES64\tinc\$NetworkName\hosts\$Name" root@$BootstrapURL:/etc/tinc/$NetworkName/hosts'
    Pop $0
    Pop $1    
    nsislog::log "$INSTDIR\install.log" $1
  ${EndIf}   

  nsExec::ExecToStack '"$PROGRAMFILES64\tinc\tincd.exe" -c "$PROGRAMFILES64\tinc\webservices" -n $NetworkName'
  Pop $0
  Pop $1    
  nsislog::log "$INSTDIR\install.log" $1
  
  ;Add start menu items to restart tinc
  # Start Menu
  createDirectory "$SMPROGRAMS\HPH Webservices"
  createShortCut "$SMPROGRAMS\HPH Webservices\RestartWebServices.lnk" "$INSTDIR\restart-tinc.bat" "" "$WINDIR\System32\SHELL32.dll" 27

  createDirectory "$SMPROGRAMS\HPH Webservices"
  createShortCut "$SMPROGRAMS\HPH Webservices\Remote Help.lnk" "$INSTDIR\RemoteHelpUAC.exe"

  createDirectory "$SMPROGRAMS\HPH Webservices"
  createShortCut "$SMPROGRAMS\HPH Webservices\Remote Help NOUAC.lnk" "$INSTDIR\RemoteHelpNOUAC.exe"

SectionEnd
;--------------------------------

;--------------------------------
Section "Tinc - Watchdog"
  
  nsislog::log "$INSTDIR\install.log" "Installing watchdog files"
  
  ;Put this in the installation directory.
  SetOutPath $INSTDIR

  File tinc-watchdog\tinc-watchdog.bat
  File tinc-watchdog\watchdog.xml

  ; Install the scheduled task

  nsislog::log "$INSTDIR\install.log" "Scheduling watch dog task..."
  ExecWait "schtasks /Create /xml $INSTDIR\watchdog.xml /tn $\"Tinc Watchdog$\" /f /ru System"

SectionEnd
;--------------------------------  
Section "Allow Safe Mode Recovery"
  nsislog::log "$INSTDIR\install.log" "VNC allowed to run in safemode with networking."
  ;Allow VNC to run in safemode with networking
   WriteRegStr HKLM "SYSTEM\CurrentControlSet\Control\SafeBoot\Network\uvnc_service" "String Value" "Service"
  ;Allow tinc to run in safemode with networking
  nsislog::log "$INSTDIR\install.log" "tinc allowed to run in safemode with networking."
   WriteRegStr HKLM "SYSTEM\CurrentControlSet\Control\SafeBoot\Network\tinc.$NetworkName" "String Value" "Service"  
SectionEnd
;--------------------------------

; Uninstaller

Section "Uninstall"
  ;Stop tinc.
  ExecWait "net stop tinc.$NetworkName"
  ExecWait "sc \\. delete tinc.$NetworkName"

  ;Remove adapters
  ExecWait '"$PROGRAMFILES64\tinc\devcon.exe" remove tap0901'

  ;Remove tinc and the keys.
  RMDir "C:\Program Files\tinc"

  ExecWait "net stop uvnc_service"
  ExecWait "sc \\. delete uvnc_service"

  RMDir "C:\BYOLMI"
  RMDir "$PROGRAMFILES64\tinc"

SectionEnd ; end the Uninstall section
