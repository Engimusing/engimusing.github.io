#!/usr/bin/env bash


#  Copyright (c) 2015 Engimusing LLC.  All right reserved.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#  See the GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA


TRUE=0
FALSE=1

SRC_BIN_FILE="serial2mqtt.py"

BIN_PATH="/usr/bin"
BIN_NAME="serial2mqtt"

INIT_PATH="/etc/init.d"
SYSTEMD_PATH="/etc/systemd/system"

BIN_FILE="$BIN_PATH/$BIN_NAME"
INIT_RC_FILE="$INIT_PATH/$BIN_NAME"
SERVICE_FILE="$SYSTEMD_PATH/$BIN_NAME.service"
SERVICE_NAME="$BIN_NAME.service"
INIT_RC_NAME="$BIN_NAME"

checkUser()
{
	if (( $EUID != 0 )); then
		return $FALSE
	fi
	return $TRUE
}
getInitSystemType()
{
	if [ -f "/proc/1/comm" ]; then
		initSysType=`cat /proc/1/comm`
		echo "$initSysType"
	else
		echo ""
	fi
}
installBinary()
{
	srcFile=$1
	destFile=$2

	if ! [ -x "$srcFile" ]; then
		echo "Unable to install the binary.Either binary does not have execute permissions or does not exists" >&2
		 return $FALSE
	fi	
	errorMsg=$(install $srcFile $destFile 2>&1)
	if [ $? != 0 ]; then
		echo "Unable to install binary.The error msg is $errorMsg"
		return $FALSE
	fi

	return $TRUE
}
enableSysdService()
{
	serviceName=$1
	isenabledCmd="systemctl is-enabled $serviceName"
	enableCmd="systemctl enable $serviceName"
	daemonReload="systemctl daemon-reload"

	msg=$($isenabledCmd 2>&1)
	if [ $? == 0 ]; then
		$daemonReload
		return $TRUE
	fi
	if [ $msg == "disabled" ]; then
		errorMsg=$($enableCmd 2>&1)
		if [ $? == 0 ]; then
			return $TRUE
		fi
	fi
	echo "Unable to enable the service.The error msg is $msg"

	return $FALSE
}
createSysdService()
{
	serviceName=$1
	execScript="$2 -f"

	fileContent="[Unit]\nDescription=Interface between the Mosquitto MQTT broker and a USB serial interface\n\n[Service]\nExecStart=$execScript\n\n[Install]\nWantedBy=multi-user.target"
	msg=$(echo -e $fileContent > $serviceName)
	if [ $? != 0 ]; then
		echo "Unable to create service file.The error is $msg"
		return $FALSE
	fi

	return $TRUE
}
startSysdService()
{
	serviceName=$1

	systemctl stop $serviceName
	errorMsg=$(systemctl start $serviceName 2>&1)
	if [ $? == 0 ]; then
		return $TRUE
	fi
	return $FALSE
}
installSysdService()
{
	installBinary $SRC_BIN_FILE $BIN_FILE
	if [ $? == $FALSE ]; then
		return $FALSE
	fi
	createSysdService $SERVICE_FILE $BIN_FILE
	if [ $? == $FALSE ]; then
		return $FALSE
	fi
	enableSysdService $SERVICE_NAME
	if [ $? == $FALSE ]; then
		return $FALSE
	fi
	startSysdService $SERVICE_NAME
	if [ $? == $TRUE ]; then
		echo "$SRC_BIN_FILE has been installed and started successfully"
	else
		echo "$SRC_BIN_FILE has been installed successfully but failed to start.Run \"systemctl status $SERVICE_NAME\" for more information"
	fi
}
stopSysVService()
{
	initScript=$1

	status=$($initScript stop)

}
startSysVService()
{
	initScript=$1

	$initScript start

}
createSysVService()
{
	initScript=$1
	binaryName=$2
	processName=$3

cat > "$initScript" <<- EOM
#!/bin/sh
### BEGIN INIT INFO
# Provides:          serial2mqtt
# Required-Start:    
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      
# Short-Description: Startup script
### END INIT INFO

set -e

. /lib/lsb/init-functions

DAEMON=$binaryName
PROCNAME=$processName
OPTIONS=""

case "\$1" in
   start)
     \\echo "Starting \$PROCNAME....."
     start-stop-daemon --start --quiet --oknodo --name "\$PROCNAME" --exec "\$DAEMON"
     ;;
   stop)
     \\echo "Stopping \$PROCNAME....."
     start-stop-daemon --stop --quiet --oknodo --retry 2 --name "\$PROCNAME"
   ;;
   restart)
     \$0 stop
     sleep 1
     \$0 start
     ;;
   status)
     status_of_proc "\$DAEMON" "\$PROCNAME"
     ;;
   *)
     echo "Usage: /etc/init.d/$initScript {start|stop|restart|status}"
     exit 1
