mkdir efm_upload-1.0
mkdir EFM_Serial2Mqtt-1.0

#setup linux32-bit
cp efm_upload/efm_upload.py efm_upload-1.0/
cp EFM_Serial2Mqtt/EFM_Serial2Mqtt.py EFM_Serial2Mqtt-1.0/

cp -r efm_upload/linux efm_upload-1.0/linux
cp -r EFM_Serial2Mqtt/ubuntu32 EFM_Serial2Mqtt-1.0/linux

tar cvf efm_tools-1.0-linux32.tar efm_upload-1.0
tar rvf efm_tools-1.0-linux32.tar EFM_Serial2Mqtt-1.0
gzip -c efm_tools-1.0-linux32.tar > efm_tools-1.0-linux32.tar.gz

rm -r efm_upload-1.0/*
rm -r EFM_Serial2Mqtt-1.0/*

#setup windows 32-bit
cp efm_upload/efm_upload.py efm_upload-1.0/
cp EFM_Serial2Mqtt/EFM_Serial2Mqtt.py EFM_Serial2Mqtt-1.0/

cp -r efm_upload/windows efm_upload-1.0/windows
cp -r EFM_Serial2Mqtt/windows EFM_Serial2Mqtt-1.0/windows

tar cvf efm_tools-1.0-win32.tar efm_upload-1.0
tar rvf efm_tools-1.0-win32.tar EFM_Serial2Mqtt-1.0
gzip -c efm_tools-1.0-win32.tar > efm_tools-1.0-win32.tar.gz

rm -r efm_upload-1.0/*
rm -r EFM_Serial2Mqtt-1.0/*

#setup osx 64-bit
cp efm_upload/efm_upload.py efm_upload-1.0/
cp EFM_Serial2Mqtt/EFM_Serial2Mqtt.py EFM_Serial2Mqtt-1.0/

cp -r efm_upload/macosx efm_upload-1.0/macosx
cp -r EFM_Serial2Mqtt/macosx EFM_Serial2Mqtt-1.0/macosx

tar cvf efm_tools-1.0-osx64.tar efm_upload-1.0
tar rvf efm_tools-1.0-osx64.tar EFM_Serial2Mqtt-1.0
gzip -c efm_tools-1.0-osx64.tar > efm_tools-1.0-osx64.tar.gz


rm -r efm_upload-1.0/
rm -r EFM_Serial2Mqtt-1.0/

rm *.tar

#x86_64-pc-linux-gnu
echo \"systems\": > modules.json
echo [ >> modules.json
echo { >> modules.json
echo \"url\": \"http://engimusing.github.io/arduinoIDE/tools/efm_tools-1.0-linux32.tar.gz\", >> modules.json
echo -n \"checksum\": \"SHA-256: >> modules.json    
sha256sum efm_tools-1.0-linux32.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \", >> modules.json
echo \"host\": \"x86_64-pc-linux-gnu\", >> modules.json
echo \"archiveFileName\": \"efm_tools-1.0-linux32.tar.gz\", >> modules.json
echo -n \"size\": \" >> modules.json
wc -c efm_tools-1.0-linux32.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \" >> modules.json
echo }, >> modules.json

#i686-pc-linux-gnu
echo { >> modules.json
echo \"url\": \"http://engimusing.github.io/arduinoIDE/tools/efm_tools-1.0-linux32.tar.gz\", >> modules.json
echo -n \"checksum\": \"SHA-256: >> modules.json    
sha256sum efm_tools-1.0-linux32.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \", >> modules.json
echo \"host\": \"i686-pc-linux-gnu\", >> modules.json
echo \"archiveFileName\": \"efm_tools-1.0-linux32.tar.gz\", >> modules.json
echo -n \"size\": \" >> modules.json
wc -c efm_tools-1.0-linux32.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \" >> modules.json
echo }, >> modules.json

#i686-mingw32
echo { >> modules.json
echo \"url\": \"http://engimusing.github.io/arduinoIDE/tools/efm_tools-1.0-win32.tar.gz\", >> modules.json
echo -n \"checksum\": \"SHA-256: >> modules.json    
sha256sum efm_tools-1.0-win32.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \", >> modules.json
echo \"host\": \"i686-mingw32\", >> modules.json
echo \"archiveFileName\": \"efm_tools-1.0-win32.tar.gz\", >> modules.json
echo -n \"size\": \" >> modules.json
wc -c efm_tools-1.0-win32.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \" >> modules.json
echo }, >> modules.json

#x86_64-apple-darwin
echo { >> modules.json
echo \"url\": \"http://engimusing.github.io/arduinoIDE/tools/efm_tools-1.0-osx64.tar.gz\", >> modules.json
echo -n \"checksum\": \"SHA-256: >> modules.json    
sha256sum efm_tools-1.0-osx64.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \", >> modules.json
echo \"host\": \"x86_64-apple-darwin\", >> modules.json
echo \"archiveFileName\": \"efm_tools-1.0-osx64.tar.gz\", >> modules.json
echo -n \"size\": \" >> modules.json
wc -c efm_tools-1.0-osx64.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \" >> modules.json
echo }, >> modules.json

#i386-apple-darwin
echo { >> modules.json
echo \"url\": \"http://engimusing.github.io/arduinoIDE/tools/efm_tools-1.0-osx64.tar.gz\", >> modules.json
echo -n \"checksum\": \"SHA-256: >> modules.json    
sha256sum efm_tools-1.0-osx64.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \", >> modules.json
echo \"host\": \"i386-apple-darwin\", >> modules.json
echo \"archiveFileName\": \"efm_tools-1.0-osx64.tar.gz\", >> modules.json
echo -n \"size\": \" >> modules.json
wc -c efm_tools-1.0-osx64.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \" >> modules.json
echo } >> modules.json


