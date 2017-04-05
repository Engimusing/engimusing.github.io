{% set DeviceType = replacements['DeviceType'] %}
{% set DeviceDescription = replacements['DeviceDescription'] %}
{% set RS232x2BoardType = replacements['RS232x2BoardType'] %}
{% set DF11BoardType = replacements['DF11BoardType'] %}
{% set RS232x2DeviceURL = replacements['RS232x2DeviceURL'] %}
{% set DF11DeviceURL = replacements['DF11DeviceURL'] %}
{% set DeviceAdditionalIncludes = replacements['DeviceAdditionalIncludes'] %}
{% set RS232x2DeviceBeginParameters = replacements['RS232x2DeviceBeginParameters'] %} 
{% set DF11DeviceBeginParameters = replacements['DF11DeviceBeginParameters'] %} 
{% set SerialPrintout = replacements['SerialPrintout'] %}
{% set Serial1Printout = replacements['Serial1Printout'] %}
{% set DeviceBeginComment = replacements['DeviceBeginComment'] %}
{% if replacements['GenerateRS232x2'] == '1' %}
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
/* Example for how to print out readings from the {{ DeviceType }} RS232x2 Engimusing board
    There are 2 devices on this board. An LED and a {{ DeviceType }} {{ DeviceDescription }}.
    See {{ RS232x2DeviceURL }} for more information about the board.
*/

#if !defined({{ RS232x2BoardType }})
#error Incorrect Board Selected! Please select Engimusing {{ RS232x2BoardType }} from the Tools->Board: menu.
#endif

#include <{{ DeviceType }}Device.h>
{{ DeviceAdditionalIncludes }}

{{ DeviceType }}Device {{ DeviceType }};

void setup()
{
Serial.begin(115200);
Serial1.begin(115200);

pinMode(LED_BUILTIN, OUTPUT);
Serial.println("Simple {{ DeviceType }} example 0");
Serial1.println("Simple {{ DeviceType }} example 1");

{{ DeviceBeginComment }}
{{ DeviceType }}.begin({{ RS232x2DeviceBeginParameters }});
}

int lastMillis = 0; // store the last time the current was printed.
int printDelay = 1000; //print every second.

void loop()
{

static int on = HIGH;

{{ DeviceType }}.update();

if(millis() - lastMillis > printDelay)
{
lastMillis = millis();

digitalWrite(LED_BUILTIN, on); // toggle the LED (HIGH is the voltage level)
{{ SerialPrintout }}
{{ Serial1Printout }}

on = (on) ? LOW : HIGH; // on alternates between LOW and HIGH
}
}
{% endif %}