#!/bin/bash

# Validating input
if [ -z "$1" ];
then
        echo "Input file missed."
        exit 0
fi

# Getting report date from file name
MONTH=`echo $1 | sed 's/.csv//g' | awk -F"_" '{print $1}'`
YEAR=`echo $1 | sed 's/.csv//g' | awk -F"_" '{print $2}'`

# Extracting and parsing trackable controls
grep -v "^," $1 | awk -F"," '{ if (NR>1 && $6 !="N/A" ) print '$YEAR'"-"'$MONTH'"-30"","$1","$2","$3","$4","$5","$6 }' > tracking.parsed

# Extracting and parsing non-trackable controls
grep -v "^," $1 | awk -F"," '{ if (NR>1 && $6 =="N/A" ) print '$YEAR'"-"'$MONTH'"-30"","$1","$2","$3","$4","$5","$6 }' > non_tracking.parsed

# Importing into DB
mysqlimport -u sec-user -pyour_secret_password --local --fields-terminated-by=',' secure_posture tracking.parsed
mysqlimport -u sec-user -pyour_secret_password --local --fields-terminated-by=',' secure_posture non_tracking.parsed

# Cleanup
rm *.parsed
