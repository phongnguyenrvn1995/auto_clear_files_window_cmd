@echo off
set "extension=PEM"

REM Minutes
set /a "exceeded=60"
REM Seconds
set /a "looping_interval=60" 

call :while_loop
exit /b

:while_loop

	echo #################DO CHECKING#################
	call :startFunc
	timeout /t %looping_interval% /nobreak
	goto :while_loop

exit /b

:startFunc
for /f "tokens=* delims=" %%F in ('dir /b "*.*" ^| findstr /i /e ".%extension%"') do (
	echo =======================================
	echo FILE NAME: "%%F"
	for /f "tokens=1,2,*" %%A in ('dir /TC "%%F" ^| find "%%F"') do (
		set "CreateDate=%%A %%B"
		echo %CreateDate%
		call :clearIfExceeded "%%F"
	)
)
exit /b


:clearIfExceeded
setlocal
	REM Use PowerShell to get the current UTC time in the specified format
	for /f "delims=" %%A in ('powershell "[System.DateTime]::UtcNow.ToString('yyyyMMddHHmmss')"') do set "CurrentTime=%%A"

	REM Use PowerShell to get file creation time in ISO 8601 format
	for /f "delims=" %%A in ('powershell "(Get-Item -LiteralPath \"%1\").CreationTimeUtc.ToString('yyyyMMddHHmmss')"') do set "FileCreationTime=%%A"

	echo CurrentTime = %CurrentTime%
	echo FileCreationTime = %FileCreationTime%
	
	call :substractDateInMins %FileCreationTime% %CurrentTime% FileAgeInMinutes
	echo FileAgeInMinutes = %FileAgeInMinutes%
	set /a "FileAgeInMinutesInt=FileAgeInMinutes * 1000 / 1000"
	
	if %FileAgeInMinutesInt% geq %exceeded% (
		if exist %1 (
			del %1
			echo File %1 deleted successfully.
		) else (
			echo File %1 does not exist.
		)
	) else (
		echo NOT DELETE %1!!!
	)
endlocal	
exit /b


:substractDateInMins
setlocal enabledelayedexpansion

	set "StartDate=%1"
	set "EndDate=%2"

	REM Calculate the difference in minutes using PowerShell
	for /f "delims=" %%A in ('powershell "($([datetime]::ParseExact('%EndDate:~0,14%', 'yyyyMMddHHmmss', $null)) - $([datetime]::ParseExact('%StartDate:~0,14%', 'yyyyMMddHHmmss', $null))).TotalMinutes"') do set "DateDifference=%%A"

endlocal & set %3=%DateDifference%
exit /b