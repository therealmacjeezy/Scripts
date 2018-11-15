#!/bin/bash

#################################################
# Pre Update Computer Health Check
# Policy - Self Service 
# Joshua Harvey | July 2018
# joshua.harvey[at]nasa.gov
#################################################

########################################## NOTES ##########################################
####### Parameters (Required) #############################################################
# N/A
####### Jamf Pro Policies Used (Triggers) #################################################
# healthCheck_changePass - Changes the password for JAMFMANAGEMENTACCOUNT to JAMFMANAGEMENTACCOUNTPASSWORD
# healthCheck_addFV - Enables JAMFMANAGEMENTACCOUNT for FileVault
# healthCheck_randomPass - Changes the password for JAMFMANAGEMENTACCOUNT back to a randomized one (8 char)
####### Supported macOS Versions ##########################################################
# macOS 10.13.X
####### Supported Disk Types ##############################################################
# HFS+ (Journaled), APFS
####### Script Overview ###################################################################
# This script will run a health check to make sure the computer is ready to be updated to
# macOS 10.13.X. This script will check the following items:
####### Script Steps  #####################################################################
# 1) 
###########################################################################################

# System Information Variables
currDate=$(date)
computerName=$(/usr/sbin/scutil --get ComputerName)
serialNumber=$(system_profiler SPHardwareDataType | grep 'Serial Number (system)' | awk '{print $NF}')
osVersion=$(/usr/bin/sw_vers -productVersion)

	if [[ "$osVersion" =~ "10.12" ]]; then
		osName="Sierra"
	elif [[ "$osVersion" =~ "10.13" ]]; then
		osName="High Sierra"
	fi

# Hard Drive Information Variables
diskCheck=$(/usr/sbin/diskutil list | grep "Fusion Drive")

	# Set variable based off the disk type to be used later on in the script
	if [[ -z "$diskCheck" ]]; then
		echo "No Fusion Drive Found"
		driveType="Solid State Drive / Spinning Hard Drive"
		if [[ "$osVersion" =~ "10.12" ]]; then
			echo "Solid State Found"
			diskType="hfs+"
		else
			diskType="apfs"
		fi
	else
		echo "Fusion Drive Found"
		driveType="Fusion Drive"
		diskType="hfs+"
	fi

# Installs the package that contains the icons for the health check messages
sudo /usr/local/bin/jamf policy -trigger updateIcons

# User Information Variables
currUser=$(ls -l /dev/console | awk '{print $3}')
currUserUID=$(id -u "$currUser")

managementAccount_nonAPFS() {
# Management Account Information Variables
	/usr/bin/dscl /Local/Default authonly JAMFMANAGEMENTACCOUNT JAMFMANAGEMENTACCOUNTPASSWORD
	if [[ $? -eq 0 ]]; then
		resetResult="Pass (Password: JAMFMANAGEMENTACCOUNTPASSWORD)"
	else
		sudo /usr/local/bin/jamf policy -trigger healthCheck_changePass
		/usr/bin/dscl /Local/Default authonly JAMFMANAGEMENTACCOUNT JAMFMANAGEMENTACCOUNTPASSWORD
		if [[ $? -eq 0 ]]; then
			resetResult="Pass (Password: JAMFMANAGEMENTACCOUNTPASSWORD)"
		else
			resetResult="Fail - Unable to Change Password"
			failure="yes"
			failedItem+=("Cannot Change Password for Management Account")
		fi
	fi

	sudo /usr/local/bin/jamf policy -trigger healthCheck_addFV
	sudo /usr/bin/fdesetup list | grep "JAMFMANAGEMENTACCOUNT"
	if [[ $? -eq 0 ]]; then
		addResult="Yes"
	else
		addResult="Failed - Unable to add to FileVault"
		failure="yes"
		failedItem+=("Cannot Enable Management Account for FileVault")
	fi
}	

managementAccount_APFS() {
# Management Account Information Variables
resetResult="N/A - AFPS Volume Found"
addResult="N/A - AFPS Volume Found"
removalResult="N/A - AFPS Volume Found"
}

