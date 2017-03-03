echo off
echo Here are the available serial ports
wmic path win32_pnpentity get caption /format:table | find "(COM"

set S2M_serial=
set S2M_address=
set S2M_port=

set /p S2M_serial=Which serial port would you like to connect to ^<COM1^>: 
set /p S2M_address=Mqtt Address ^<localhost^>: 
set /p S2M_port=Mqtt Port ^<1883^>: 

IF [%S2M_serial%] == [] set S2M_serial=COM1
IF [%S2M_address%] == [] set S2M_address=localhost
IF [%S2M_port%] == [] set S2M_port=1883

echo EFM_Serial2Mqtt.exe -p %S2M_serial% -a %S2M_address% -m %S2M_port%

echo echo off > EFM_Serial2Mqtt_Saved.bat
echo EFM_Serial2Mqtt.exe -p %S2M_serial% -a %S2M_address% -m %S2M_port% >> EFM_Serial2Mqtt_Saved.bat
echo echo If EFM_Serial2Mqtt failed to run please rerun setup and specify correct parameters >> EFM_Serial2Mqtt_Saved.bat
echo pause >> EFM_Serial2Mqtt_Saved.bat

EFM_Serial2Mqtt_Saved.bat

