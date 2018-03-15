export VERSION=$1

mkdir efm_tools-$VERSION
mkdir efm_tools-$VERSION/efm_upload
mkdir efm_tools-$VERSION/EFM_Serial2Mqtt

#setup linux32-bit
cp efm_upload/*.py efm_tools-$VERSION/efm_upload/
cp EFM_Serial2Mqtt/EFM_Serial2Mqtt.py efm_tools-$VERSION/EFM_Serial2Mqtt/

cp -r efm_upload/linux efm_tools-$VERSION/efm_upload/linux
cp -r EFM_Serial2Mqtt/ubuntu32 efm_tools-$VERSION/EFM_Serial2Mqtt/linux

tar czvf efm_tools-$VERSION-linux32.tar.gz efm_tools-$VERSION

rm -r efm_tools-$VERSION/efm_upload/*
rm -r efm_tools-$VERSION/EFM_Serial2Mqtt/*

#setup linux64-bit
cp efm_upload/*.py efm_tools-$VERSION/efm_upload/
cp EFM_Serial2Mqtt/EFM_Serial2Mqtt.py efm_tools-$VERSION/EFM_Serial2Mqtt/

cp -r efm_upload/linux efm_tools-$VERSION/efm_upload/linux
cp -r EFM_Serial2Mqtt/ubuntu efm_tools-$VERSION/EFM_Serial2Mqtt/linux

tar czvf efm_tools-$VERSION-linux64.tar.gz efm_tools-$VERSION

rm -r efm_tools-$VERSION/efm_upload/*
rm -r efm_tools-$VERSION/EFM_Serial2Mqtt/*

#setup windows 32-bit
cp efm_upload/*.py efm_tools-$VERSION/efm_upload/
cp EFM_Serial2Mqtt/EFM_Serial2Mqtt.py efm_tools-$VERSION/EFM_Serial2Mqtt/

cp -r efm_upload/windows efm_tools-$VERSION/efm_upload/windows
cp -r EFM_Serial2Mqtt/windows efm_tools-$VERSION/EFM_Serial2Mqtt/windows

tar czvf efm_tools-$VERSION-win32.tar.gz efm_tools-$VERSION

rm -r efm_tools-$VERSION/efm_upload/*
rm -r efm_tools-$VERSION/EFM_Serial2Mqtt/*

#setup osx 64-bit
cp efm_upload/*.py efm_tools-$VERSION/efm_upload/
cp EFM_Serial2Mqtt/EFM_Serial2Mqtt.py efm_tools-$VERSION/EFM_Serial2Mqtt/

cp -r efm_upload/macosx efm_tools-$VERSION/efm_upload/macosx
cp -r EFM_Serial2Mqtt/macosx efm_tools-$VERSION/EFM_Serial2Mqtt/macosx

tar czvf efm_tools-$VERSION-osx64.tar.gz efm_tools-$VERSION

rm -r efm_tools-$VERSION/efm_upload/*
rm -r efm_tools-$VERSION/EFM_Serial2Mqtt/*

#setup arm 32-bit
cp efm_upload/*.py efm_tools-$VERSION/efm_upload/
cp EFM_Serial2Mqtt/EFM_Serial2Mqtt.py efm_tools-$VERSION/EFM_Serial2Mqtt/

cp -r efm_upload/linux efm_tools-$VERSION/efm_upload/linux
cp -r EFM_Serial2Mqtt/linuxArm32 efm_tools-$VERSION/EFM_Serial2Mqtt/linux

tar czvf efm_tools-$VERSION-linuxArm32.tar.gz efm_tools-$VERSION

rm -r efm_tools-$VERSION/efm_upload/*
rm -r efm_tools-$VERSION/EFM_Serial2Mqtt/*

rm -r efm_tools-$VERSION/
rm *.tar


mv modules.json old_modules.json
#x86_64-pc-linux-gnu
echo { > modules.json
echo \"version\": \"$VERSION\", >> modules.json
echo \"name\": \"efm_tools\", >> modules.json
echo \"systems\": >> modules.json
echo [ >> modules.json
echo { >> modules.json
echo \"url\": \"http://engimusing.github.io/arduinoIDE/tools/efm_tools-$VERSION-linux64.tar.gz\", >> modules.json
echo -n \"checksum\": \"SHA-256: >> modules.json    
sha256sum efm_tools-$VERSION-linux64.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \", >> modules.json
echo \"host\": \"x86_64-pc-linux-gnu\", >> modules.json
echo \"archiveFileName\": \"efm_tools-$VERSION-linux64.tar.gz\", >> modules.json
echo -n \"size\": \" >> modules.json
wc -c efm_tools-$VERSION-linux64.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \" >> modules.json
echo }, >> modules.json

#i686-pc-linux-gnu
echo { >> modules.json
echo \"url\": \"http://engimusing.github.io/arduinoIDE/tools/efm_tools-$VERSION-linux32.tar.gz\", >> modules.json
echo -n \"checksum\": \"SHA-256: >> modules.json    
sha256sum efm_tools-$VERSION-linux32.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \", >> modules.json
echo \"host\": \"i686-pc-linux-gnu\", >> modules.json
echo \"archiveFileName\": \"efm_tools-$VERSION-linux32.tar.gz\", >> modules.json
echo -n \"size\": \" >> modules.json
wc -c efm_tools-$VERSION-linux32.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \" >> modules.json
echo }, >> modules.json

#Arm32
echo { >> modules.json
echo \"url\": \"http://engimusing.github.io/arduinoIDE/tools/efm_tools-$VERSION-linuxArm32.tar.gz\", >> modules.json
echo -n \"checksum\": \"SHA-256: >> modules.json    
sha256sum efm_tools-$VERSION-linuxArm32.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \", >> modules.json
echo \"host\": \"arm-linux-gnueabihf\", >> modules.json
echo \"archiveFileName\": \"efm_tools-$VERSION-linuxArm32.tar.gz\", >> modules.json
echo -n \"size\": \" >> modules.json
wc -c efm_tools-$VERSION-linuxArm32.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \" >> modules.json
echo }, >> modules.json


#i686-mingw32
echo { >> modules.json
echo \"url\": \"http://engimusing.github.io/arduinoIDE/tools/efm_tools-$VERSION-win32.tar.gz\", >> modules.json
echo -n \"checksum\": \"SHA-256: >> modules.json    
sha256sum efm_tools-$VERSION-win32.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \", >> modules.json
echo \"host\": \"i686-mingw32\", >> modules.json
echo \"archiveFileName\": \"efm_tools-$VERSION-win32.tar.gz\", >> modules.json
echo -n \"size\": \" >> modules.json
wc -c efm_tools-$VERSION-win32.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \" >> modules.json
echo }, >> modules.json

#x86_64-apple-darwin
echo { >> modules.json
echo \"url\": \"http://engimusing.github.io/arduinoIDE/tools/efm_tools-$VERSION-osx64.tar.gz\", >> modules.json
echo -n \"checksum\": \"SHA-256: >> modules.json    
sha256sum efm_tools-$VERSION-osx64.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \", >> modules.json
echo \"host\": \"x86_64-apple-darwin\", >> modules.json
echo \"archiveFileName\": \"efm_tools-$VERSION-osx64.tar.gz\", >> modules.json
echo -n \"size\": \" >> modules.json
wc -c efm_tools-$VERSION-osx64.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \" >> modules.json
echo }, >> modules.json

#i386-apple-darwin
echo { >> modules.json
echo \"url\": \"http://engimusing.github.io/arduinoIDE/tools/efm_tools-$VERSION-osx64.tar.gz\", >> modules.json
echo -n \"checksum\": \"SHA-256: >> modules.json    
sha256sum efm_tools-$VERSION-osx64.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \", >> modules.json
echo \"host\": \"i386-apple-darwin\", >> modules.json
echo \"archiveFileName\": \"efm_tools-$VERSION-osx64.tar.gz\", >> modules.json
echo -n \"size\": \" >> modules.json
wc -c efm_tools-$VERSION-osx64.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> modules.json
echo \" >> modules.json
echo } >> modules.json

echo ] >> modules.json
echo }, >> modules.json
cat old_modules.json >> modules.json
