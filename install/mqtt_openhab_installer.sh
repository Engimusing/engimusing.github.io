#!/bin/bash

# -------- Check that JAVA is installed and the version

JAVA_VER=$(java -version 2>&1 | grep -i version | sed 's/.*version ".*\.\(.*\)\..*"/\1/; 1q')
JAVA_NUM=$(java -version 2>&1 | grep -i version | sed 's/.*version ".*\_\(.*\)\.*"/\1/; 1q')

echo "Checking for java:"
if type -p java >/dev/null; then
    if [ "$JAVA_VER" -ge 8 ] && [ "$JAVA_NUM" -ge 101 ]; then
	echo "  ok, java is 8_121 or newer"
    else
	echo "  The java on your system is too old. Build must be greater than 8_121 yours is $JAVA_VER""_$JAVA_NUM"
	echo "  Upgrade yours based on http://docs.openhab.org/installation/index.html#prerequisites"
	exit
    fi
else
    echo "  java was not found on your system"
    echo "  Install java based on http://docs.openhab.org/installation/index.html#prerequisites"
fi

# -------- Check if mosquitto is installed and install if not

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' mosquitto|grep "install ok installed")
echo Checking for mosquitto:
if [ "" == "$PKG_OK" ]; then
  echo "  mosquitto is not installed - installing it..."
  sudo apt-get -y install mosquitto
else
    echo "  mosquitto is installed"
fi

# -------- Check if mosquitto-clients is installed and install if not

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' mosquitto-clients|grep "install ok installed")
echo Checking for mosquitto-clients:
if [ "" == "$PKG_OK" ]; then
  echo "  mosquitto-clients is not installed - installing it..."
  sudo apt-get -y install mosquitto-clients
else
    echo "  mosquitto-clients is installed"
fi

# -------- Check if openhab2 is installed and install if not

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' openhab2|grep "install ok installed")
echo Checking for openhab2:
if [ "" == "$PKG_OK" ]; then
  echo "  openhab2 is not installed - installing it..."
  wget -qO - 'https://bintray.com/user/downloadSubjectPublicKey?username=openhab' | sudo apt-key add -
  echo 'deb http://dl.bintray.com/openhab/apt-repo2 stable main' | sudo tee /etc/apt/sources.list.d/openhab2.list
  sudo apt-get update
  sudo apt-get -y --allow-unauthenticated install openhab2
else
    echo "  openhab2 is installed"
fi

# -------- Configure openhab2 for first start
# -------- TODO verify addons.cfg exists first

sudo sed -i 's/#package = minimal/package = standard/' /etc/openhab2/services/addons.cfg
sudo sed -i 's/#binding = /binding = mqtt1/' /etc/openhab2/services/addons.cfg
sudo sed -i 's/#ui = /ui = paper,basic,habmin/' /etc/openhab2/services/addons.cfg
echo "configured openhab2 for first start"

# -------- Start openhab2 and configure it to start on boot

echo "Checking for systemd"
if type -p systemctl >/dev/null; then
    echo "found systemctl"
    sudo systemctl start openhab2.service
    sudo systemctl daemon-reload
    sudo systemctl enable openhab2.service
else
    echo "will try sysvinit"
    sudo /etc/init.d/openhab2 start
    sudo /etc/init.d/openhab2 status
    sudo update-rc.d openhab2 defaults
fi
echo "Started openhab2"

# -------- Set up permissions and add user to openhab group

echo "group write permission for /etc/openhab2"
sudo chmod -R g+w /etc/openhab2
ls -l /etc/openhab2

echo "add user to openhab group"
sudo usermod -a -G openhab $(whoami)
sudo usermod -a -G dialout $(whoami)
newgrp $(whoami)


# -------- Wait for openhab to start (it can take a while on some systems

echo "wait for openhab2 to start..."

while [ ! -f /etc/openhab2/services/mqtt.cfg ];
do
    sleep 1;
    echo -ne '.'
done;
sleep 1;
echo "openhab2 started"

# -------- Configure the MQTT binding to connect openhab to the mosquitto broker

sudo sed -i '/url/amqtt:localBroker.url=tcp://localhost:1883' /etc/openhab2/services/mqtt.cfg
sudo sed -i '/clientID/amqtt:localBroker.clientId=openHab' /etc/openhab2/services/mqtt.cfg
sudo sed -i '/qos/amqtt:localBroker.qos=1' /etc/openhab2/services/mqtt.cfg
echo "configured /etc/openhab2/services/mqtt.cfg"

# -------- Prepare for SmartHome Designer installation

sudo mkdir /opt/smarthome-designer
echo "created /opt/smarthome-designer directory"
ls -l /opt/

# -------- Download SmartHome Designer

echo "Downloading SmartHome Designer"
curl https://mirrors.xmission.com/eclipse/smarthome/stable-snapshots/eclipsesmarthome-incubation-0.9.0-SNAPSHOT-designer-linux64.zip > ~/Downloads/shd.zip

sudo mv ~/Downloads/shd.zip /opt/smarthome-designer/

echo "unzip SmartHome Designer"
sudo unzip -q /opt/smarthome-designer/shd.zip -d /opt/smarthome-designer

echo "delete shd.zip"
sudo rm -f /opt/smarthome-designer/shd.zip

echo "mkdir .settings file"
sudo mkdir /opt/smarthome-designer/configuration/.settings

echo "add configuration files to add CONFIG_FOLDER_PREFERENCE=/etc/openhab2 to prefs"
curl http://engimusing.github.io/install/org.eclipse.platform_4.4.0_157788997_linux_gtk_x86_64.tar.gz > ~/Downloads/org.eclipse.platform_4.4.0_157788997_linux_gtk_x86_64.tar.gz
mkdir -p ~/.eclipse
tar -xf ~/Downloads/org.eclipse.platform_4.4.0_157788997_linux_gtk_x86_64.tar.gz -C ~/.eclipse/


echo "Download the logo"
curl http://engimusing.github.io/engimusing_logo.jpg > ~/Downloads/engimusing_logo.jpg
sudo mv ~/Downloads/engimusing_logo.jpg /opt/smarthome-designer

echo "change owner of /opt/smarthome-designer to openhab"
sudo chown -R openhab:openhab /opt/smarthome-designer/

echo "add desktop start icon for SmartHome Designer"
echo "[Desktop Entry]" > ~/Desktop/smarthome-designer.desktop
echo "Name=SmartHome Designer" >> ~/Desktop/smarthome-designer.desktop
echo "Comment=SmartHome Designer" >> ~/Desktop/smarthome-designer.desktop
echo "Exec=/opt/smarthome-designer/SmartHome-Designer" >> ~/Desktop/smarthome-designer.desktop
echo "Terminal=false" >> ~/Desktop/smarthome-designer.desktop
echo "Categories=Development;IDE;Electronics" >> ~/Desktop/smarthome-designer.desktop
echo "Type=Application" >> ~/Desktop/smarthome-designer.desktop
echo "Icon=/opt/smarthome-designer/engimusing_logo.jpg" >> ~/Desktop/smarthome-designer.desktop

echo "make desktop icon executable"
chmod a+x ~/Desktop/smarthome-designer.desktop



