Function SetAdapterNames()
	Set t = WScript.CreateObject("WScript.Shell")
	On Error Resume Next 
	Dim cmd
	 
	strComputer = "." 
	Set objWMIService = GetObject("winmgmts:" _ 
		& "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2") 
	 
	Set colItems = objWMIService.ExecQuery("Select * from Win32_NetworkAdapter where ServiceName = 'tap0901' ") 
	 
	For Each objItem in colItems 
		Wscript.Echo "Adapter Type: " & objItem.AdapterType 
	  
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
	  
	  	WScript.echo "Device ID: " & objItem.PNPDeviceID  
	  	Select Case objItem.PNPDeviceID 
	  		Case "ROOT\NET\0000"
				cmd = "netsh interface set interface name=""" & objItem.NetConnectionID & """ newname=""VPN"""
	  		Case "ROOT\NET\0001"
				cmd = "netsh interface set interface name=""" & objItem.NetConnectionID & """ newname=""OpenVPN"""
	  	End Select

		WScript.echo "Will run command: " & cmd
		t.run cmd,1,true
	Next
End Function

result = SetAdapterNames()