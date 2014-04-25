'Dim vars
        dim x,t,m,filename
        dim wsh
        dim fso
        dim d
        dim args
        dim oFolder
        dim oFile
'Create objects
        set fso = WScript.CreateObject("Scripting.fileSystemObject")
        Set t = WScript.CreateObject("WScript.Shell")
        Set args = WScript.Arguments
        set wsh = WScript.CreateObject("WScript.Shell")
'Make sure we're in util.
        t.CurrentDirectory="C:\Util\"
'Get the file
        wscript.echo "Downloading Core Utils ..."
        t.run "wget http://gnuwin32.sourceforge.net/downlinks/coreutils-bin-zip.php -O coreutils.zip",1,true
        t.run "unzip -o coreutils.zip",1,true

        wscript.echo "Downloading Dependencies..."
        t.run "wget http://gnuwin32.sourceforge.net/downlinks/coreutils-dep-zip.php -O coredeps.zip",1,true
        t.run "unzip -o coredeps.zip",1,true

        wscript.echo "Downloading Grep..."
        t.run "wget http://downloads.sourceforge.net/gnuwin32/grep-2.5.4-bin.zip -O grep.zip",1,true
        t.run "unzip -o grep.zip",1,true

        wscript.echo "Downloading Grep Dependencies..."
        t.run "wget http://downloads.sourceforge.net/gnuwin32/grep-2.5.4-dep.zip -O grepdeps.zip",1,true
        t.run "unzip -o grepdeps.zip",1,true

        'Fix the su.exe read only bullshit
        t.run "attrib -r .\bin\su.exe"

        wscript.echo "Installing binaries and dependencies..."
        set oFolder = fso.GetFolder(".\bin")
        for each oFile in oFolder.Files
                dim target
                target = t.CurrentDirectory & "\" &oFile.Name
                wscript.echo "Checking to see if " & target & " exists..."
                if fso.FileExists(target) then
                        'stuff
'                        wscript.echo "File Exists. Removing in favor of the new file."
'                        fso.DeleteFile target
                end if
                        wscript.echo "Installing: " & oFile.Name
                        fso.CopyFile oFile.Path,target,1
        next

        wscript.echo "Cleaning UP..."
        dim FolderNames
        FolderNames = "bin,contrib,man,manifest,share"
        dim DelFolders
        DelFolders = split(FolderNames,",")
        for each x in DelFolders
                wscript.echo "Removing folder: " & x
                fso.DeleteFolder(x),1
        next

        dim FileNames
        FileNames = "coreutils.zip,coredeps.zip,grep.zip,grepdeps.zip"
        dim killList
        killList = split(FileNames,",")
        for each x in killList
                wscript.echo "Removing downloaded file: " & x
                fso.DeleteFile(x),1
        next

        wscript.echo "Installation Complete."
