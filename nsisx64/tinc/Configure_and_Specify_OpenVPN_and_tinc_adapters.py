import sys,os,subprocess, time

#Delete all the current VPN adapters.
print "Deleting ALL VPN adapters..."
cmd = ['C:\\Program Files\\tinc\\devcon.exe','remove','tap0901']
subprocess.call(cmd)
print "Done."
print ""

#Add a new adapter, which will be used for OpenVPN
cmd = ['C:\\Program Files\\tinc\\devcon.exe','install','C:\Program Files\\tinc\\OemWin2k.inf','tap0901']
subprocess.call(cmd)

#Do it again, because we need two.
cmd = ['C:\\Program Files\\tinc\\devcon.exe','install','C:\Program Files\\tinc\\OemWin2k.inf','tap0901']
subprocess.call(cmd)

#Sleep for 10 seconds to allow the os to update the new adapaters.
time.sleep(5)

#Make sure cscript doesn't load in the GUI
cmd = ['cscript.exe','//H:CScript']
subprocess.call(cmd)

#set the adapter names
cmd = ['cscript.exe','C:\\BYOLMI\\SetAdapterNames.vbs']
subprocess.call(cmd)

#Define the dev-node directive for OpenVPN. This assumes there is only ONE ovpn file in the OpenVPN configuration directory!
configdir = 'C:\\Program Files\\OpenVPN\\config'
for f in os.listdir(configdir):
	theFile = os.path.join('C:\\Program Files\\OpenVPN\\config',f)
	filename, file_extension = os.path.splitext(theFile)
	print file_extension
	if file_extension == ".ovpn":
		print "Modifying: %s" % theFile
		configfile = open(theFile,'a')
		configfile.write("dev-node OpenVPN\n")
		configfile.close()

#Read the tinc config, and set the VPN Adapter's IP address

#Open nets.boot to get the directory
#tincDir = "C:\\Program Files\\tinc\\"
#file = open(os.path.join(tincDir,"nets.boot")
#network = file.readline().strip()
#file.close()
#
#networkDir = os.path.join(tincDir,network)
#file = open(os.path.join(networkDir,tinc.conf))
#for line in file:
#	print line
print "Done."