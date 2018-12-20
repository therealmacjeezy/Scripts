#!/bin/bash

#################################################
# Microsoft AutoUpdate Script
# Office 2016
# Joshua Harvey | November 2018
# Updated: December 2018
# josh[at]macjeezy.com
# GitHub - github.com/therealmacjeezy    
# JAMFnation - therealmacjeezy
#################################################

############ Script Parameters Info #############
## 4 - Word Version (16.16.xxxxxxxx)
## 5 - Excel Version (16.16.xxxxxxxx)
## 6 - PowerPoint Version (16.16.xxxxxxxx)
## 7 - Outlook Version (16.16.xxxxxxxx)
## 8 - OneNote Version (16.16.xxxxxxxx)
##
## If a Parameter is left blank, the script will
## output "Missing <APPNAME> Version" and move on
## to the next app. Each time this script is run,
## it will always check and install (if available)
## updates for Skype for Business, MAU and Remote
## Desktop since they are the same for both versions.
#################################################

## 12-20-18 - Resolved Issues
# Added a version check for msupdate at the beginning of the script. This resolves the issue where the script was throwing an error and exiting prior to updating the apps. The cause of the issue was msupdate not being on the latest version. msupdate updates override any updates that are avaiable for the other applications. 

# Function that gets called to look for any updates that are avaiable for the Microsoft Office applications
updateCheck() {
	versionCheck=$(/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -l | grep "No updates available")
	
	# Uses the above variable that checks for any avaiable updates and exits the script if no updates are found
	if [[ "$versionCheck" == "No updates available" ]]; then
			echo "All Microsoft Office applications are up to date. Exiting"
			exit 0
	else
			echo "Microsoft Office updates found.. starting updates.."
	fi
}

# Checks to see if Microsoft AutoUpdate is on the latest version and updates it if not, if already on the latest version it will continue on and use the above function to look for additonal updates. 
if [[ ! -z `/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -l | grep "MSau03"` ]]; then
	echo "Microsoft AutoUpdate requires an update before continuing. Starting Update."
	/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -i -a msau03
	echo "Microsoft AutoUpdate has been updated. Looking for additional updates.."
	updateCheck
else
	echo "Microsoft AutoUpdate is up to date. Checking for any additional available application updates.."
	updateCheck
fi

# Script Parameters to apply version control with updates
# Word
if [[ ! -z "$4" ]]; then
    /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -i -a mswd15 -v "$4"
else
    echo "Missing Word Version"
fi

# Excel
if [[ ! -z "$5" ]]; then
    /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -i -a xcel15 -v "$5"
else
    echo "Missing Excel Version"
fi

# PowerPoint
if [[ ! -z "$6" ]]; then
    /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -i -a ppt315 -v "$6"
else
    echo "Missing PowerPoint Version"
fi

# Outlook
if [[ ! -z "$7" ]]; then
    /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -i -a opim15 -v "$7"
else
    echo "Missing Outlook Version"
fi

# OneNote
if [[ ! -z "$8" ]]; then
    /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -i -a onmc15 -v "$8"
else
    echo "Missing OneNote Version"
fi

# Skype for Business and Remote Desktop
# Uses the same version for both 2019 and 2016 so adding them to the update each time
/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -i -a msfb16 msrd10

exit 0
