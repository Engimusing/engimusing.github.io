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
/* Example for how to setup the MQTT client for the {{ Strs.FilePrefix }} DF11 board using the {{ Strs.DF11BoardType }} Engimusing board
    There are 2 devices on this board. An LED and a {{ Strs.FilePrefix }} {{ Strs.DeviceDescription }}.
    See {{ Strs.DF11DeviceURL }} for more information about the board.
*/

#if !defined({{ Strs.DF11BoardType }})
#error Incorrect Board Selected! Please select Engimusing {{ Strs.DF11BoardType }} from the Tools->Board: menu.
#endif

//Include the MqttModule to get the MQTT client classes
#include <MqttHub.h>
#include <MqttPort.h>
#include <MqttModule.h>

{% if Strs.DeviceCount > 0 %}
{% for device in Strs.DeviceTypeSet %}
#include <{{ device }}Device.h>
{% endfor %}
{% else %}
#include <{{ Strs.DeviceType }}Device.h>
{% endif %}
{{ Strs.DeviceAdditionalIncludes }}

/*
  {{ Strs.DF11BoardType }} Commands:
  {"TOP":"{{ Strs.DF11BoardType }}/BOARD/LED/CTL","PLD":"ON"}
  {"TOP":"{{ Strs.DF11BoardType }}/BOARD/LED/CTL","PLD":"OFF"}
  {"TOP":"{{ Strs.DF11BoardType }}/BOARD/LED/CTL","PLD":"STATUS"}

{% if Strs.DeviceCount > 0 %}
{% for device in Strs.DeviceType %}
  {"TOP":"{{ Strs.DF11BoardType }}/BOARD/{{ Strs.DeviceObjName[loop.index0] }}/","PLD":"STATUS"}
{% endfor %}
{% else %}
  {"TOP":"{{ Strs.DF11BoardType }}/BOARD/{{ Strs.DeviceType }}/","PLD":"STATUS"}
{% endif %}
*/

MqttHub HUB;
MqttSerialPort serialPort;

//MQTT class defintions
// The MqttModule classes are automatically registered with the COMM
// object when begin() is called so they can be updated
// whenever HUB.update() is called.
OnOffCtlModule LEDCtrl;

{% if Strs.DeviceCount > 0 %}
{% for device in Strs.DeviceType %}
{{ Strs.DeviceType[loop.index0] }}Device {{ Strs.DeviceObjName[loop.index0] }};
SimpleMqttModule {{ Strs.DeviceObjName[loop.index0] }}MqttMod;
{% endfor %}
{% else %}
{{ Strs.DeviceType }}Device {{ Strs.DeviceType }};
SimpleMqttModule {{ Strs.DeviceType }}MqttMod;
{% endif %}

void setup() 
{
  serialPort.begin(HUB, Serial);

  //Initialize the on off control to connect it to
  // the LED that is on the board
  LEDCtrl.begin(HUB, 13, "{{ Strs.DF11BoardType }}/BOARD/LED", HIGH);

  {{ Strs.DeviceBeginComment }}
  {% if Strs.DeviceCount > 0 %}
{% for device in Strs.DeviceType %}
  {{ Strs.DeviceObjName[loop.index0] }}.begin({{ Strs.DF11DeviceBeginParameters[loop.index0] }});
  {{ Strs.DeviceObjName[loop.index0] }}MqttMod.begin(HUB, {{ Strs.DeviceObjName[loop.index0] }}, "{{ Strs.DF11BoardType }}/BOARD/{{ Strs.DeviceObjName[loop.index0] }}", 10000);
{% endfor %}
{% else %}
  {{ Strs.DeviceType }}.begin({{ Strs.DF11DeviceBeginParameters }});
  {{ Strs.DeviceType }}MqttMod.begin(HUB, {{ Strs.DeviceType }}, "{{ Strs.DF11BoardType }}/BOARD/{{ Strs.DeviceType }}", 10000);
{% endif %}
}

void loop() 
{

  //Update the MQTT communication so it
  // can send statuses and recieve requests
  HUB.update();

}
{% endif %}