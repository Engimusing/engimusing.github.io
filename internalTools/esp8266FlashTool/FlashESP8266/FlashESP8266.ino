/*
  Copyright (c) 2016 Engimusing LLC.  All right reserved.

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include "MqttESP8266Port.h"

#define pinConfig esp8266_0_pinConfig

#define FLASHMODE

void setup() {
  pinConfig.serial.begin(115200);
  
  pinMode(pinConfig.resetPin, OUTPUT);
  digitalWrite(pinConfig.resetPin, HIGH); 

  pinMode(pinConfig.powerPin, OUTPUT);
  digitalWrite(pinConfig.powerPin, LOW);   // turn off the Wifi board

#ifdef FLASHMODE
  //put the ESP8266 in flash programming mode
  pinMode(pinConfig.gpio0Pin, OUTPUT);
  digitalWrite(pinConfig.gpio0Pin, LOW);  
#else
  //put the ESP8266 in flash programming mode
  pinMode(pinConfig.gpio0Pin, OUTPUT);
  digitalWrite(pinConfig.gpio0Pin, HIGH);  
#endif
  delay(2000);
  
  pinMode(pinConfig.powerPin, OUTPUT);
  digitalWrite(pinConfig.powerPin, HIGH);   // turn on the Wifi board


  pinMode(ledId[2], OUTPUT);
  digitalWrite(ledId[2], LOW);   // turn the LED

  Serial.println("ESP8266 Flash Programming!!!");
}

void loop() {  
  if(pinConfig.serial.available())
  {
    Serial.print((char)pinConfig.serial.read());
  }
  if(Serial.available())
  {
    char readValue = Serial.read();
    pinConfig.serial.print(readValue);
  }
}

