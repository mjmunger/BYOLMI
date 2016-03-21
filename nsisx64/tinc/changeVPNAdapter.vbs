'dim vars
Set t = WScript.CreateObject("WScript.Shell")

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
	  
		IF objItem.Description = "TAP-Windows Adapter V9" Then
			
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

cmd = getAdapaterCommand()
t.run cmd,1,true