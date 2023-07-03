#!/bin/bash

# Date: 20180504
# Version: 1.0
# By: robertson.diasjr@gmail.com

####################
# GLOBAL VARIABLES #
####################

BASEDIR="/home/sasauto/hc-tool"
CONFIGDIR="$BASEDIR/hc-configs"
OUTPUTDIR="$BASEDIR/hc-output"
HCSUMMARY="$OUTPUTDIR/HC-summary.txt"
FILE_TEMPLATE="$BASEDIR/hc-templates/template.txt"

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
# CISCO_ROUTERS/SWITCHES FUNCTIONS #
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

sed -n -e '/SECTION_GLOBAL/,/END_SECTION_GLOBAL/p' $FILE_TEMPLATE | grep -v "SECTION_GLOBAL" | grep -v "^$" | while read LINE;
do
        # Print text Looking ...
        if [[ "$LINE" == *Looking* ]]
        then
                echo
                echo "*$LINE*"
        fi

        # Evaluate commands inside config file
        if [[ "$LINE" != *Looking* ]]
        then
                MATCH=`grep -E -w "$LINE" $CONFIG`
                if [ -n "$MATCH" ]
                then
                        echo "Pass: $MATCH"
                else
                        echo "Failed: $LINE not found"
                fi
        fi
done
}

function SECTION_MGMT ( ) {

sed -n -e '/SECTION_MGMT/,/END_SECTION_MGMT/p' $FILE_TEMPLATE | grep -v "SECTION_MGMT" | grep -v "^$" | while read LINE;
do
        # Print text Looking ...
        if [[ "$LINE" == *Looking* ]]
        then
                echo
                echo "*$LINE*"
        fi

        # Evaluate commands inside config file
        if [[ "$LINE" != *Looking* ]]
        then
                MATCH=`grep -E -w "$LINE" $CONFIG`
                if [ -n "$MATCH" ]
                then
                        echo "Failed: Found $MATCH"
                else
                        echo "Pass: $LINE not found"
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

        if [[ "$SECTIONS" == "SECTION_MGMT" ]]
        then
                SECTION_MGMT >> $OUTPUT
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
	/usr/local/bin/text2html --metachars=0 --lines --bold $HC.txt > $HC.html; 
	# removing txt's file
	rm $HC.txt
done
}

# CALL FUNCTIONS TO BE EXECUTED AFTER HC COMPLETED
SUMMARY;
TEXT2HTML;
