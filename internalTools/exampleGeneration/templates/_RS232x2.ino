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

#include <DevicePrinter.h>

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
DevicePrinter {{ Strs.DeviceObjName[loop.index0] }}Printer0;
DevicePrinter {{ Strs.DeviceObjName[loop.index0] }}Printer1;
{% endfor %}
{% else %}
{{ Strs.DeviceType }}Device {{ Strs.DeviceType }};
DevicePrinter {{ Strs.DeviceType }}Printer0;
DevicePrinter {{ Strs.DeviceType }}Printer1;
{% endif %}
TOGGLEClass led;

void setup()
{
  Serial.begin(115200);
  Serial1.begin(115200);

  Serial.println("Simple {{ Strs.FilePrefix }} example 0");
  Serial1.println("Simple {{ Strs.FilePrefix }} example 1");
  led.begin(1000);
 
  {% if Strs.DeviceCount > 0 %}
  {% for device in Strs.DeviceType %}
  {{ Strs.DeviceObjName[loop.index0] }}Printer0.begin(Serial, {{ Strs.DeviceObjName[loop.index0] }}, 5000, "{{ Strs.DeviceObjName[loop.index0] }}");
  {{ Strs.DeviceObjName[loop.index0] }}Printer1.begin(Serial1, {{ Strs.DeviceObjName[loop.index0] }}, 5000, "{{ Strs.DeviceObjName[loop.index0] }}");
  {% endfor %}
  {% else %}
  {{ Strs.DeviceType }}Printer0.begin(Serial, {{ Strs.DeviceType }}, 5000, "{{ Strs.DeviceType }}");
  {{ Strs.DeviceType }}Printer1.begin(Serial1, {{ Strs.DeviceType }}, 5000, "{{ Strs.DeviceType }}");
  {% endif %}
  
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

{% if Strs.DeviceCount > 0 %}
  {% for device in Strs.DeviceType %}
  {{ Strs.DeviceObjName[loop.index0] }}Printer0.update();
  {{ Strs.DeviceObjName[loop.index0] }}Printer1.update();
  {% endfor %}
  {% else %}
  {{ Strs.DeviceType }}Printer0.update();
  {{ Strs.DeviceType }}Printer1.update();
  {% endif %}
  led.update();
}
{% endif %}
