'Dim vars
        dim x,t,m,filename
        dim wsh
        dim fso
        dim d
        dim args
'Create objects
        set fso = WScript.CreateObject("Scripting.fileSystemObject")
        Set t = WScript.CreateObject("WScript.Shell")
        Set args = WScript.Arguments
'Get the file
        'fso.deletefolder("C:\PandaCL")
        wscript.echo "Downloading Putty Utils ..."
        t.run "wget http://the.earth.li/~sgtatham/putty/latest/x86/putty.zip",1,true
        t.run "unzip putty.zip",1,true
