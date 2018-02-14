@echo off
SETLOCAL EnableDelayedExpansion

set PSM="C:\Program Files\Sisense\Prism\psm.exe"
set PSM_BUILD=ecube build
set PSM_RESTART=ecube restart
set EC_MODE=full
set FIND_LOG=find.log
set STAGING_DIR=E:\comverse
set EC_FILE=%STAGING_DIR%\lookups\ecubes.txt
set EC_BUILD_COUNT=0

:: get names of ElastiCubes to build
for /F  "tokens=1,2,3 delims=;" %%i in ('type %EC_FILE%') do (
	set EC_SOURCE=%%j
    set EC_NAME=%%i%%j%%k
	set NEW_DIR=%STAGING_DIR%\!EC_SOURCE!\new
	set PROCESSED_DIR=%STAGING_DIR%\!EC_SOURCE!\processed
	set PSM_BUILD_LOG=!EC_SOURCE!.log
	set EC_SOURCE_FILES=%%j.txt

	if exist !NEW_DIR! (
		if exist !NEW_DIR!\*.!EC_SOURCE!.txt (
			dir /b !NEW_DIR!\*.!EC_SOURCE!.txt > !EC_SOURCE_FILES!
			set /p EC_SOURCE_FILES_1=< !EC_SOURCE_FILES!
::	rename first file
			echo "Rename file from=!EC_SOURCE_FILES_1! to=_%%j.txt"
			ren !NEW_DIR!\!EC_SOURCE_FILES_1! _%%j.txt

::	restart ElastiCube
			echo "Restart name=!EC_NAME!"
			%PSM% %PSM_RESTART% name="!EC_NAME!"

			set /A EC_BUILD_STATUS=0
::	build ElastiCube
			echo "Build name=!EC_NAME! mode=%EC_MODE%"
			%PSM% %PSM_BUILD% name="!EC_NAME!" mode=%EC_MODE% > !PSM_BUILD_LOG! 2>&1

::	check log file
			echo "Check !PSM_BUILD_LOG!"
			find /I "build successfully ended" !PSM_BUILD_LOG! > %FIND_LOG% 2>&1
			IF ERRORLEVEL 1 set /A EC_BUILD_STATUS=1
	
::	rename reference file
			echo "Rename file from=_%%j.txt to=!EC_SOURCE_FILES_1!"
			ren !NEW_DIR!\_%%j.txt !EC_SOURCE_FILES_1!

::	restart ElastiCube
			echo "Restart name=!EC_NAME!"
			%PSM% %PSM_RESTART% name="!EC_NAME!"

			if "!EC_BUILD_STATUS!"=="1" goto BUILD_FAIL
			set /A EC_BUILD_COUNT+=1
::	move source files to processed folder
			if exist !NEW_DIR! (
				echo "Move from=!NEW_DIR! files=*.!EC_SOURCE!.txt to=!PROCESSED_DIR! "
				forfiles /P !NEW_DIR! /M *.!EC_SOURCE!.txt /C "cmd /c move /y @path !PROCESSED_DIR!"
			)
		)
	)
)

if "%EC_BUILD_COUNT%" GTR "3" (
	echo "Restart name=%EC_NAME%"
	%PSM% %PSM_RESTART% name="%EC_NAME%"
	echo "Build name=%EC_NAME% mode=%EC_MODE%"
	%PSM% %PSM_BUILD% name="%EC_NAME%" mode=%EC_MODE% > %PSM_BUILD_LOG% 2>&1
	echo "Restart name=%EC_NAME%"
	%PSM% %PSM_RESTART% name="%EC_NAME%"
) else (
	echo "EC_BUILD_COUNT=%EC_BUILD_COUNT%, so not building %EC_NAME%"
)

exit /b 0

:BUILD_FAIL
type %PSM_BUILD_LOG%
