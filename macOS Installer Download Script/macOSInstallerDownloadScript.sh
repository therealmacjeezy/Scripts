#!/bin/bash

#################################################
# macOS 10.13 Installer Download
# Policy - Self Service
# Joshua Harvey | July 2018
# joshua.harvey[at]nasa.gov
#################################################

########################################## NOTES ##########################################
####### Parameters (Required) #############################################################
# N/A
####### Jamf Pro Policies Used (Triggers) #################################################
# updateDownloader - Copies the python script used to download the installer to the computer
####### Supported macOS Versions ##########################################################
# macOS 10.12
####### Supported Disk Types ##############################################################
# HFS+ (Journaled)
####### Script Overview ###################################################################
# This script will download the macOS 10.13 High Sierra installer and save it to the 
# /Library/VA directory as a sparseimage. This will allow the user to download the installer
# before they take their computer in to start the update, which will save time. The macOS 
# Update policy will automatically check for this installer and only download it if needed.
###########################################################################################

# Starts the python script that will download the macOS installer. This is only used to grab the list of available macOS updates and their option numbers. This gets redirected to a file in the /tmp directory for use later in the script
nohup sudo /Users/Shared/installinstallmacos.py > /tmp/update.txt &
echo "Starting script to get item number" > /Users/Shared/debug.log

# This varaible finds the PID of the python script so it can be stopped once the list has been exported
getPID=$(ps aux | grep -m2 installinstallmacos | awk '{print $2}' | tail -1)
echo "$getPID" >> /Users/Shared/debug.log

sleep 4

# Kills the python script 
sudo kill -9 "$getPID"

# This varaible searches for the macOS installer needed and filters the output to only have the number of the option for use later in the script
getNumber=$(cat /tmp/update.txt | grep -m4 "macOS High Sierra" | awk '{print $1}' | tail -1 | head -2)

echo "$getNumber"

# Download macOS 10.13
cat > /Users/Shared/startDownload.command <<EOF
#!/bin/bash

#################################################
# Download macOS 10.13 High Sierra Installer
# Joshua Harvey | June 2018
# joshua.harvey[at]nasa.gov
#################################################

# Uses the yes binary to repeat a number and pipes the python script that will download the installer. The download script requires the user to enter the number of the item they want to download. This number is filled in with a variable that is set above which searches for the correct macOS version.

yes $getNumber | sudo /Users/Shared/installinstallmacos.py --workdir /Users/Shared

exit 0
EOF

sudo chmod a+x /Users/Shared/startDownload.command
nohup /Users/Shared/startDownload.command &

# Variables to store the current logged in user and their UID
currUser=$(ls -l /dev/console | awk '{print $3}')
currUserUID=$(id -u "$currUser")

/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<APPLESCRIPT
display dialog "The macOS 10.13 High Sierra download has started. Please do not close Self Service while it is downloading. 

Once it is finished downloading, a prompt will appear letting you know it has finished and that Self Service can be closed" with title "Starting Download" buttons {"Ok"} default button 1
APPLESCRIPT

checkSize=$(du -sh /Users/Shared/content/downloads/ | awk '{print $1}')

until [[ "$checkSize" == "5.3G" ]]; do
	checkSize=$(du -sh /Users/Shared/content/downloads/ | awk '{print $1}')
	sleep 5
	checkSize=$(du -sh /Users/Shared/content/downloads/ | awk '{print $1}')
done

imageName=$(ls /Users/Shared | grep sparseimage)

until [[ ! -z "$imageName" ]]; do
	sleep 10
	imageName=$(ls /Users/Shared | grep sparseimage)
done

/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<APPLESCRIPT
display dialog "The macOS 10.13 High Sierra has been downloaded. You can close Self Service now and schedule your appointment with Local IT to start the update to macOS 10.13 if you have not already done so." with title "Download Complete" buttons {"Ok"} default button 1
APPLESCRIPT

exit 0
