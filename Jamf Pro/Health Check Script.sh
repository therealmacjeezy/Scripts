#!/bin/bash

#################################################
# Mac Health Check
# Script / Policy
# Josh Harvey | July 2018
# Updated: N/A
# josh[at]macjeezy.com
# github: github.com/therealmacjeezy
# Jamf Nation: therealmacjeezy
#################################################

########################################## NOTES ##########################################
####### Parameters (Required) #############################################################
# N/A
####### Jamf Pro Policies Used (Triggers) #################################################
# This policies will need to be created (along with any additional ones you may need) before
# this script is able to run successfully
# healthCheck_changePass - Changes the password for the Management Account (macOS 10.12 and Non-APFS Only)
# healthCheck_addFV - Enables the Management Account for FileVault (macOS 10.12 and Non-APFS Only)
# healthCheck_randomPass - Changes the password for the Management Account back to random (macOS 10.12 and Non-APFS Only)
####### Supported macOS Versions ##########################################################
# macOS 10.12.X, macOS 10.13.X
####### Supported Disk Types ##############################################################
# HFS+ (Journaled), APFS
####### Script Overview ###################################################################
# This script will perform a health check on the Mac it is ran on. Once the check is completed
# it will output a log file onto the User's Desktop which will contain each of the checks
# performed and the results of that check.
####### Additional Info  ##################################################################
# This script uses several policies in the Jamf Pro Server based off various information 
# (macOS Version, Hard Drive Type, etc..). Before using this script, make sure you have 
# created the policies and assigned the custom triggers that will be used in this script.
###########################################################################################

# System Information Variables
currDate=$(date)
computerName=$(/usr/sbin/scutil --get ComputerName)
serialNumber=$(system_profiler SPHardwareDataType | grep 'Serial Number (system)' | awk '{print $NF}')
osVersion=$(/usr/bin/sw_vers -productVersion)
jamfVersion=$(/usr/local/bin/jamf -version | cut -b9-)

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

# User Information Variables
currUser=$(ls -l /dev/console | awk '{print $3}')
currUserUID=$(id -u "$currUser")

managementAccount_nonAPFS() {
# Management Account Information Variables
	sudo /usr/local/bin/jamf policy -trigger healthCheck_changePass
	# Change the <management_user> <temp_pass> fields with the username and temp password for the Management Account. This verifies the password change was made successfully using the dscl command and the authonly option
	#/usr/bin/dscl /Local/Default authonly <management_user> <temp_pass>
	if [[ $? -eq 0 ]]; then
		resetResult="Pass"
		# Changes the Management Account password back to a randomized one via a policy
		sudo /usr/local/bin/jamf policy -trigger healthCheck_randomPass
	else
		resetResult="Fail - Unable to Change Password"
		failure="yes"
		failedItem+=("Cannot Change Password for Management Account")
	fi
	
	if [[ "$resetResult" == "Pass" ]]; then
		sudo /usr/local/bin/jamf policy -trigger healthCheck_addFV
		# Change the <management_user> to the name of the Management Account you use. This uses the fdesetup binary to pull the list of FileVault users and the grep command to only look for the Management Account
		#sudo /usr/bin/fdesetup list | grep "<management_user>"
		if [[ $? -eq 0 ]]; then
			addResult="Pass"
			removeUser="Yes"
		else
			addResult="Fail - Unable to add esecasp to FileVault"
			failure="yes"
			failedItem+=("Cannot Enable Management Account for FileVault")
		fi
	fi

	if [[ "$removeUser" == "Yes" ]]; then
		# Change the <management_user> to the name of the Management Account you use. This uses the fdesetup binary to remove the management account from FileVault
		#sudo /usr/bin/fdesetup remove -user <management_user>
			# Change the <management_user> to the name of the Management Account you use. This uses the fdesetup binary to pull the list of FileVault users and the grep command to only look for the Management Account
			#sudo /usr/bin/fdesetup list | grep "<management_user>"
			if [[ $? -eq 0 ]]; then
				removalResult="Pass"
			else
				removalResult="Fail - Unable to remove esecasp from FileVault"
				failure="yes"
				failedItem+=("Cannot Remove Management Account from FileVault")
			fi
	else
		removalResult="N/A - Account not added"
	fi
}	

managementAccount_APFS() {
# Management Account Information Variables
resetResult="N/A - AFPS Volume Found"
addResult="N/A - AFPS Volume Found"
removalResult="N/A - AFPS Volume Found"
}

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
	if [[ "$fvStatus" =~ "On" ]]; then
		fvStatus="On"
	elif [[ "$fvStatus" =~ "Off" ]]; then
		fvStatus="Off (Not Encrypted)"
	fi
fvSearch=$(sudo /usr/bin/fdesetup list | sed 's/[,].*//g')
	for i in $fvSearch; do
		fvUsers+=("$i")
	done

