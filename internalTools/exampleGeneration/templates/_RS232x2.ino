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
/* Example for how to print out readings from the {{ Strs.FilePrefix }} RS232x2 Engimusing board
    There are 2 devices on this board. An LED and a {{ Strs.FilePrefix }} {{ Strs.DeviceDescription }}.
    See {{ Strs.RS232x2DeviceURL }} for more information about the board.
*/

#if !defined({{ Strs.RS232x2BoardType }})
#error Incorrect Board Selected! Please select Engimusing {{ Strs.RS232x2BoardType }} from the Tools->Board: menu.
#endif

{% if Strs.DeviceCount > 0 %}
{% for device in Strs.DeviceTypeSet %}
#include <{{ device }}Device.h>
{% endfor %}
{% else %}
#include <{{ Strs.DeviceType }}Device.h>
{% endif %}
{{ Strs.DeviceAdditionalIncludes }}

{% if Strs.DeviceCount > 0 %}
{% for device in Strs.DeviceType %}
{{ Strs.DeviceType[loop.index0] }}Device {{ Strs.DeviceObjName[loop.index0] }};
{% endfor %}
{% else %}
{{ Strs.DeviceType }}Device {{ Strs.DeviceType }};
{% endif %}
TogglePin led;
Timeout serialTimer;

void setup()
{
  Serial.begin(115200);
  Serial1.begin(115200);

  Serial.println("Simple {{ Strs.FilePrefix }} example 0");
  Serial1.println("Simple {{ Strs.FilePrefix }} example 1");
  led.begin(1000);
  serialTimer.begin(1000,true);
 
  {{ Strs.DeviceBeginComment }}
{% if Strs.DeviceCount > 0 %}
{% for device in Strs.DeviceType %}
  {{ Strs.DeviceObjName[loop.index0] }}.begin({{ Strs.RS232x2DeviceBeginParameters[loop.index0] }});
{% endfor %}
{% else %}
  {{ Strs.DeviceType }}.begin({{ Strs.RS232x2DeviceBeginParameters }});
{% endif %}
}

void loop()
{


{% if Strs.DeviceCount > 0 %}
{% for device in Strs.DeviceType %}
  {{ Strs.DeviceObjName[loop.index0] }}.update();
{% endfor %}
{% else %}
  {{ Strs.DeviceType }}.update();
{% endif %}

  {{ Strs.SerialParser }}
  {{ Strs.Serial1Parser }}
{% if Strs.SerialPrintout %}
  if(serialTimer.update())
  { {{ Strs.SerialPrintout }}
  {{ Strs.Serial1Printout }}
  }
{% endif %}
  led.update();
}
{% endif %}
