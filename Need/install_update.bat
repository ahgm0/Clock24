@echo off
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' ( goto UAC
) else ( goto goAdmin )

:UAC
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:goAdmin
    pushd "%CD%"
    CD /D "%~dp0"
taskkill /f /im Clock.exe >nul
move "%temp%\Clock.exe" "C:\Windows\SysWOW64\Clock.exe" >nul
start C:\Windows\SysWOW64\Clock.exe >nul
