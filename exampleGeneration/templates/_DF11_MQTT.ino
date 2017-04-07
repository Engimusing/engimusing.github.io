{% import 'setupVariables.txt' as Strs with context %}
{% if replacements['GenerateDF11'] == '1' %}
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
/* Example for how to setup the MQTT client for the {{ Strs.DeviceType }} DF11 board using the {{ Strs.DF11BoardType }} Engimusing board
    There are 2 devices on this board. An LED and a {{ Strs.DeviceType }} {{ Strs.DeviceDescription }}.
    See {{ Strs.DF11DeviceURL }} for more information about the board.
*/

#if !defined({{ Strs.DF11BoardType }})
#error Incorrect Board Selected! Please select Engimusing {{ Strs.DF11BoardType }} from the Tools->Board: menu.
#endif

//Include the MqttModule to get the MQTT client classes
#include <MqttHub.h>
#include <MqttPort.h>
#include <MqttModule.h>

#include <{{ Strs.DeviceType }}Device.h>
{{ Strs.DeviceAdditionalIncludes }}

/*
  {{ Strs.DF11BoardType }} Commands:
  {"TOP":"{{ Strs.DF11BoardType }}/BOARD/LED/CTL","PLD":"ON"}
  {"TOP":"{{ Strs.DF11BoardType }}/BOARD/LED/CTL","PLD":"OFF"}
  {"TOP":"{{ Strs.DF11BoardType }}/BOARD/LED/CTL","PLD":"STATUS"}

  {"TOP":"{{ Strs.DF11BoardType }}/BOARD/{{ Strs.DeviceType }}/","PLD":"STATUS"}
*/

MqttHub HUB;
MqttSerialPort serialPort;

//MQTT class defintions
// The MqttModule classes are automatically registered with the COMM
// object when begin() is called so they can be updated
// whenever HUB.update() is called.
OnOffCtlModule LEDCtrl;

{{ Strs.DeviceType }}Device {{ Strs.DeviceType }};
SimpleMqttModule {{ Strs.DeviceType }}MqttMod;

void setup() 
{
  serialPort.begin(HUB, Serial);

  //Initialize the on off control to connect it to
  // the LED that is on the board
  LEDCtrl.begin(HUB, 13, "{{ Strs.DF11BoardType }}/BOARD/LED", HIGH);

  {{ Strs.DeviceBeginComment }}
  {{ Strs.DeviceType }}.begin({{ Strs.DF11DeviceBeginParameters }});
  {{ Strs.DeviceType }}MqttMod.begin(HUB, {{ Strs.DeviceType }}, "{{ Strs.DF11BoardType }}/BOARD/{{ Strs.DeviceType }}", 10000);
}

void loop() 
{

  //Update the MQTT communication so it
  // can send statuses and recieve requests
  HUB.update();

}
{% endif %}