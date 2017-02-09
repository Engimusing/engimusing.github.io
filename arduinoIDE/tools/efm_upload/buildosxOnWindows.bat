rem script for cxfreezing a python script for osx from a windows machine. 
rem This requires an osx VM with ssh turned on
rem It also requires bash for windows is installed. It could be rewritten to use another ssh client to remove this requirement if needed.
set SCRIPT_FOLDER=/Volumes/D/emus2016/gitrepos/engimusingio/arduinoIDE/tools/efm_upload
set SCRIPT_FILENAME=./efm_upload.py
bash -c "ssh Tim@192.168.56.101 'cd %SCRIPT_FOLDER%; /Library/Frameworks/Python.framework/Versions/2.7/bin/cxfreeze %SCRIPT_FILENAME%  --target-dir=macosx'"
pause