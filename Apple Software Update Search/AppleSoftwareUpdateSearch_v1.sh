#!/bin/sh

##########################################
# Apple Software Update Script 				 
# Josh Harvey | June 2017				 
# josh[at]macjeezy.com 				 	 
# GitHub - github.com/therealmacjeezy    
# JAMFnation - therealmacjeezy			 
##########################################

############################### Notes ##################################
# This script will list all the avalible Apple Software updates and add
# them to arrays. Once the update search is complete, it will then 
# prompt the user to enter which update they would like to install.
#
# NOTE: This script requires SUDO privileges in order to successfully 
# install any update. Otherwise the update will only be downloaded.
#
#### Future Updates Planned ############################################
#
# 1. Option to install all available updates
#
# 2. Option to install only required updates
#
# 3. Prompt to ask the user if they want to install additonal updates if 
# more are available
# 
########### ISSUES / USAGE #############################################
# If you have any issues or questions please feel free to contact  	    
# using the information in the header of this script.                   
#																		
# Also, Please give me credit and let me know if you are going to use  
# this script. I would love to know how it works out and if you find    
# it helpful.  														    
########################################################################

# Get Software Updates and send the list to a temp file for use later in the script
getUpdates=`softwareupdate -l | grep -w "*" | sed 's/^[[:space:]]*//'`

# Function to count the updates and add them to arrays for use later in the script
countUpdates() {
	countItems=`cat /tmp/SoftwareUpdates | wc -l`
	echo "------------------------------"
	echo "----- Available Updates ------"
	echo "------------------------------"
	startCount="1"
	for i in `seq 1 "$countItems"`;
	do
		#echo "$startCount `cat /tmp/SoftwareUpdates | head -"$startCount" | tail -1`"
		updateItem=`cat /tmp/SoftwareUpdates | head -"$startCount" | tail -1 | sed 's/^[[:space:]]*//'`
		listUpdates+=("$startCount - $updateItem")
		update["$startCount"]=$updateItem
		echo "$startCount - ${update["$startCount"]}"
		let "startCount++"
	done 
}

# If statement to prompt the user to select an update to install if any are available
if [[ -z "$getUpdates" ]];
	then
		echo "No Updates Found"
		doUpdate=`exit 1`
	else
		echo "$getUpdates" | sed 's/[*]//g' > /tmp/SoftwareUpdates
		countUpdates
			echo "------------------------------"
			echo "Select an update to install..."
			echo "---- Enter \"q\" to quit  ----"
			read answer
			case "$answer" in
				1)	
					#updateItunes=`cat /tmp/SoftwareUpdates | sed 's/^[[:space:]]*//' | grep -e "iTunes"`
					doUpdate="`sudo softwareupdate --install "${update[1]}"`"
					;;
				2)
					#updateOS=`cat /tmp/SoftwareUpdates | sed 's/^[[:space:]]*//' | grep -e "macOS"`
					doUpdate="`sudo softwareupdate --install "${update[2]}"`"
					;;
				3)
					#updateOS=`cat /tmp/SoftwareUpdates | sed 's/^[[:space:]]*//' | grep -e "macOS"`
					doUpdate="`sudo softwareupdate --install "${update[3]}"`"
					;;
				4)
					#updateOS=`cat /tmp/SoftwareUpdates | sed 's/^[[:space:]]*//' | grep -e "macOS"`
					doUpdate="`sudo softwareupdate --install "${update[4]}"`"
					;;
				q)
					echo "Exiting.."
					doUpdate=`exit 1`
					;;
			esac
fi

# Runs the command
echo "$doUpdate"



