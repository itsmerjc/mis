@echo off
:: Maglagay ng Title sa Command Prompt Window

title EMI MIS ACCOUNT MANAGER
color 0D
:: Black background, Ligth Purple text

:: URL kung saan kukunin ang expiration date
set "EXPIRATION_URL=https://raw.githubusercontent.com/itsmerjc/mis/refs/heads/main/expiration_date.txt"

:: I-download ang expiration date mula sa URL gamit ang PowerShell
for /f "delims=" %%A in ('powershell -Command "(Invoke-WebRequest -Uri '%EXPIRATION_URL%' -UseBasicParsing).Content"') do set "EXPIRATION_DATE=%%A"

:: Siguraduhin na may nakuha na expiration date
if "%EXPIRATION_DATE%"=="" (
    echo Failed to retrieve expiration date.
    pause
    exit /b
)

:: Get current date in YYYYMMDD format
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value ^| findstr LocalDateTime') do set "CURRENT_DATE=%%I"
set "CURRENT_DATE=%CURRENT_DATE:~0,8%"

:: Compare current date with expiration date
if %CURRENT_DATE% GTR %EXPIRATION_DATE% (
    echo This script has expired.
    pause
    exit /b
)

:: Prompt for admin password
:auth
cls
echo ***********************************
echo ** EMI MIS LOCAL USER MANAGEMENT **
echo **        Powered by RJC         **
echo ***********************************
echo.

:: Attempt to run as administrator
runas /savecred /user:emiyazaki\prtadmin "cmd /k exit" >nul 2>&1

:: Check if runas was successful
if errorlevel 1 (
    echo Invalid password or failed to obtain administrator privileges.
    pause
    exit /b
)


:: Continue to menu if admin access is granted
:menu
cls
echo.
echo ***********************************
echo ** EMI MIS LOCAL USER MANAGEMENT **
echo **        Powered by RJC         **
echo ***********************************
echo.
echo 1. User Information
echo 2. Activate User
echo 3. Change User Password
echo 4. Remote Activation of User Account
echo 5. Exit

echo.
set /p option=Choose an option: 
if "%option%"=="1" goto userinfo
if "%option%"=="2" goto activate
if "%option%"=="3" goto changepass
if "%option%"=="4" goto remoteactivate
if "%option%"=="5" goto end
echo Invalid option. Try again.
cls
goto menu

:userinfo
set /p username=Enter the username to show user information: 
if /i "%username%"=="exit" goto menu

runas /savecred /user:emiyazaki\prtadmin "cmd /k title EMLUM && net user %username% /domain && pause && exit" >nul 2>&1
cls
goto menu

:activate
set /p username=Enter the username to activate: 
if /i "%username%"=="exit" goto menu

runas /savecred /user:emiyazaki\prtadmin "cmd /k title EMLUM && net user %username% /active:yes /domain && timeout /t 3 && exit" >nul 2>&1
cls
goto menu

:changepass
set /p username=Enter the username to change password: 
if /i "%username%"=="exit" goto menu
set /p newpassword=Enter new password: 

runas /savecred /user:emiyazaki\prtadmin "cmd /k title EMLUM && net user %username% %newpassword% /domain && timeout /t 3 && exit" >nul 2>&1
cls
goto menu

:remoteactivate
set /p TARGET_PC=Enter the Target PC Name or IP Address: 
schtasks /create /s %TARGET_PC% /tn "EnableAdmin" /tr "cmd.exe /c net user Administrator /active:yes" /sc once /st 00:00 /F
schtasks /run /s %TARGET_PC% /tn "EnableAdmin"
echo.
echo User account has been activated on %TARGET_PC%.
pause
cls
goto menu

:end
exit
