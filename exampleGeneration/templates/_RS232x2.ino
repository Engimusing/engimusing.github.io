{% import 'setupVariables.txt' as Strs with context %}
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
/* Example for how to print out readings from the {{ Strs.DeviceType }} RS232x2 Engimusing board
    There are 2 devices on this board. An LED and a {{ Strs.DeviceType }} {{ Strs.DeviceDescription }}.
    See {{ Strs.RS232x2DeviceURL }} for more information about the board.
*/

#if !defined({{ Strs.RS232x2BoardType }})
#error Incorrect Board Selected! Please select Engimusing {{ Strs.RS232x2BoardType }} from the Tools->Board: menu.
#endif

#include <{{ Strs.DeviceType }}Device.h>
{{ Strs.DeviceAdditionalIncludes }}

{{ Strs.DeviceType }}Device {{ Strs.DeviceType }};

void setup()
{
  Serial.begin(115200);
  Serial1.begin(115200);

  pinMode(LED_BUILTIN, OUTPUT); 
  Serial.println("Simple {{ Strs.DeviceType }} example 0");
  Serial1.println("Simple {{ Strs.DeviceType }} example 1");

  {{ Strs.DeviceBeginComment }}
  {{ Strs.DeviceType }}.begin({{ Strs.RS232x2DeviceBeginParameters }});
}

int lastMillis = 0; // store the last time the current was printed.
int printDelay = 1000; //print every second.

void loop()
{

  static int on = HIGH;

  {{ Strs.DeviceType }}.update();

  if(millis() - lastMillis > printDelay)
  {
    lastMillis = millis();

    digitalWrite(LED_BUILTIN, on); // toggle the LED (HIGH is the voltage level)
    {{ Strs.SerialPrintout }}
    {{ Strs.Serial1Printout }}

    on = (on) ? LOW : HIGH; // on alternates between LOW and HIGH
  }
}
{% endif %}