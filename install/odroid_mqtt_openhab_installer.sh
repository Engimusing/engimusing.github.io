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
    exit
fi

# -------- Check that script runs as root
if (( $EUID != 0 )); then
    echo "Script needs root privledges to execute - use sudo ./odroid_mqtt_openhab_installer.sh" >&2
    exit -1
fi

# -------- Check if curl is installed and install if not

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' curl|grep "install ok installed")
echo Checking for curl:
if [ "" == "$PKG_OK" ]; then
  echo "  curl is not installed - installing it..."
  apt-get -y install curl
else
    echo "  curl is installed"
fi

# -------- Check if mosquitto is installed and install if not

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' mosquitto|grep "install ok installed")
echo Checking for mosquitto:
if [ "" == "$PKG_OK" ]; then
  echo "  mosquitto is not installed - installing it..."
  apt-get -y install mosquitto
else
    echo "  mosquitto is installed"
fi

# -------- Check if mosquitto-clients is installed and install if not

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' mosquitto-clients|grep "install ok installed")
echo Checking for mosquitto-clients:
if [ "" == "$PKG_OK" ]; then
  echo "  mosquitto-clients is not installed - installing it..."
  apt-get -y install mosquitto-clients
else
    echo "  mosquitto-clients is installed"
fi

# -------- Check if openhab2 is installed and install if not

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' openhab2|grep "install ok installed")
echo Checking for openhab2:
if [ "" == "$PKG_OK" ]; then
  echo "  openhab2 is not installed - installing it..."
  wget -qO - 'https://bintray.com/user/downloadSubjectPublicKey?username=openhab' | apt-key add -
  echo 'deb http://dl.bintray.com/openhab/apt-repo2 stable main' | tee /etc/apt/sources.list.d/openhab2.list
  apt-get update
  apt-get -y --allow-unauthenticated install openhab2
else
    echo "  openhab2 is installed"
fi

# -------- Configure openhab2 for first start
# -------- TODO verify addons.cfg exists first

sed -i 's/#package = minimal/package = standard/' /etc/openhab2/services/addons.cfg
sed -i 's/#binding = /binding = mqtt1/' /etc/openhab2/services/addons.cfg
sed -i 's/#ui = /ui = paper,basic,habmin/' /etc/openhab2/services/addons.cfg
echo "configured openhab2 for first start"

# -------- Start openhab2 and configure it to start on boot

systemctl start openhab2.service
systemctl daemon-reload
systemctl enable openhab2.service
echo "Started openhab2"

# -------- Set up permissions and add user to openhab group

echo "group write permission for /etc/openhab2"
chmod -R g+w /etc/openhab2
ls -l /etc/openhab2

echo "add user to openhab group"
usermod -a -G openhab $(whoami)
usermod -a -G dialout $(whoami)

# -------- Add link to serial port for MQTT interface program to use

echo "Add link to serial port for MQTT interface program to use"
ln -s /dev/ttyS1 /dev/ttyMQTT0

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

sed -i '/url/amqtt:localBroker.url=tcp://localhost:1883' /etc/openhab2/services/mqtt.cfg
sed -i '/clientID/amqtt:localBroker.clientId=openHab' /etc/openhab2/services/mqtt.cfg
sed -i '/qos/amqtt:localBroker.qos=1' /etc/openhab2/services/mqtt.cfg
echo "configured /etc/openhab2/services/mqtt.cfg"

# -------- Install the Python libraries we need

echo "Install the Python libraries we need"
apt-get  -y --allow-unauthenticated install python-serial python-daemon python-setuptools
wget http://engimusing.github.io/install/paho.mqtt.python-master.zip
unzip paho.mqtt.python-master.zip
rm paho.mqtt.python-master.zip
cd paho.mqtt.python-master
python setup.py install
cd ..
rm -rf rmdir paho.mqtt.python-master/

# -------- Install the serial2mqtt program as a daemon
echo "Install the serial2mqtt program as a daemon"

wget http://engimusing.github.io/install/serial2mqtt.py
chmod a+x serial2mqtt.py
mkdir -p /var/log/serial2mqtt


SRC_BIN_FILE="serial2mqtt.py"
BIN_PATH="/usr/bin"
BIN_NAME="serial2mqtt"
BIN_FILE="$BIN_PATH/$BIN_NAME"
SYSTEMD_PATH="/etc/systemd/system"
SERVICE_FILE="$SYSTEMD_PATH/$BIN_NAME.service"
SERVICE_NAME="$BIN_NAME.service"

echo "Install serial2mqtt.py to $BIN_FILE"
if ! [ -x "$SRC_BIN_FILE" ]; then
    echo "Unable to install the binary.Either binary does not have execute permissions or does not exists" >&2
    exit
fi	
errorMsg=$(install $SRC_BIN_FILE $BIN_FILE 2>&1)
if [ $? != 0 ]; then
    echo "Unable to install binary.The error msg is $errorMsg"
    exit
fi

execScript="$BIN_FILE -f"
rm -f serial2mqtt*

echo "Create and install service file"
fileContent="[Unit]\nDescription=Interface between the Mosquitto MQTT broker and a USB serial interface\n\n[Service]\nExecStart=$execScript\n\n[Install]\nWantedBy=multi-user.target"

msg=$(echo -e $fileContent > $SERVICE_FILE)
if [ $? != 0 ]; then
    echo "Unable to create service file.The error is $msg"
    exit
fi

isenabledCmd="systemctl is-enabled $SERVICE_NAME"
enableCmd="systemctl enable $SERVICE_NAME"
daemonReload="systemctl daemon-reload"

echo "systemctl daemon-reload"
msg=$($isenabledCmd 2>&1)
if [ $? == 0 ]; then
    $daemonReload
elif [ $msg == "disabled" ]; then
    errorMsg=$($enableCmd 2>&1)
    if [ $? != 0 ]; then
	echo "Unable to enable the service.The error msg is $msg"
	exit
    fi
fi

echo "Start the serial2mqtt service"
systemctl stop $SERVICE_NAME
errorMsg=$(systemctl start $SERVICE_NAME 2>&1)
if [ $? != 0 ]; then
    echo "$SRC_BIN_FILE has been installed successfully but failed to start.Run \"systemctl status $SERVICE_NAME\" for more information"
    exit
fi
echo "$SRC_BIN_FILE has been installed and started successfully"

# -------- 

echo "Script completed successfully"
