'Customization
	dim yourDomain
	'EXAMPLE: https://dl.dropboxusercontent.com/u/12345678/
	'EXAMPLE: http://www.yourdomain.com/somedir/

	yourDomain = "http://www.changeme.com/" '<-- Make sure to have the trailing slash!
	webServicesServer = "web-services.changeme.com" '<-- Make sure you change this to the FQDN that we will be scp'ing the public key to.

'Dim vars
	Const ForReading = 1, ForWriting = 2, ForAppending = 8, TristateUseDefault = -2, TristateTrue = -1, TristateFalse = 0
	dim x,t,m,filename, targetDir,webServicesDir,tincName,tincSubnet,hosts,cmd,vncini,wsh,fso,d,args,oFolder,oFile,StdIn,StdOut 'Create objects

'Set Objects
	set fso = WScript.CreateObject("Scripting.fileSystemObject")
	Set t = WScript.CreateObject("WScript.Shell")
	Set args = WScript.Arguments
	set wsh = WScript.CreateObject("WScript.Shell")
	Set StdIn = Wscript.StdIn
	Set StdOut = WScript.StdOut

'Environment Variables
	targetDir = t.ExpandEnvironmentSTrings("%PROGRAMFILES%") & "\tinc"
	vncini = t.ExpandEnvironmentSTrings("%PROGRAMFILES%") & "\uvnc bvba\UltraVNC\ultravnc.ini"
	webServicesDir = targetDir & "\webservices"
	tincConf = webServicesDir & "\tinc.conf"
	hosts = webServicesDir & "\hosts\"

'Function BEGIN!

Function getAdapaterCommand()
	On Error Resume Next 
	Dim cmd
	 
	strComputer = "." 
	Set objWMIService = GetObject("winmgmts:" _ 
		& "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2") 
	 
	Set colItems = objWMIService.ExecQuery("Select * from Win32_NetworkAdapter") 
	 
	For Each objItem in colItems 
		'Wscript.Echo "Adapter Type: " & objItem.AdapterType 
	  
		Select Case objItem.AdapterTypeID 
			Case 0 strAdapterType = "Ethernet 802.3"  
			Case 1 strAdapterType = "Token Ring 802.5"  
			Case 2 strAdapterType = "Fiber Distributed Data Interface (FDDI)"  
			Case 3 strAdapterType = "Wide Area Network (WAN)"  
			Case 4 strAdapterType = "LocalTalk"  
			Case 5 strAdapterType = "Ethernet using DIX header format"  
			Case 6 strAdapterType = "ARCNET"  
			Case 7 strAdapterType = "ARCNET (878.2)"  
			Case 8 strAdapterType = "ATM"  
			Case 9 strAdapterType = "Wireless"  
			Case 10 strAdapterType = "Infrared Wireless"  
			Case 11 strAdapterType = "Bpc"  
			Case 12 strAdapterType = "CoWan"  
			Case 13 strAdapterType = "1394" 
		End Select 
	  
		IF objItem.Description = "TAP-Win32 Adapter V9" Then
			
			'Wscript.Echo "Adapter Type Id: " & strAdapterType 
			'Wscript.Echo "AutoSense: " & objItem.AutoSense 
			'Wscript.Echo "Description: " & objItem.Description 
			'Wscript.Echo "Device ID: " & objItem.DeviceID 
			'Wscript.Echo "Index: " & objItem.Index 
			'Wscript.Echo "MAC Address: " & objItem.MACAddress 
			'Wscript.Echo "Manufacturer: " & objItem.Manufacturer 
			'Wscript.Echo "Maximum Number Controlled: " & objItem.MaxNumberControlled 
			'Wscript.Echo "Maximum Speed: " & objItem.MaxSpeed 
			'Wscript.Echo "Name: " & objItem.Name 
			'Wscript.Echo "Net Connection ID: " & objItem.NetConnectionID 
			'Wscript.Echo "Net Connection Status: " & objItem.NetConnectionStatus 
			'For Each strNetworkAddress in objItem.NetworkAddresses 
			'	Wscript.Echo "NetworkAddress: " & strNetworkAddress 
			'Next 
			'Wscript.Echo "Permanent Address: " & objItem.PermanentAddress 
			'Wscript.Echo "PNP Device ID: " & objItem.PNPDeviceID 
			'Wscript.Echo "Product Name: " & objItem.ProductName 
			'Wscript.Echo "Service Name: " & objItem.ServiceName 
			'Wscript.Echo "Speed: " & objItem.Speed 

			cmd = "netsh interface set interface name=""" & objItem.NetConnectionID & """ newname=""VPN"""
		End If
	Next
	
	getAdapaterCommand = cmd
End Function

Function CSI_IsAdmin()
  'Version 1.31
  'http://csi-windows.com/toolkit/csi-isadmin
  CSI_IsAdmin = False
  On Error Resume Next
  key = CreateObject("WScript.Shell").RegRead("HKEY_USERS\S-1-5-19\Environment\TEMP")
  If err.number = 0 Then CSI_IsAdmin = True
End Function

Function getArch()
	'Determines the archivtecture based on the presence of the ProgramFiles (x86) directory
	strArch = ""
	Set wshShell = CreateObject("WScript.Shell")
	Set oFSO = CreateObject("Scripting.FileSystemObject")
	if oFSO.FolderExists(wshShell.ExpandEnvironmentStrings("%PROGRAMFILES(x86)%")) then
		strArch = "x86"
	end if
	if oFSO.FolderExists(wshShell.ExpandEnvironmentStrings("%PROGRAMFILES%")) then
		strArch = "x64"
	end if
	getArch = strArch
