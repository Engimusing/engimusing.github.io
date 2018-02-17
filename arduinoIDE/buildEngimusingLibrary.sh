export VERSION=1.0.3

export BUILD_TOOLS=0
export TOOLS_VERSION=1.1

mkdir $VERSION
cd $VERSION

git clone https://github.com/Engimusing/engimusing-firmware.git .
cp ./platform.txt ./platform2.txt
sed '19s/.*/version='$VERSION'/' platform2.txt > platform.txt
rm ./platform2.txt

git add platform.txt
git commit -m 'Moving platform.txt upto the new version:'$VERSION
git push
cd ..

tar czvf efm32-$VERSION.tar.gz $VERSION

rm -r $VERSION

if [ $BUILD_TOOLS -eq 1 ]
then
    cd ./tools
    ./buildOsTars.sh $TOOLS_VERSION

    cd ..
fi


echo	{ > buffer.json
echo		    \"name\": \"Engimusing ARM EFM32 Boards\",  >> buffer.json
echo		    \"architecture\": \"efm32\", >> buffer.json
echo		    \"version\": \"$VERSION\", >> buffer.json
echo		    \"category\": \"Contributed\", >> buffer.json
echo		    \"url\": \"http://engimusing.github.io/arduinoIDE/efm32-$VERSION.tar.gz\", >> buffer.json
echo		    \"archiveFileName\": \"efm32-$VERSION.tar.gz\", >> buffer.json
echo		-n    \"checksum\": \"SHA-256: >> buffer.json
sha256sum efm32-$VERSION.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> buffer.json
echo \", >> buffer.json
echo		-n    \"size\": \" >> buffer.json
wc -c efm32-$VERSION.tar.gz | grep -Eo '^[^ ]+' | tr -d '\n' >> buffer.json
echo \", >> buffer.json
echo		    \"help\": { >> buffer.json
echo			\"online\": \"http://www.engimusing.com\" >> buffer.json
echo		    }, >> buffer.json
echo		    \"boards\": [ >> buffer.json >> buffer.json
echo			{\"name\": \"EFM32ZGUSB\"}, >> buffer.json
echo			{\"name\": \"EFM32ZG108\"}, >> buffer.json
echo			{\"name\": \"EFM32ZG222\"}, >> buffer.json
echo			{\"name\": \"EFM32TG110\"}, >> buffer.json
echo			{\"name\": \"EFM32G232\"}, >> buffer.json
echo			{\"name\": \"EFM32WG840\"}, >> buffer.json
echo			{\"name\": \"EFM32WG842\"} >> buffer.json
echo		    ], >> buffer.json
echo		    \"toolsDependencies\": [{ >> buffer.json
echo			\"packager\": \"arduino\", >> buffer.json
echo			\"name\": \"arm-none-eabi-gcc\", >> buffer.json
echo			\"version\": \"4.8.3-2014q1\" >> buffer.json
echo		    }, >> buffer.json
echo	{ >> buffer.json
echo	\"packager\": \"engimusing\", >> buffer.json
echo	\"name\": \"efm_tools\", >> buffer.json
echo	\"version\": \"$TOOLS_VERSION\" >> buffer.json
echo	}] >> buffer.json
echo	}, >> buffer.json

cat package_engimusing_modules_index_part2.json >> buffer.json
mv buffer.json package_engimusing_modules_index_part2.json

cat package_engimusing_modules_index_part1.json > final.json
cat package_engimusing_modules_index_part2.json >> final.json
cat ./tools/modules.json >> final.json
cat package_engimusing_modules_index_part3.json >> final.json

mv final.json package_engimusing_modules_index.json
