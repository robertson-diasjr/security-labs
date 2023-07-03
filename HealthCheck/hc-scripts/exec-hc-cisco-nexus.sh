#!/bin/bash

# Date: 20130606
# Version: 1.1
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
        # Print text Evaluating ...
        if [[ "$LINE" == *Evaluating* ]]
        then
                echo
                echo "*$LINE ...*"
        fi

        # Evaluate commands inside config file
        if [[ "$LINE" != *Evaluating* ]]
        then
                MATCH=`grep -E -w "$LINE" $CONFIG`
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
# 7) access to community: protected by ACL

sed -n -e '/SECTION_SNMP/,/END_SECTION_SNMP/p' $FILE_TEMPLATE | grep -v "SECTION_SNMP" | grep -v "^$" | while read LINE;
do
        # Print text Evaluating ...
        if [[ "$LINE" == *Evaluating* ]]
        then
               echo
               echo "*$LINE ...*"
        fi

        if [[ "$LINE" != *Evaluating ]]
        then
                grep -E "$LINE" $CONFIG | awk '{print $3}' | while read COMMUNITY; do

                echo "Reading community: $COMMUNITY"
                # Evaluating string policy requirements
		STRING="`echo $COMMUNITY | grep -P '(?=.*[[:lower:]])(?=.*[[:upper:]])(?=.*[[:digit:]])(?=.*[[:punct:]]).{14,}'`"

                if [ -n "$STRING" ]; then
                        echo "Pass: Policy requirements"
                fi

                if [ -z "$STRING" ]; then
                        echo "Failed: Policy requirements"
                fi
                done
        fi
done
}


function SECTION_VTY ( ) {
echo "*Evaluating VTY Sections ...*"

# Gathering vty config lines into device config
sed -n -e '/^line/,/!/p' $CONFIG > $FILE_LINES

# Gathering only vty lines from template
egrep "^line" $FILE_LINES > $FILE_LINESONLY

cat $FILE_LINESONLY | while read VTY; 
do
	# remove line numbers, like 0, 0 4, 5 15
       	echo $VTY | tr -d [:digit:] | while read LINEVTY;  
       	do
       		echo "Reading: $VTY"
		sed -n -e '/^'"$LINEVTY"'/,/line/p' $FILE_TEMPLATE | egrep "^ " | while read PATTERN; 
		do
			MATCH=`sed -n -e '/^'"$VTY"'/,/line/p' $CONFIG | egrep -w "$PATTERN"`
			if [ -z "$MATCH" ]; then
				echo "Failed: "$PATTERN""
			else
				echo "Pass: "$MATCH""
			fi
		done
	done
done

# cleanning temporary files
rm *.lines
}

function SECTION_INTERFACE ( ) {
echo "*Evaluating Interfaces Sections ...*"

# Gathering for all interfaces into device config
#sed -n -e '/^interface/,/^!/p' $CONFIG > $FILE_IFACES

# Gathering for all interfaces into device config: state UP with IP configured
#sed -n -e '/^interface/,/^!/p' $FILE_IFACES | awk -v RS='!\n' '/ip address /' | sed 's/^$/!/g' | awk -v RS='!\n' '!/shutdown/' > $FILE_IFACE_UP
sed -n -e '/^interface/,/^!/p' $CONFIG | sed 's/^$/!/g' | awk -v RS='!\n' '/ip address /' | sed 's/^$/!/g' | awk -v RS='!\n' '/no shutdown/' > $FILE_IFACE_UP

# Getting parameters from interface's template and check if it's exists into interfaces UP
sed -n -e '/SECTION_INTERFACE/,/END_SECTION_INTERFACE/p' $FILE_TEMPLATE | sed 's/\!//g' | grep -v "^$" | grep -v "SECTION_INTERFACE" | egrep -v '^interface|^$' > $FILE_IFACE_PARAMETERS

cat $FILE_IFACE_PARAMETERS | while read PATTERN;
do 
	echo "Reading: $PATTERN"; 
	IFACE_MISSING=`awk -v RS='' -v VALUE="${PATTERN}" '{ if ($0 !~ VALUE) print }' $FILE_IFACE_UP | awk '/^interface/'`;

	if [ -n "$IFACE_MISSING" ]; then
		echo "Failed: "$IFACE_MISSING""	
	else
		echo "Pass: "$PATTERN""
	fi
done

# cleanning temporary files
rm *.ifaces
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
    
        if [[ "$SECTIONS" == "SECTION_VTY" ]]
        then
                SECTION_VTY >> $OUTPUT
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
