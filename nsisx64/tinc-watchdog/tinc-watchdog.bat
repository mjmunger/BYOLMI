@echo off
cls
sc query tinc.webservices | findstr "RUNNING"
if %ERRORLEVEL% == 2 goto trouble
if %ERRORLEVEL% == 1 goto stopped
if %ERRORLEVEL% == 0 goto started
echo unknown status
goto end
:trouble
echo trouble
goto end
:started
echo started
goto end
:stopped
echo "Staring tinc.webservices"
net start tinc.webservices
goto end
:end
