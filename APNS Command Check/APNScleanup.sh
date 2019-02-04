#!/bin/bash

#################################################
# APNS Command Check
# Joshua Harvey | February 2019
# josh[at]macjeezy.com
# GitHub - github.com/therealmacjeezy    
# JAMFnation - therealmacjeezy
#################################################

# Database Password
dbPass='<database_password>'
# This array stores the names of your MySQL databases, if you only have one database for your setup, comment out the array on line 15 and uncomment the array on line 18
    # Array for Multiple Databases
    dbNames=( "<db1>" "<db2>" "<db3>" )

    # Array for a Single Database
    #dbNames=( "<db1>" )
# Path for the script log
# Path for the script log
logPath="/path/to/mdmcleanup.log"

# Verify log exists and create if not
if [[ ! -f "$logPath" ]]; then
    echo "No log found.. Creating log at $logPath"
fi

# Create log for start time and date
echo "Starting APNS Check on `date`" >> $logPath
echo "---" >> $logPath

# Function to clear the failed MDM commands for APNS
clearCommand() {
    # Variable to capture the number of failed APNS commands in the database. If you are running the database on the same computer as this script, you can remove the -h option below
    getNumber=$(mysql -u root -p$dbPass -h <database_location> -Bse "use $dbName; select count(*) from mobile_device_management_commands where apns_result_status =\"Error\";")

    echo "[$dbName]: $getNumber found failed APNS Commands. Clearing now.." >> $logPath

    # This line will clear the failed APNS commands found. If you are running the database on the same computer as this script, you can remove the -h option below
    mysql -u root -p$dbPass -h <database_location> -Bse "use $dbName; delete from mobile_device_management_commands where apns_result_status =\"Error\";"

    echo "[$dbName]: Cleared $getNumber failed APNS Commands." >> $logPath
}

# For loop to go through the database names stored in the dbNames array. It will check for any failed APNS commands and clear them if found
for i in "${dbNames[@]}"; do
    dbName="$i"
    # If statement to check for any failed APNS commands. If you are running the database on the same computer as this script, you can remove the -h option below.
    if [[ `mysql -u root -p$dbPass -h <database_location> -Bse "use $dbName; select count(*) from mobile_device_management_commands where apns_result_status =\"Error\";"` == "0" ]]; then
        echo "[$dbName]: No Failed APNS Commands found." >> $logPath
    else
        # Calls the function to clear the failed APNS commands
        clearCommand
    fi
done

echo "Goodbye" >> "$logPath"
echo "---" >> "$logPath"

exit 0
