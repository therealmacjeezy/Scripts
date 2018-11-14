#!/bin/bash

#################################################
# Apple Software Update Search
# Policy Script
# Joshua Harvey | Jul 2017
# joshua.harvey[at]nasa.gov
#################################################

#### Parameters ####
# Parameter 4 - Update Selection (Required)
# Parameter 5 - Update Selection (Optional)
# Parameter 6 - Update Selection (Optional)
# Parameter 7 - Update Selection (Optional)
# Parameter 8 - Update Selection (Optional)
#### Item Options
# iTunes - iTunes Update
# macOS - macOS Software Update (Restart Required)
# RDP - Remote Desktop Client Update
# Security - Security Update (Restart Required)
# App Store - Mac App Store Update (Restart Required)
# Safari - Safari Update
# Java - Java Update

# System Information Variables
currDate=$(date)
computerName=$(/usr/sbin/scutil --get ComputerName)
osVersion=$(/usr/bin/sw_vers -productVersion)

	if [[ "$osVersion" =~ "10.12" ]]; then
		macOS="10.12"
	elif [[ "$osVersion" =~ "10.13" ]]; then
		macOS="10.13"
	elif [[ "$osVersion" =~ "10.14" ]]; then
		macOS="10.14"
	fi

formatInput() {
	# Arrays that contain multiple variations of each item to ensure it gets formatted correctly
	RemoteDesktop=("rdp" "RDP" "remote desktop" "remote" "Remote" "Remote Desktop")
	iTunes=("itunes" "Itunes" "iTunes")
	macOS=("macos" "MacOS" "MACOS" "osx" "OSX")
	appStore=("app" "appstore" "App Store" "App store" "Appstore")
	security=("Security" "security" "security update" "Security Update")
	safari=("safari" "Safari")
	java=("java" "Java")

	# Formats the item name
	if [[ "${iTunes[@]}" =~ "$itemUpdate" ]]; then
		itemUpdate="iTunes"
	elif [[ "${macOS[@]}" =~ "$itemUpdate" ]]; then
		itemUpdate="macOS"
	elif [[ "${RemoteDesktop[@]}" =~ "$itemUpdate" ]]; then
		itemUpdate="RemoteDesktop"
	elif [[ "${appStore[@]}" =~ "$itemUpdate" ]]; then
		itemUpdate="App Store"
	elif [[ "${security[@]}" =~ "$itemUpdate" ]]; then
		itemUpdate="Security"
	elif [[ "${safari[@]}" =~ "$itemUpdate" ]]; then
		itemUpdate="Safari"
	elif [[ "${java[@]}" =~ "$itemUpdate" ]]; then
		itemUpdate="Java"
	fi
}

# Creates an empty array
updateList=()

# Checks for input in each of the parameters and formats the string for use in the softwareupdate command
if [[ ! -z "$4" ]]; then
	itemUpdate="$4"
	formatInput
	updateList+=($itemUpdate)
else
	echo "Parameter 4 is missing and is required."
	exit 0
fi

# Parameter 5 (Optional)
if [[ ! -z "$5" ]]; then
	itemUpdate="$5"
	formatInput
	updateList+=($itemUpdate)
else
	echo "Parameter 5 is empty."
fi

# Parameter 6 (Optional)
if [[ ! -z "$6" ]]; then
	itemUpdate="$6"
	formatInput
	updateList+=($itemUpdate)
else
	echo "Parameter 6 is empty."
fi

# Parameter 7 (Optional)
if [[ ! -z "$7" ]]; then
	itemUpdate="$7"
	formatInput
	updateList+=($itemUpdate)
else
	echo "Parameter 7 is empty."
fi

# Sets the update count variable to zero then looks at the updateList array and checks to see if an update is available and if so downloads the update to /Library/Updates for each item
updateCount="0"
for i in "${updateList[@]}"; do
	echo "Searching for an update for ${updateList[$updateCount]} .."
	searchUpdate=$(/usr/sbin/softwareupdate -l | grep -w "*" | sed 's/^[[:space:]]*//' | grep -y "${updateList[$updateCount]}" | sed 's/[*]//g' | sed 's/^[[:space:]]*//')
		# Checks to see if there is an update available, if not it will return No Update Found and continue to the next item
		if [[ -z "$searchUpdate" ]]; then
			echo "No update found for ${updateList[$updateCount]} .."
		else
			echo "Update found for ${updateList[$updateCount]} .. Starting download."
			installList+=("$searchUpdate")
			/usr/sbin/softwareupdate -d "$searchUpdate"
			echo "Download of "${updateList[$updateCount]}" finished"
		fi	
	let updateCount+=1
done

# Sets the install count variable to zero then looks at the installList array and runs the softwareupdate command with the install flag for each item in the array
installCount="0"
for i in "${installList[@]}"; do
	echo "Installing the update for "${installList[$installCount]}" ..."
	/usr/sbin/softwareupdate -i "${installList[$installCount]}"
	echo "Installation of "${installList[$installCount]}" is complete."
	let installCount+=1
done

# Updates the inventory to reflect the installed updates
sudo /usr/local/bin/jamf recon

# Lists the updates that were installed
echo "The following updates have been installed:"
echo "${installList[@]}"

# Checks to see if a restart is required
if [[ "${installList[@]}" =~ Security ]]; then
	echo "A restart is required for this update"
	restartRequired="yes"
else
	restartRequired="no"
fi

# Checks the restart variable to see if a restart is required
if [[ "$restartRequired" == "yes" ]]; then
	echo "Restart is Required"
	# Checks to see which macOS version is installed and will either use the reboot policy or the built in reboot switch (macOS 10.13 Only)
	if [[ "$macOS" == "10.12" ]]; then
		echo "Running $macOS"
		# Performs an authenticated restart after installing the software updates (macOS 10.12 Only)
        # Uncomment line below when ready to make the restart live
		#sudo /usr/local/bin/jamf policy -event restart
	elif [[ "$macOS" == "10.13" ]]; then
		echo "Running $macOS"
		# Performs a non-authenticated restart after installing the software updates
        # Uncomment line below when ready to make the restart live
		/usr/sbin/softwareupdate -R
	elif [[ "$macOS" == "10.14" ]]; then
		echo "Running $macOS"
		# Performs a non-authenticated restart after installing the software updates
        # Uncomment line below when ready to make the restart live
		/usr/sbin/softwareupdate -R
	fi
else
	echo "No Restart Required"
fi
