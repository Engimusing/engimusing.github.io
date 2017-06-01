@echo off
SETLOCAL

mkdir %~dp0\exampleBuildLogs 2> NUL
del %~dp0\exampleBuildLogs\*.log

set boards=engimusing_efm32zgusb ^
engimusing_efm32zg108 ^
engimusing_efm32zg222 ^
engimusing_efm32tg110 ^
engimusing_efm32tg222 ^
engimusing_efm32g232 ^
engimusing_efm32wg840 ^
engimusing_efm32wg842

set BUILD_DIR=D:\emus2016\gitrepos\engimusingio\internalTools\exampleTesting\tempBuildDir
set ARDUINO_EXE_DIR=D:\emus2016\Arduino1-6-9
set PACKAGES_DIR=C:\Users\Tim\AppData\Local\Arduino15\packages
set ADDITIONAL_LIBRARY_DIR=C:\Users\Tim\Documents\Arduino\libraries
set EXAMPLES_DIR=D:\emus2016\ArduinoSketchbook\Arduino15\packages\engimusing\hardware\efm32\1.0.1\libraries
set SUMMARY_LOG=%~dp0\exampleBuildLogs\summary.log

pushd %EXAMPLES_DIR%
for %%a in (%boards%) do (
    for /R %%f in (*.ino) do (
        Call :BuildExample %%f %%a
    )
    del %BUILD_DIR%\* /S /q > NUL
)
popd

pause
Exit /B 0

:BuildExample 

pushd D:\emus2016\Arduino1-6-9

echo Building Example %~n1 for %~2

mkdir %BUILD_DIR% 2> NUL

arduino-builder ^
-dump-prefs ^
-logger=machine ^
-hardware "%ARDUINO_EXE_DIR%\hardware" ^
-hardware "%PACKAGES_DIR%" ^
-tools "%ARDUINO_EXE_DIR%\tools-builder" ^
-tools "%ARDUINO_EXE_DIR%\hardware\tools\avr" ^
-tools "%PACKAGES_DIR%" ^
-built-in-libraries "%ARDUINO_EXE_DIR%\libraries" ^
-libraries "%ADDITIONAL_LIBRARY_DIR%" ^
-fqbn=engimusing:efm32:%~2 ^
-ide-version=10609 ^
-build-path "%BUILD_DIR%" ^
-warnings=none ^
-prefs=build.warn_data_percentage=75 "%~1" 2>&1 > NUL 

arduino-builder ^
-compile -logger=machine ^
-hardware "%ARDUINO_EXE_DIR%\hardware" ^
-hardware "%PACKAGES_DIR%" ^
-tools "%ARDUINO_EXE_DIR%\tools-builder" ^
-tools "%ARDUINO_EXE_DIR%\hardware\tools\avr" ^
-tools "%PACKAGES_DIR%" ^
-built-in-libraries "%ARDUINO_EXE_DIR%\libraries" ^
-libraries "%ADDITIONAL_LIBRARY_DIR%" ^
-fqbn=engimusing:efm32:%~2 ^
-ide-version=10609 ^
-build-path "%BUILD_DIR%" ^
-warnings=none ^
-prefs=build.warn_data_percentage=75 "%~1" 2>&1 > NUL | findstr /i "error" >  %~dp0\exampleBuildLogs\temp.log 

findstr /i /v "Incorrect Board" %~dp0\exampleBuildLogs\temp.log >  %~dp0\exampleBuildLogs\temp_2.log

Call :CheckFile %~dp0\exampleBuildLogs\temp_2.log %~dp0\exampleBuildLogs\temp.log %~1 %~2

popd

EXIT /B 0

:CheckFile
if %~z2 EQU 0 (
    echo Sucessfully built %~n3 for %~4 >> %SUMMARY_LOG%
) else (
if %~z1 GTR 0 (
    echo Failed building %~n3 for %~4
    echo %~n3 for board %~4 failed >> %SUMMARY_LOG%
    
    copy %~1 %~d1%~p1\%~n3-%~4.log
) else (
    echo Ignorable error building %~n3 for %~4  >> %SUMMARY_LOG%
)
)

Exit /B 0