esac
EOM
	chmod 755 "$initdPath/$initScript"
}
createRedhatSysVService()
{
	initScript=$1
	binaryName=$2
	initdPath="/etc/init.d"

cat > "$initdPath/$initScript" <<- EOM
#!/bin/bash
### BEGIN INIT INFO
# Provides:          serial2mqtt
# Required-Start:    
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      
# Short-Description: Startup script
### END INIT INFO


. /etc/rc.d/init.d/functions

DAEMON=$binaryName
RETVAL=0

check() {
     # Check that we're a privileged user
     [ \`id -u\` = 0 ] || exit 4

     # Check if serialtomqtt is executable
     test -x $binaryName || exit 5
}

start() {

     check

     # Check if it is already running
     if [ ! -f /var/lock/subsys/serialtomqtt ]; then
        echo -n $"Starting serialtomqtt daemon: "       
        daemon $binaryName
        RETVAL=$?
        [ $RETVAL -eq 0 ] && touch /var/lock/subsys/serialtomqtt
        echo
     fi
     return $RETVAL
}

stop() {

     check

     echo -n $"Stopping serialtomqtt daemon: "
     killproc $binaryName
     RETVAL=$?
     [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/serialtomqtt
     echo
     return $RETVAL
}
restart() {
     stop
     start
}
case "\$1" in
start)
        start
        ;;
stop)
        stop
        ;;
restart)
        stop
        sleep 1
        start
        ;;
status)
        status serialtomqtt 
        RETVAL=$?
        ;;
*)
        echo "Usage: /etc/init.d/$initScript {start|stop|restart|status}"
        exit 1
esac
exit $RETVAL
EOM
	chmod 755 "$initdPath/$initScript"
}
enableSysVService()
{
	if [ -x "/usr/sbin/update-rc.d" ]; then
		createSysVService $INIT_RC_FILE $BIN_FILE $BIN_NAME
		cmd="update-rc.d $INIT_RC_NAME defaults"
	else
		createRedhatSysVService $initScript $DEST_BIN_FILE
		cmd="chkconfig --add $scriptName"
	fi
	errorMsg=$($cmd 2>&1)
	if [ $? == 0 ]; then
		return $TRUE	
	fi
	echo "Failed to enable sysv service.The error msg is $errorMsg"
	return $FALSE
}
installSysVService()
{
	installBinary $SRC_BIN_FILE $BIN_FILE
	if [ $? == $FALSE ]; then
		return $FALSE
	fi
	enableSysVService 
	if [ $? == $FALSE ]; then
		return $FALSE
	fi
	stopSysVService $INIT_RC_FILE
	startSysVService $INIT_RC_FILE
	echo "$SRC_BIN_FILE has been installed and started successfully"
}
checkUser
if [ $? != $TRUE ]; then
	echo "Script need root user to execute" >&2
	exit -1
fi

initSysType=$(getInitSystemType)
#initSysType="init"

if [ $initSysType == "systemd" ]; then
	installSysdService
elif [ $initSysType == "init" ]; then
	installSysVService
else
	echo "Unsupported init system" >&2
fi
