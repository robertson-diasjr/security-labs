#!/bin/bash

# Date: 20140701
# Version: 1.1
# By: robertson.diasjr@gmail.com

EXECDIR="/home/sasauto/hc-tool/hc-scripts"

function ERROR ( ){
echo "Usage examples ..."
echo "1) $0 cisco firewall"
echo "2) $0 vyatta 5400"
echo "3) $0 cisco switch"
echo "4) $0 juniper junos" 
}

if [ $# == 2 ] || [ $# == 3 ]
then
	cd $EXECDIR

	if [ $# == 2 ]
	then
		if [ $1 == "cisco" ] && [ $2 == "firewall" ]
		then
			echo "HC of Cisco Firewall"
			./exec-hc-cisco-fw.sh

		elif [ $1 == "cisco" ] && [ $2 == "switch" ]
		then
			 echo "HC of Cisco SW IOS"       
                        ./exec-hc-cisco-sw.sh

		elif [ $1 == "vyatta" ] && [ $2 == "5400" ]
		then
			echo "HC of Vyatta Router 5400"
			./exec-hc-vyatta-5400.sh

		
		elif [ $1 == "juniper" ] && [ $2 == "junos" ]
		then
			echo "HC of Juniper Junos"
			./exec-hc-juniper-junos.sh

		else
			ERROR;
		fi
	fi

	if [ $# == 3 ]
	then
		if [ $1 == "cisco" ] && [ $2 == "switch" ] && [ $3 == "nexus" ]
		then
			echo "HC of Cisco SW Nexus"	
			./exec-hc-cisco-nexus.sh
		else
			ERROR;
        	fi
	fi
else
	ERROR;
fi
