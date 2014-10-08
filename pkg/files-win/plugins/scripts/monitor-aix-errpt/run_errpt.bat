@echo off

cd ..\..\..\
set UPTIME_DIR=%cd%

@c:\perl\bin\perl.exe "check_aixerrpt.pl" %*