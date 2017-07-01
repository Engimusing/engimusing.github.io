Check the version of the ESP8266 software by uploading the FlashESP8266 ino script from this folder but first comment out the #define FLASHMODE

Once uploaded try sending AT+GMR using the serial monitor and you should see something like this:

AT+GMR

AT version:1.1.0.0(May 11 2016 18:09:56)
SDK version:1.5.4(baaeaebb)
Ai-Thinker Technology Co. Ltd.
Jun 13 2016 11:29:20
OK

If the version is 1.5.4 then that board is good to go. If not then either we need to test it to see if that version works with our other script or upload the 1.5.4 version.

How to flash ESP8266 with version 1.5.4 of the AiThinker Software.

Make sure FLASHMODE is defined in the FlashESP8266 ino script and then upload it to the EFM board. 
If you type AT+GMR on the serial monitor it should not work anymore.
Close the serial monitor if it is open.

Run ./FLASH_DOWNLOAD_TOOLS_V3.4.8/ESPFlashDownloadTool_v3.4.8.exe
Click the ESP8266 DownloadTool button.

Should have the top item checked and set to ..\AiThinker_ESP8266_DIO_32M_32M_20160615_V1.5.4.bin @ 0x000000
Click the start button and it should upload the bin file to the ESP8266. This will take a few minutes.