# Application Information Variables
if [[ -d /Applications/Utilities/Centrify/AD\ Check.app ]]; then
	centrifyVersion=$(/usr/local/bin/adinfo -v | awk '{print $3}' | sed 's/[)]//g')
		if [[ -z "$centrifyVersion" ]]; then
			centrifyVersion="Missing / Unable to Pull Version"
		fi
		
		if [[ "$osVersion" =~ "10.13" && "$centrifyVersion" == "5.4.2-668" ]]; then
			centrifyVersion="Update to v5.5.0 Needed (using 5.4.2)"
		fi
	centrifyStatus=$(/usr/local/bin/adinfo -m)
	scStatus=$(/usr/local/bin/sctool -s)
else
	centrifyVersion="Not Installed"
	centrifyStatus="N/A"
	scStatus="N/A"
fi

# Smart Card Pairing Variables

sc_pairingStatus=$(/usr/sbin/sc_auth pairing_ui -s status)

if [[ "$sc_pairingStatus" =~ "disabled" ]]; then
	scPairing="Smart Card Pairing is Disabled"
	pairedCard="N/A"
else
	scPairing="Smart Card Pairing is Enabled"
	checkPair="Yes"
fi

if [[ "$checkPair" == "Yes" ]]; then
	sc_pairingCheck=$(/usr/sbin/sc_auth list -u "$currUser")
		if [[ -z "$sc_pairingCheck" ]]; then
			pairedCard="No Cards Paired with $currUser"
		else
			pairedCard="$sc_pairingCheck"
		fi
fi

# Cisco AnyConnect Variables

if [[ -d /Applications/Cisco ]]; then
	anyConnectVersion=$(defaults read /Applications/Cisco/Cisco\ AnyConnect\ Secure\ Mobility\ Client.app/Contents/Info.plist CFBundleVersion)
		if [[ -z "$anyConnectVersion" ]]; then
			anyConnectVersion="Unable to find version"
		fi
else
	anyConnectVersion="Not Installed"
fi



# Configuration Profiles Information Variables
if [[ "$osVersion" =~ "10.12" ]]; then
	listProfiles=$(sudo /usr/bin/profiles -Pv | grep "attribute: name:" | sed 's/.*:/   /')
else
	listProfiles=$(sudo /usr/bin/profiles show -type configuration | grep "attribute: name:" | sed 's/.*:/   /')
fi


if [[ "$failure" == "yes" ]]; then
	issuesFound="${#failedItem[@]} Issue(s) Found"
else
	issuesFound="None"
fi

echo '
------------------------------------------------------------------------
macOS Health Check Log
Capture Date: '"$currDate"'
Logged In User: '"$currUser"' ('"$currUserUID"')
------------------------------------------------------------------------
Issues Found: '"$issuesFound"'
------------------------------------------------------------------------
System Information:
------------------------------------------------------------------------
	Computer Name: '"$computerName"'
	Serial Number: '"$serialNumber"'
	macOS Version: '"$osVersion"' ('"$osName"')
	Jamf Binary Version: '"$jamfVersion"'
	Hard Drive: '"$driveType"'
	Disk Type: '"$diskType"'
------------------------------------------------------------------------
FileVault Information:
------------------------------------------------------------------------
	Status: '"$fvStatus"'
	Users: '"${fvUsers[@]}"'
------------------------------------------------------------------------
Jamf Pro Management Account Information:
------------------------------------------------------------------------
	Password Reset Check: '"$resetResult"'
	Enable FileVault Check: '"$addResult"'
	FileVault Removal Check: '"$removalResult"'
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
SmartCard Information:
------------------------------------------------------------------------
	Pairing UI: '"$scPairing"'
	Paired Card(s) For '"$currUser"':
	'"$pairedCard"'
------------------------------------------------------------------------
Installed Configuration Profiles:
------------------------------------------------------------------------
'"$listProfiles"'
------------------------------------------------------------------------
' > /Users/"$currUser"/Desktop/healthCheck.log

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
	echo "The above issues have been found and should be resolved as soon as possible to avoid any future issues." >> /tmp/failedItems.txt
	
# Variables to store the current logged in user and their UID
currUser=$(ls -l /dev/console | awk '{print $3}')
currUserUID=$(id -u "$currUser")

/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<APPLESCRIPT
set failedItems to do shell script "cat /tmp/failedItems.txt"

-- You can use a custom icon with the line below if wanted
-- display dialog failedItems with title "Health Check Issues" buttons {"Ok"} with icon file "Path:To:Image.png"
display dialog failedItems with title "Health Check Issues" buttons {"Ok"} with icon 1
APPLESCRIPT
}

passedChecks() {
# Variables to store the current logged in user and their UID
currUser=$(ls -l /dev/console | awk '{print $3}')
currUserUID=$(id -u "$currUser")

selectedOption=$(
/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<APPLESCRIPT
-- You can use a custom icon with the line below if wanted

--set checkPassed to display dialog "
--The health check has completed running and passed all required tests. The results have been saved to your Desktop." with title "Health Check Passed" with icon file "Path:To:Image.png" buttons {"Ok"} default button 1

set checkPassed to display dialog "
The health check has completed running and passed all required tests. The results have been saved to your Desktop." with title "Health Check Passed" with icon 1 buttons {"Ok"} default button 1
APPLESCRIPT
)
}

if [[ "$failure" == "yes" ]]; then
	failedChecks
else
	passedChecks
fi