startCheck() {
if [[ "$diskType" == "hfs+" ]]; then
	managementAccount_nonAPFS
elif [[ "$diskType" == "apfs" ]]; then
	managementAccount_APFS
else
	resetResult="Error Finding Disk Type"
	addResult="Error Finding Disk Type"
	removalResult="Error Finding Disk Type"
fi

# FileVault Information Variables
fvStatus=$(/usr/bin/fdesetup status)
fvSearch=$(sudo /usr/bin/fdesetup list | sed 's/[,].*//g')
	for i in $fvSearch; do
		fvUsers+=("$i")
	done

# Application Information Variables
centrifyVersion=$(/usr/local/bin/adinfo -v | awk '{print $3}' | sed 's/[)]//g')
centrifyStatus=$(/usr/local/bin/adinfo -m)
scStatus=$(/usr/local/bin/sctool -s)

anyConnectVersion=$(defaults read /Applications/Cisco/Cisco\ AnyConnect\ Secure\ Mobility\ Client.app/Contents/Info.plist CFBundleVersion)
	if [[ -z "$anyConnectVersion" ]]; then
		anyConnectVersion="Unable to find version"
	fi

# Configuration Profiles Information Variables
if [[ "$osVersion" =~ "10.12" ]]; then
	listProfiles=$(sudo /usr/bin/profiles -Pv | grep "attribute: name:" | sed 's/.*:/   /')
else
	listProfiles=$(sudo /usr/bin/profiles show -type configuration | grep "attribute: name:" | sed 's/.*:/   /')
fi

if [[ "$failure" == "yes" ]]; then
	updateReady="No, ${#failedItem[@]} Issue(s) Found"
else
	updateReady="Yes"
fi

echo '
------------------------------------------------------------------------
SpaceForce Jamf Pro Health Check Log
Capture Date: '"$currDate"'
Logged In User: '"$currUser"' ('"$currUserUID"')
------------------------------------------------------------------------
System Information:
------------------------------------------------------------------------
	Computer Name: '"$computerName"'
	Serial Number: '"$serialNumber"'
	macOS Version: '"$osVersion"' ('"$osName"')
	Hard Drive: '"$driveType"'
	Disk Type: '"$diskType"'
	Ready For Update: '"$updateReady"'
------------------------------------------------------------------------
FileVault Information:
------------------------------------------------------------------------
	Status: '"$fvStatus"'
	Users: '"${fvUsers[@]}"'
------------------------------------------------------------------------
Jamf Pro Management Account Information:
------------------------------------------------------------------------
	Password Reset: '"$resetResult"'
	FileVault Enabled: '"$addResult"'
------------------------------------------------------------------------
Centrify Information:
------------------------------------------------------------------------
	Version: '"$centrifyVersion"'
	Status: '"$centrifyStatus"'
	SmartCard Assistant: '"$scStatus"'
------------------------------------------------------------------------
Cisco AnyConnect Information:
------------------------------------------------------------------------
	Version: '"$anyConnectVersion"'
------------------------------------------------------------------------
Installed Configuration Profiles:
------------------------------------------------------------------------
'"$listProfiles"'
------------------------------------------------------------------------
' > /Users/"$currUser"/Desktop/healthCheck.log

}

# If statement to check for a previous passed health check
if [[ ! -a "/Users/"$currUser"/updateCheck.passed" ]]; then
	startCheck
fi


failedChecks() {
	echo "${#failedItem[@]} Issue(s) were Found." > /tmp/failedItems.txt
	echo "The following items have failed the health check." >> /tmp/failedItems.txt
	echo " " >> /tmp/failedItems.txt
	itemCount=1
	for i in "${failedItem[@]}"; do
		echo "	$itemCount) $i" >> /tmp/failedItems.txt
		let itemCount++
	done
	
	echo " " >> /tmp/failedItems.txt
	echo "The above issues need to be resolved prior to starting the macOS update. For help resolving the above issues, please contact peoplewhohelp@company.gov and attach the health check log" >> /tmp/failedItems.txt
	
# Variables to store the current logged in user and their UID
currUser=$(ls -l /dev/console | awk '{print $3}')
currUserUID=$(id -u "$currUser")

/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<APPLESCRIPT
set failedItems to do shell script "cat /tmp/failedItems.txt"

display dialog failedItems with title "Health Check Issues" buttons {"Ok"} with icon file "Users:Shared:Images:SadMac.png"
APPLESCRIPT
}

passedChecks() {
# Variables to store the current logged in user and their UID
currUser=$(ls -l /dev/console | awk '{print $3}')
currUserUID=$(id -u "$currUser")

selectedOption=$(
/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<APPLESCRIPT
set checkPassed to display dialog "
The health check has completed running and passed all required tests. The results have been saved to your Desktop.

Would you like to start the macOS 10.13 Update?" with title "Health Check Passed" with icon file "Users:Shared:Images:HappyMac.png" buttons {"Yes, Start Update", "No, Update Later", "Download Update Only"}


if button returned of checkPassed is "Yes, Start Update" then
	set selectedOption to "Now" as text
else if button returned of checkPassed is "Download Update Only" then
	set selectedOption to "Download" as text
else
	set selectedOption to "Later" as text
end if
APPLESCRIPT
)

# Creates a file that can be used to bypass the health check if the option to download only was selected
sudo touch /Users/"$currUser"/updateCheck.passed
}

if [[ "$failure" == "yes" ]]; then
	if [[ "$resetResult" == "Pass" ]]; then
		sudo /usr/local/bin/jamf policy -trigger healthCheck_randomPass
	fi
	
	if [[ "$addResult" == "Pass" ]]; then
		sudo /usr/bin/fdesetup remove -user JAMFMANAGEMENTACCOUNT
	fi

	failedChecks
else
	passedChecks
	if [[ "$selectedOption" == "Now" ]]; then
		echo "Starting Update.."
		# Triggers the policy that will start the update process
		sudo /usr/local/bin/jamf policy -trigger update_macOS
	elif [[ "$selectedOption" == "Download" ]]; then
		echo "Starting Download.."
		if [[ "$resetResult" == "Pass" ]]; then
			sudo /usr/local/bin/jamf policy -trigger healthCheck_randomPass
		fi
		
		if [[ "$addResult" == "Pass" ]]; then
			sudo /usr/bin/fdesetup remove -user JAMFMANAGEMENTACCOUNT
		fi
		
		sudo /usr/local/bin/jamf policy -trigger download_macOS
	fi
fi
