echo off 
EFM_Serial2Mqtt.exe -p COM1 -a localhost -m 1883 
echo If EFM_Serial2Mqtt failed to run please rerun setup and specify correct parameters 
pause 
