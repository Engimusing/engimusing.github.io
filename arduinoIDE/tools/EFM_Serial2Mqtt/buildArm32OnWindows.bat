rem script for cxfreezing a python script for osx from a windows machine. 
rem This requires an ODROID C1 with ssh turned on and a shared fullder setup on the windows box at ODROID_SHARE
rem It also requires bash for windows is installed. It could be rewritten to use another ssh client to remove this requirement if needed.
rem Need version < 5.0 of cxfreeze on the ODROID. cxfreeze 5+ is broken on linux.
set SCRIPT_FOLDER=/home/odroid/cxfreeze/EFM_Serial2Mqtt
set SCRIPT_FILENAME=EFM_Serial2Mqtt.py

set ODROID_SHARE=O:\cxfreeze

mkdir %ODROID_SHARE%\EFM_Serial2Mqtt\
copy /Y .\%SCRIPT_FILENAME% %ODROID_SHARE%\EFM_Serial2Mqtt\

bash -c "ssh odroid@192.168.1.15 'cd %SCRIPT_FOLDER%; /usr/bin/cxfreeze ./%SCRIPT_FILENAME%  --target-dir=linuxArm32'"

mkdir linuxArm32

copy /Y %ODROID_SHARE%\EFM_Serial2Mqtt\linuxArm32\* linuxArm32\
rmdir %ODROID_SHARE%\EFM_Serial2Mqtt /Q /S


pause