# Date: 20130506
# Version: 1.1
# By: robertson.diasjr@gmail.com

#!/bin/bash

DEVICE_LIST="/home/sasauto/hc-tool/getconf/device-list"
DEVICE_CMDS="/home/sasauto/hc-tool/getconf/device-commands"
OUTPUT="/home/sasauto/hc-tool/hc-configs"

cat $DEVICE_LIST | sed -e '/^#/d' -e '/^$/d'| while read DEVICE; do
		HOSTNAME=`echo $DEVICE | awk -F";" '{print $1}'`;
		HOST=`echo $DEVICE | awk -F";" '{print $2}'`;
		METHOD=`echo $DEVICE | awk -F";" '{print $3}'`;
		USER=`echo $DEVICE | awk -F";" '{print $4}'`;
		USER_PASSWORD=`echo $DEVICE | awk -F";" '{print $5}'`;
		ENABLE=`echo $DEVICE | awk -F";" '{print $6}'`;
		EN_PASSWORD=`echo $DEVICE | awk -F";" '{print $7}'`;

	if [ "$ENABLE" == "enable" ]; then
		/usr/bin/expect /home/sasauto/hc-tool/getconf/getcmd.exp -h $HOST -u $USER -p $USER_PASSWORD -e $EN_PASSWORD -m $METHOD -f $DEVICE_CMDS | tee $OUTPUT/$HOSTNAME.txt
	fi

	if [ "$ENABLE" != "enable" ]; then
		/usr/bin/expect /home/sasauto/hc-tool/getconf/getcmd.exp -h $HOST -u $USER -p $USER_PASSWORD -m $METHOD -f $DEVICE_CMDS | tee $OUTPUT/$HOSTNAME.txt
	fi
done
exit 0
