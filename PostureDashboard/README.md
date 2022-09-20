# Building and Tracking the Security Posture through Your Own Dashboard

This artifact aims to create clarity on methods to track the company secure posture across common security controls embracing data protection upon On-Premises, Hybrid and/or Cloud Environments.

CyberSecurity is an infinite game, which lead us to view this work as a continuous effort and not a source of truth.

So, going through this artifact you will realize that even on small environments with restricted resources, it´s possible to envisioning the whole CyberSecurity landscape from a broad standpoint and then, plan improvements on those most impacted areas.

![InformationSecurityControl](https://github.com/robertson-diasjr/security-labs/blob/main/PostureDashboard/6.jpg)

## Environment

To sum up, we´re going to build the whole data processing environment on top of Linux/Unix and using open-source softwares and packages.

That being said, I'm considering:

1. You already have a system running Linux and/or Unix or know how to spin up one.
2. MySQL (MariaDB) and GrafanaMySQL successfully installed or know how to setup on top of above system.

## Setting up the database

**First and foremost - change the DB password within file "load-sql-schema.sql" according your requirements and update it on script "load-score.sh". Recommend you to enhance the credentials protection using the MySQL best-practices**

1. Create the DB schema (DB, tables, credentials, etc): $ mysql -u root -p < load-sql-schema.sql

## Setting up the Grafana
1. Access the Grafana portal and add the Mysql DB using the credentials previously updated by You ;-)

## Importing secure score into DB
1. Grafana will generate data stored into MySQL and MySQL will store the data You gathered during the secure posture assessment.

2. Open the "Security-Assessment-Controls.xlsx" spreadsheet and go through line by line flagging the controls. 
   - Acceptable values: 0, 25, 50, 75, 100 or N/A.

3. Save the file as "CSV" and **rename** it as **"<month_year>.csv**. I.e.: If you´re assessing in ***2022, September***, then the CSV file will be renamed to: **09_2022.csv**

4. Upload the **csv** into the Linux/Unix system into the same directory where the **"load-score.sh" script** resides.

5. Run the script to parse the data and load into the DB: $ source load-score.sh 09_2022.csv

Done. At this stage you´re ready to create the Grafana dashboards, since the data were successfully loaded into DB.

## Example of Grafana Dashboards

**Keep in mind** the data is stored on DB, so you´re free to create any kind of graph just manipulating the SQL queries as needed. 
Below you can find some dashboards and the respective SQL query.


SELECT time, Security_Domain 'Security Domain', AVG(Security_Control_Rate) '%' FROM tracking WHERE Customer = 'Client A' AND Security_Domain = 'Application' GROUP BY time;
![Latest_Score](https://github.com/robertson-diasjr/security-labs/blob/main/PostureDashboard/1.jpg)

SELECT time, Security_Domain 'Security Domain', AVG(Security_Control_Rate) '% Score' FROM tracking WHERE Customer = 'Client A' AND Security_Domain = 'Devices' GROUP BY time;
![Progress](https://github.com/robertson-diasjr/security-labs/blob/main/PostureDashboard/2.jpg)

SELECT time, Security_Domain 'Security Domain', COUNT(Security_Control_Rate) '' FROM non_tracking WHERE Customer = 'Client A' AND Security_Domain = 'Application' GROUP BY time;
![Progress](https://github.com/robertson-diasjr/security-labs/blob/main/PostureDashboard/3.jpg)

SELECT time, Security_Control_Name 'Focus On' FROM tracking WHERE Customer = 'Client A' AND Security_Control_Rate = '0' GROUP BY Security_Control_Name ORDER by 'Security_Control_Name' ASC;
![ToFocus](https://github.com/robertson-diasjr/security-labs/blob/main/PostureDashboard/4.jpg)

SELECT time, Security_Domain 'Security Domain', AVG(Security_Control_Rate) '% Score' FROM tracking WHERE Customer = 'Client A' AND Security_Domain = 'Application' GROUP BY time;
![OverallPosture](https://github.com/robertson-diasjr/security-labs/blob/main/PostureDashboard/5.jpg)

## Next stage and ideas
You´re welcome, encouraged and invited to contribute. So drop me an e-mail and lets work together ;-)

## Final considerations
As I mentioned early, by far it´s not the purpose be a source of trouth, model, wharever. Instead, it´s a trigger to encourage you to start dealing with this fascinating CyberSecurity world ;-) Enjoy.
