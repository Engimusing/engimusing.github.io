rem script for cxfreezing a python script for ubuntu from a windows machine. 
rem This script requires bash for windows is installed. It could be rewritten to use another ssh client to remove this requirement if needed.
set SCRIPT_FILENAME=./EFM_Serial2Mqtt.py
bash -c "cxfreeze %SCRIPT_FILENAME%  --target-dir=ubuntu"
pause