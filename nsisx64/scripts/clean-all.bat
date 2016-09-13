@echo off
cls
echo "Stopping all related services"
net stop tinc.webservices
net stop tinc.andretti
net stop tinc
net stop uvnc_service

echo "Removing all installed services
sc \\. DELETE tinc.webservices
sc \\. DELETE tinc.andretti
sc \\. DELETE tinc
sc \\. DELETE uvnc_service

"C:\Program Files\tinc\devcon.exe" remove tap0901
"C:\Program Files (x86)\tinc\devcon.exe" remove tap0901

rd /s /q C:\BYOLMI
rd /s /q "C:\Program Files\tinc"
rd /s /q "C:\Program Files (x86)\tinc"

echo "Please manually remove the 'tinc' directory under program files."
echo "done"