BYOLMI
======

Scripts to setup Tinc and UltraVNC for creating secure, remote support networks.

#Pre-Requisites


These scripts pre-suppose you have already:

1. Setup a primary tinc node See: [Setting Up a VPN with Tinc VPN Software](http://learnlinuxonline.com/servers/setting-up-a-vpn-with-tinc-vpn-software)
2. Have a basic understanding of RSA Encryption See: [RSA Encryption and Authentication Primer](http://learnlinuxonline.com/security/rsa-encryption-and-authentication-primer)
3. A publicly accessible URL where you can safely store your zip packages that contain your custom setup INI files (for UltraVNC) and your VPN configuration directory skeleton (and public RSA key) for tinc. You can use a webserver (as I have done) or a public Dropbox folder. Anything that is HTTP accessible will work just fine.

###Preparing Your Keys and Settings

The installation script relies on being able to download pre-configured zip files that contain directory skeletons and configuratino files for both tinc and UltraVNC. The three zip files the script will attempt download and use:

1. **tinc.zip** which contains the tinc executables and an initial directory.
2. **webservices.zip** which contains the skeleton structure for your VPN service (named *webservices*)
3. **uvnc.zip** which contains the UltraVNC installable with the pre-configured ini file for silent installation as well as pre-configured remote management settings.

System Setup
======

### Configure UVNC
The UltraVNC settings that come from this repo DO NOT contain a password. Instead, the passwd and passwd2 values are set to [CHANGEME]. This value needs to be replaced with the encrypted version of the password you want to use to connect to UVNC. To get the encrypted password, you'll need to setup / install UltraVNC on a workstation and set the password to what you want, then look at look at the UltraVNC.ini settings file to get the encrypted password. Copy this value into uvnc-webservices\UltraVNC.ini for the values of passwd and passwd. (It should look like: passwd= passwd=694212F70C89301595
 and passwd2=694212F70C89301595, respectively.)

 Once you're done setting the password, zip the three files (excluding the subdirectory they are in) to uvnc-webservices.zip and post on a publically accessible webserver (DropBox public file or a web server) to be downloaded by the setup script later.

 ### Configure tinc with your public RSA key for your primary tinc node.

 Your primary node, which you created when you went through [this tutorial, right?](http://learnlinuxonline.com/servers/setting-up-a-vpn-with-tinc-vpn-software) should have three directives: compression, Subnet, and Address followed by a public RSA key, and should be saved as "webservices". This file should be stored in this folder structure:

 *webservices\hosts\webservices* under the tinc directory in Program Files. **Note:** the final "webservices" in this path is a text file without an extension. A sample of this zip file is included in the repo.

 tinc.conf (stored in webservices\tinc.conf) can remain as it is listed in the repo.

 Zip this structure up in a zip file called webservices.zip, and store on a publically accessible URL. (A sample webservices.zip is included in this repo).

#Installation

### Setup the Environment.
There are three scripts requried to setup the system:

1. Set cscript as the default vbs script interpreter: From the command line: **cscript //h:csccript //s**
1. Create a directory: **C:\Util**, and copy all the contents of this repo there.
1. Add C:\Util to the path of your system (we need access to utils that are in there!)
1. Run the utils in the following order:
- get-coreutils.vbs (Downloads GNU Core Utils so you can have access to wget and unzip for downloads)
- getputty.vbs (Downloads PuTTY and pscp so we can copy the encryption keys to the server)
- setup-web-services.vbs (Downloads and installs your pre-configured tinc and uvnc software)

### How Installation Works (setup-webservices.vbs)
1. First, we download tinc.zip, and extract it to %PROGRAMFILES%\tinc.
2. Next, we download webservices.zip and extract it to %PROGRAMFILES%\tinc\webservices
3. The script then prompts you for a unique name for this comptuer and the network, and what IP address you would like to use for the local computer on the VPN network.
4. The Name and IP address are written to tinc.conf
5. The same name and IP address are also recorded in %PROGRAMFILES%\tinc\webservices\hosts\name, where "name" is the network name that you entered at the prompt.
6. tincd.exe is called to generate your private keys for this computer. When prompted to "Please enter a file to save private RSA key to", accept the default by pressing enter.
7. Next, you should be prompted to save the public key for this computer. The application should give you the full path as %PROGRAMFILES%\tinc\webservices\hosts\name, where "name" is the name you entered when prompted. If you do not see this full and complete (and accurate) path, then you have not set something up correctly. Otherwise, just press enter.
8. Next, the script will call pscp to securely copy the public key for the local computer to the primary tinc node (/etc/tinc/webservices/hosts/name, where "name" is the name you entered into the script above.) Enter your password to allow it to copy. **Note**: You'll likely need to use the *root* user on the system so you can have write access to the /etc/tinc/ directory.
9. Next, the script will install the OpenVPN virtual network adapter for you. It will try to determine if you are running the 64-bit version of an operating system or the 32-bit version, and install the corresponding adapter. When it has completed the installation, it will tell you "Press any key to continue..." Press enter. Enter's a good key to press.
10. Next, the script will attempt to change the name of the adapter that was just installed to "VPN". It gives you a chance to verify this before continuing. I suggest you verify it, and then press enter.
11. Now, the script will change the IP address of the VPN adapter to the address you entered in when prompted. 
12. The script installs the webservices.tinc system service, and starts it.
13. The script downloads and installs UltraVNC as pre-setup in the uvnc-webservices.zip package you created.
14. Because the installer installs the default UltraVNC.ini settings, after the installer completes, the script will stop the uvnc service, then copy YOUR UltraVNC.ini settnigs to the UltraVNC directory and then restart the service to activate those new settings.

Now, your installation is complete, and you should be able to access that computer over the tinc VPN network. You've just built your own LMI.

### Add the Firewall Rules (If applicable)
In Windows, you'll probably need to add a firewall rule to allow traffic over your VPN. I recommend you "whitelist" the entire network rather than just a single port or program. Do do this:

1. Open Windows Advanced Firewall
2. Create a new custom INBOUND rule
3. The rule applies to ALL PROGRAMS
4. The rule applies to ANY protocol. 
5. The *SCOPE* of the rule applies to any **local** IP Addresses of the system, but only to the remote network of the VPN. So, on the Scope step of a new custom rule, click *These IP addresses* for the **Which remote IP addresses does this rule apply to?** section, and click the *Add* button. Then, add your network in the form of *192.168.90.0/24*
6. Allow the connection
7. This rule applies to **Domain, Private, and Public**
8. Give it a name that means something to you.

# Troubleshooting Connections

If you're unable to connect, the problem lies in one of these problem areas (listed from most likely to least likely):

1. You did not copy the public key of the workstation to the /etc/tinc/hosts/ directory of your primary node server. Failure to do so leaves the client unable to authenticate with the primary server node.
2. You need to create a proper firewall entry on the workstation. It is recommended that you allow all traffic on the VPN network regardless of ports. To do so, see *Add the Firewall Rules* above. I have also seen where group policy erases the firewall rule previously set. If you're on a domain, it would be best to add this rule via group policy instead of via a simple local override.
3. tinc vpn service is not configured correctly or throwing errors. tinc is VERY good about putting meaningful information in the event viewer logs. Most of them start with a message that appears to say: "Something went wrong and we don't know what" in the event viewer; however, if you scroll down, you will generally get a useful error message that will help you solve the problem.
4. uvnc_service is stopped or broken, and needs to be restarted.