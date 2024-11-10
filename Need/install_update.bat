@echo off
if '%errorlevel%' NEQ '0' (
    goto goUAC 
) else (
 goto goADMIN )

:goUAC
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:goADMIN
    pushd "%CD%"
    CD /D "%~dp0"
taskkill /f /im Clock.exe >nul
move "%temp%\Clock.exe" "%systemroot%\SysWOW64\Clock.exe"
start %systemroot%\SysWOW64\Clock.exe
