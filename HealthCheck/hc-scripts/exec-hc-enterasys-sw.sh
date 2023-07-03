#!/bin/bash

# Date: 20130507
# Version: 1.0
# By: robertson.diasjr@gmail.com

####################
# GLOBAL VARIABLES #
####################

CONFIGDIR="../hc-configs/"
OUTPUTDIR="../hc-output"
HCSUMMARY="$OUTPUTDIR/HC-summary.txt"
FILE_TEMPLATE="../hc-templates/template.txt"
FILE_IFACES="ifaces.ifaces"
FILE_IFACE_UP="iface-up.ifaces"
FILE_IFACE_DOWN="iface-down.ifaces"
FILE_IFACE_PARAMETERS="iface-parameters.ifaces"
FILE_LINES="lines.lines"
FILE_LINESONLY="linesonly.lines"

# converting file format to unix
dos2unix -q $CONFIGDIR/*

# Reading config files for execute HC ...
ls -1 $CONFIGDIR | while read EVALUATEDEVICE; do
	CONFIG=$CONFIGDIR/$EVALUATEDEVICE
	OUTPUT="$OUTPUTDIR/HC-$EVALUATEDEVICE"
	echo "Health-checking device: $EVALUATEDEVICE ..."
	echo "Output Result: $OUTPUT"
	
############################
# FUNCTIONS TO PERFORM HC  #
############################

####################################
# ENTERASYS FIREWALLS FUNCTIONS        #
####################################

function VERSION ( ) {
	echo "#############################################"
	echo "`head -n 3 $FILE_TEMPLATE`"
        echo
        USER="`id -u`"
        echo "*Performed by:* $USER"
        echo "*Performed at:* `date +%c`"
}

function SECTION_GLOBAL ( ) {
#echo "*********************************************"
#echo "Evaluating Global Sections ..."
#echo "*********************************************"
#echo

sed -n -e '/SECTION_GLOBAL/,/END_SECTION_GLOBAL/p' $FILE_TEMPLATE | grep -v "SECTION_GLOBAL" | grep -v "^$" | while read LINE;
do
        # Print text Evaluating ...
        if [[ "$LINE" == *Evaluating* ]]
        then
                echo
                echo "*$LINE ...*"
        fi

        # Evaluate commands inside config file
        if [[ "$LINE" != *Evaluating* ]]
        then
                MATCH=`grep -E "$LINE" $CONFIG`
                if [ -n "$MATCH" ]
                then
                        echo "Pass: $MATCH"
                else
                        echo "Failed: Missing configuration"
                fi
        fi
done
}

function SECTION_SNMP ( ) {
# General Policy Requirements
# 1) minimum lenght: 14
# 2) minimum digit: 1
# 3) minimum alphabethical letter: 1
# 4) minimum upper case: 1
# 5) minimum lower case: 1
# 6) minimum non-alphabethical letter: 1

sed -n -e '/SECTION_SNMP/,/END_SECTION_SNMP/p' $FILE_TEMPLATE | grep -v "SECTION_SNMP" | grep -v "^$" | while read LINE;
do
        # Print text Evaluating ...
        if [[ "$LINE" == *Evaluating* ]]
        then
               echo
               echo "*$LINE ...*"
        fi

        if [[ "$LINE" != *Evaluating* ]]
        then
		#set snmp user PAALB2004WriteNetMgmt

		MATCH_SNMP_DEFAULT="`grep -w "$LINE" $CONFIG`"

		if [ -z "$MATCH_SNMP_DEFAULT" ] 
		then
			echo "Failed: Missing SNMP configuration"
		else
			grep -w "$LINE" $CONFIG | awk '{print $4}' | while read COMMUNITY;
			do
				echo "Reading community: $COMMUNITY"
				STRING="`echo $COMMUNITY | grep -P '(?=.*[[:lower:]])(?=.*[[:upper:]])(?=.*[[:digit:]])(?=.*[[:punct:]]).{14,}'`"
				if [ -n "$STRING" ]; 
				then
					echo "Pass: Minimum lenght and sintax"
				else
					echo "Failed: Policy requirements"
				fi
			done
		fi
		
	fi
done
}


###################################
# END OF FUNCTIONS TO PERFORM HC  #
###################################

# Call functions to perform hc

cat $FILE_TEMPLATE | while read SECTIONS;
do
        if [[ "$SECTIONS" == *Standard* ]]
        then
                VERSION > $OUTPUT
                echo >> $OUTPUT
        fi

        if [[ "$SECTIONS" == "SECTION_GLOBAL" ]]
        then
                SECTION_GLOBAL >> $OUTPUT
                echo >> $OUTPUT
        fi

        if [[ "$SECTIONS" == "SECTION_INTERFACE" ]]
        then
                SECTION_INTERFACE >> $OUTPUT
                echo >> $OUTPUT
        fi

        if [[ "$SECTIONS" == "SECTION_ACCESS_GROUP" ]]
        then
                SECTION_ACCESS_GROUP >> $OUTPUT
                echo >> $OUTPUT
        fi

        if [[ "$SECTIONS" == "SECTION_SPOOF" ]]
        then
                SECTION_SPOOF >> $OUTPUT
                echo >> $OUTPUT
        fi

        if [[ "$SECTIONS" == "SECTION_SNMP" ]]
        then
                SECTION_SNMP >> $OUTPUT
                echo >> $OUTPUT
        fi
done


# End of call functions
# End of reading config files to execute HC ...
done

###########################################
# FUNCTIONS TO EXECUTE AFTER HC COMPLETED #
###########################################

function SUMMARY ( ) {
cat /dev/null > $HCSUMMARY
ls -1 $CONFIGDIR | while read EVALUATEDEVICE; 
do
        OUTPUT="$OUTPUTDIR/HC-$EVALUATEDEVICE"

        FAIL=`grep -cw Failed $OUTPUT`
        PASS=`grep -cw Pass $OUTPUT`
	TOTAL=`echo $FAIL + $PASS | bc`

	PERCENT_FAIL="`echo "scale=3;($FAIL/$TOTAL)*100" | bc -l`"
	PERCENT_PASS="`echo "scale=3;($PASS/$TOTAL)*100" | bc -l`"

        echo "---------------------------------------------" >> $HCSUMMARY
        echo "*Device:* $EVALUATEDEVICE. *Evaluated:* $TOTAL. *Failed:* $FAIL ($PERCENT_FAIL%). *Passed:* $PASS ($PERCENT_PASS%)" >> $HCSUMMARY
        echo >> $HCSUMMARY

	sed -i "9i *Evaluated:* $TOTAL - *Failed:* $FAIL ($PERCENT_FAIL%) - *Passed:* $PASS ($PERCENT_PASS%)" $OUTPUT
	sed -i "10i #############################################" $OUTPUT
done
}

function TEXT2HTML ( ) {
# translate .txt
find $OUTPUTDIR -name "*.txt" -print | sed 's/\.txt//g' | while read HC; 
do 
	# converting from txt to html "package: perl-HTML-FromText.noarch"
	text2html --metachars=0 --lines --bold $HC.txt > $HC.html; 
	# removing txt's file
	rm $HC.txt
done

# translate .cfg
find $OUTPUTDIR -name "*.cfg" -print | sed 's/\.cfg//g' | while read HC; 
do
        # converting from txt to html "package: perl-HTML-FromText.noarch"
        text2html --metachars=0 --lines --bold $HC.cfg > $HC.html;
        # removing txt's file
        rm $HC.cfg
done

# translate .conf
find $OUTPUTDIR -name "*.conf" -print | sed 's/\.conf//g' | while read HC; 
do
        # converting from txt to html "package: perl-HTML-FromText.noarch"
        text2html --metachars=0 --lines --bold $HC.conf > $HC.html;
        # removing txt's file
        rm $HC.conf
done
}

# CALL FUNCTIONS TO BE EXECUTED AFTER HC COMPLETED
SUMMARY;
TEXT2HTML;
