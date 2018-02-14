@echo off
SETLOCAL EnableDelayedExpansion

set PSM="C:\Program Files\Sisense\Prism\psm.exe"
set PSM_BUILD=ecube build
set PSM_RESTART=ecube restart
set EC_MODE=restart
set FIND_LOG=find.log
set STAGING_DIR=E:\informix
set EC_FILE=%STAGING_DIR%\ecubes.txt
set EC_BUILD_COUNT=0

:: get names of ElastiCubes to build
for /F  "tokens=1,2,3 delims=;" %%i in ('type %EC_FILE%') do (
	set EC_SOURCE=%%j
    set EC_NAME=%%i%%j%%k
	set PSM_BUILD_LOG=!EC_NAME!.log

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
	
::	restart ElastiCube
	echo "Restart name=!EC_NAME!"
	%PSM% %PSM_RESTART% name="!EC_NAME!"
)

exit /b 0

rem :BUILD_FAIL
rem type "%PSM_BUILD_LOG%"
