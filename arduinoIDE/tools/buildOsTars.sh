mkdir efm_tools-1.0
mkdir efm_tools-1.0/efm_upload
mkdir efm_tools-1.0/EFM_Serial2Mqtt

#setup linux32-bit
cp efm_upload/efm_upload.py efm_tools-1.0/efm_upload/
cp EFM_Serial2Mqtt/EFM_Serial2Mqtt.py efm_tools-1.0/EFM_Serial2Mqtt/

cp -r efm_upload/linux efm_tools-1.0/efm_upload/linux
cp -r EFM_Serial2Mqtt/ubuntu32 efm_tools-1.0/EFM_Serial2Mqtt/linux

tar czvf efm_tools-1.0-linux32.tar.gz efm_tools-1.0

rm -r efm_tools-1.0/efm_upload/*
rm -r efm_tools-1.0/EFM_Serial2Mqtt/*

#setup linux64-bit
cp efm_upload/efm_upload.py efm_tools-1.0/efm_upload/
cp EFM_Serial2Mqtt/EFM_Serial2Mqtt.py efm_tools-1.0/EFM_Serial2Mqtt/

cp -r efm_upload/linux efm_tools-1.0/efm_upload/linux
cp -r EFM_Serial2Mqtt/ubuntu efm_tools-1.0/EFM_Serial2Mqtt/linux

tar czvf efm_tools-1.0-linux64.tar.gz efm_tools-1.0

rm -r efm_tools-1.0/efm_upload/*
rm -r efm_tools-1.0/EFM_Serial2Mqtt/*

#setup windows 32-bit
cp efm_upload/efm_upload.py efm_tools-1.0/efm_upload/
cp EFM_Serial2Mqtt/EFM_Serial2Mqtt.py efm_tools-1.0/EFM_Serial2Mqtt/

cp -r efm_upload/windows efm_tools-1.0/efm_upload/windows
cp -r EFM_Serial2Mqtt/windows efm_tools-1.0/EFM_Serial2Mqtt/windows

tar czvf efm_tools-1.0-win32.tar.gz efm_tools-1.0

rm -r efm_tools-1.0/efm_upload/*
rm -r efm_tools-1.0/EFM_Serial2Mqtt/*

#setup osx 64-bit
cp efm_upload/efm_upload.py efm_tools-1.0/efm_upload/
cp EFM_Serial2Mqtt/EFM_Serial2Mqtt.py efm_tools-1.0/EFM_Serial2Mqtt/

cp -r efm_upload/macosx efm_tools-1.0/efm_upload/macosx
cp -r EFM_Serial2Mqtt/macosx efm_tools-1.0/EFM_Serial2Mqtt/macosx

tar czvf efm_tools-1.0-osx64.tar.gz efm_tools-1.0

rm -r efm_tools-1.0/efm_upload/*
rm -r efm_tools-1.0/EFM_Serial2Mqtt/*

rm -r efm_tools-1.0/
rm *.tar

#x86_64-pc-linux-gnu
echo \"systems\": > modules.json
echo [ >> modules.json
echo { >> modules.json
echo \"url\": \"http://engimusing.github.io/arduinoIDE/tools/efm_tools-1.0-linux64.tar.gz\", >> modules.json
echo -n \"checksum\": \"SHA-256: >> modules.json    
sha256sum efm_tools-1.0-linux64.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \", >> modules.json
echo \"host\": \"x86_64-pc-linux-gnu\", >> modules.json
echo \"archiveFileName\": \"efm_tools-1.0-linux64.tar.gz\", >> modules.json
echo -n \"size\": \" >> modules.json
wc -c efm_tools-1.0-linux64.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
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