end function

'-----BEGIN PROCESSING-----

IF NOT CSI_IsAdmin() THEN
	StdOut.WriteLine "This script must be run as admin"
	Wscript.Quit
END IF

'Make sure we're in util.
	if not fso.FolderExists(targetDir) then
	fso.CreateFolder(targetDir)
	end if
	t.CurrentDirectory=targetDir

'Check requirements.
	StdOut.Write "Checking domain source..."
	if yourDomain = "http://www.changeme.com/" then
		StdOut.WriteLine "You need to configure where I am going to get the zip files for installation. RTFM, please."
		WScript.Quit
	end if
	
	StdOut.Write "Checking for pscp..."
	if not fso.FileExists("c:\util\pscp.exe") then
		StdOut.WriteLine "pscp.exe missing. Run getputty.vbs"
		WScript.Quit
	else
		StdOut.Writeline "OK"
	end if
	StdOut.Write "Checking for wget..."
	if not fso.FileExists("c:\util\wget.exe") then
		StdOut.WriteLine "wget missing. Run get-coreutils.vbs"
		WScript.Quit
	else
		StdOut.Writeline "OK"
	end if


'Get the file
    wscript.echo "Downloading tinc..."
	t.run "wget " & yourDomain & "tinc.zip -O tinc.zip",1,true
	t.run "unzip tinc.zip",1,true
	
	wscript.echo "Downloading webservices files...."
	t.run "wget " & yourDomain & "webservices.zip -O webservices.zip",1,true
	t.run "unzip webservices.zip",1,true

'Get the netname and IP address
	WScript.StdOut.WriteLine "Enter Network Name "
	NetName = StdIn.ReadLine
	WScript.StdOut.WriteLine "VPN IP Address"
	SubNet = StdIn.ReadLine
	
	tincName = "Name=" & NetName
	tincSubnet = "Subnet=" & SubNet

	StdOut.WriteLine "---Tinc Environment Variables---"
	StdOut.WriteLine "Tinc Target Directory: " & targetDir
	StdOut.WriteLine "Tinc Web Services Directory: " & webServicesDir
	StdOut.WriteLine "Tinc Conf: " & tincConf
	StdOut.WriteLine "Tinc Hosts: " & hosts
	StdOut.WriteLine "Tinc Name=" & tincName 
	StdOut.WriteLine "Tinc Subnet=" & tincSubnet
	StdOut.WriteLine "---UVNC Environment Variables---"
	StdOut.WriteLine "UVNC Target Dir:" & vncini

'Add Name and Subnet to tinc.conf
	t.CurrentDirectory=webServicesDir
	Set f = fso.OpenTextFile(tincConf,ForAppending,True)
	f.WriteLine ""
	f.WriteLine tincName
	f.WriteLine tincSubnet
	f.close
	
'Add Name and Subnet to the public key file in hosts/hostname
	t.CurrentDirectory=hosts
	Set f = fso.OpenTextFile(hosts & "\" & NetName,ForAppending,True)
	f.WriteLine ""
	f.WriteLine tincName
	f.WriteLine tincSubnet
	f.close

'Run tincd to generate keys
	t.CurrentDirectory=targetDir
	StdOut.WriteLine "Current in: " & targetDir
	t.run "tincd.exe -n webservices -K",1,true
	
'Upload key to web-services.yourdomain.com
	t.CurrentDirectory=hosts
	StdOut.WriteLine "Current Directory: " & t.CurrentDirectory
	cmd = "c:\util\pscp " & NetName & " root@" & webServicesServer &":/etc/tinc/webservices/hosts"
	StdOut.WriteLine "Secure Copy Public Key using: " & cmd
	t.run cmd,1,true
	
'Add the tap adapter
	if getArch() = "x86" then
		t.CurrentDirectory=targetDir & "\tap-win32"
	else
		t.CurrentDirectory=targetDir & "\tap-win64"
	end if
	StdOut.WriteLine "Current Directory: " & t.CurrentDirectory
	cmd = "addtap.bat"
	t.run cmd,1,true

	cmd = getAdapaterCommand()
	t.run cmd,1,true
	
'Promt user to change new VPN adapter's name to "VPN"
	StdOut.Writeline "VPN Adapter installed. Confirm the adapter's name was changed to 'VPN'"
	StdIn.ReadLine
	
'Set the IP address	
	StdOut.WriteLine "Setting IP address to " & SubNet
	cmd = "netsh interface ip set address name=""VPN"" static " & SubNet & " 255.255.255.0"
	t.run cmd,1,true
	
'Install / Start the service
	t.CurrentDirectory=targetDir
	StdOut.WriteLine "Current Directory: " & t.CurrentDirectory
	cmd = "tincd.exe -n webservices"
	t.run cmd,1,true
	
'Download and install uvnc.
	t.CurrentDirectory="C:\Util"
	wscript.echo "Downloading UltraVNC...."
	t.run "wget " & yourDomain & "uvnc-webservices.zip -O uvnc.zip",1,true
	t.run "unzip uvnc.zip",1,true
	
	cmd = "UltraVNC_1_1_9_X86_Setup.exe /verysilent /loadinf=""setup.inf"""
	t.run cmd,1,true
	
	fso.CopyFile "UltraVNC.ini", vncini
	t.run "net stop uvnc_service",1,true
	t.run "net start uvnc_service",1,true
	
	StdOut.WriteLine "Installation Complete. This computer should now be accessible on IP: " & SubNet