 {% set DeviceType = replacements['DeviceType'] %}
 {% set DeviceDescription = replacements['DeviceDescription'] %}
 {% set RS232x2BoardType = replacements['RS232x2BoardType'] %}
 {% set DF11BoardType = replacements['DF11BoardType'] %}
 {% set DeviceURL = replacements['DeviceURL'] %}
 {% set DeviceAdditionalIncludes = replacements['DeviceAdditionalIncludes'] %}
 {% set RS232x2DeviceBeginParameters = replacements['RS232x2DeviceBeginParameters'] %} 
 {% set DF11DeviceBeginParameters = replacements['DF11DeviceBeginParameters'] %} 
 {% set SerialPrintout = replacements['SerialPrintout'] %}
 {% set Serial1Printout = replacements['Serial1Printout'] %}
 {% set DeviceBeginComment = replacements['DeviceBeginComment'] %}
/*
  Copyright (c) 2016-{{ Year }} Engimusing LLC.  All right reserved.
  
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
/* Example for how to setup the MQTT client for the {{ DeviceType }} RS232x2 Engimusing board
    There are 2 devices on this board. An LED and a {{ DeviceType }} {{ DeviceDescription }}.
    See {{ DeviceURL }} for more information about the board.
*/

#if !defined({{ RS232x2BoardType }})
#error Incorrect Board Selected! Please select Engimusing {{ RS232x2BoardType }} from the Tools->Board: menu.
#endif

//Include the MqttModule to get the MQTT client classes
#include <MqttHub.h>
#include <MqttPort.h>
#include <MqttModule.h>

#include <{{ DeviceType }}Device.h>
{{ DeviceAdditionalIncludes }}

/*
  {{ RS232x2BoardType }} Commands:
  {"TOP":"{{ RS232x2BoardType }}/BOARD/LED/CTL","PLD":"ON"}
  {"TOP":"{{ RS232x2BoardType }}/BOARD/LED/CTL","PLD":"OFF"}
  {"TOP":"{{ RS232x2BoardType }}/BOARD/LED/CTL","PLD":"STATUS"}

  {"TOP":"{{ RS232x2BoardType }}/BOARD/{{ DeviceType }}/","PLD":"STATUS"}
*/

MqttHub HUB;
MqttSerialPort serialPort1;
MqttSerialPort serialPort2;

//MQTT class defintions
// The MqttModule classes are automatically registered with the COMM
// object when begin() is called so they can be updated
// whenever HUB.update() is called.
OnOffCtlModule LEDCtrl;

{{ DeviceType }}Device {{ DeviceType }};
SimpleMqttModule {{ DeviceType }}MqttMod;


void setup() 
{
  serialPort1.begin(HUB, Serial);
  serialPort2.begin(HUB, Serial1);

  //Initialize the on off control to connect it to
  // the LED that is on the board
  LEDCtrl.begin(HUB, 13, "{{ RS232x2BoardType }}/BOARD/LED", HIGH);


  {{ DeviceBeginComment }}
  {{ DeviceType }}.begin({{ RS232x2DeviceBeginParameters }});
  {{ DeviceType }}MqttMod.begin(HUB, {{ DeviceType }}, "{{ RS232x2BoardType }}/BOARD/{{ DeviceType }}", 10000);
}

void loop() {

  //Update the MQTT communication so it
  // can send statuses and recieve requests
  HUB.update();

}
