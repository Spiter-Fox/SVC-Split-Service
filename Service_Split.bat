@echo off

:: Optimize svchost.exe process count and free up system resources
:: Run as Administrator and reboot for changes to take effect.
:: If RAM is added/removed, rerun the script.
::

:: Check for admin privileges
net session >nul 2>&1 || (echo. & echo Run Script As Admin! & echo. & pause & exit)

:: Get total RAM in KB using PowerShell
for /f "tokens=*" %%p in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "(Get-ComputerInfo).CsTotalPhysicalMemory / 1KB"') do (
    set "m=%%p"
)

:: Validate RAM value
if "%m%"=="" (
    echo Failed to retrieve RAM size. Exiting.
    pause
    exit /b 1
)

:: Set SVCHost Split Threshold
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v SvcHostSplitThresholdInKB /t REG_DWORD /d "%m%" /f >nul 2>&1
if %errorlevel% neq 0 (
    echo Failed to update registry. Ensure you have admin privileges.
    pause
    exit /b 1
)

:: Additional cleanup and optimization
:: Stop unnecessary services to free up memory
sc config SysMain start= disabled >nul 2>&1
sc config DiagTrack start= disabled >nul 2>&1
sc config WSearch start= disabled >nul 2>&1
sc config TabletInputService start= disabled >nul 2>&1
sc config wlidsvc start= disabled >nul 2>&1

:: Kill unneeded processes
for %%i in (OneDrive.exe SearchIndexer.exe RuntimeBroker.exe YourPhone.exe) do (
    taskkill /F /IM %%i >nul 2>&1
)

echo System optimization completed! Reboot for changes to take effect.
pause
exit /b 0
