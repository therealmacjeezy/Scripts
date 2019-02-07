#!/bin/bash

#################################################
# Display Local Admin Password - Self Service
# Joshua Harvey | February 2019
# josh[at]macjeezy.com
# GitHub - github.com/therealmacjeezy    
# JAMFnation - therealmacjeezy
#################################################

#### NOTES ######################################
############ Script Parameters Info #############
## 4 - API Username String (Required)
## 5 - API Password String (Required)
#################################################

# Decrypt String
DecryptString() {
	# Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
	echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
}

# Account Information
if [[ -z "$4" ]]; then 
    echo "Error: API USER MISSING"
    exit 1
else
	apiUser=$(DecryptString "$4" '<salt>' '<passphrase>')        
fi

if [[ -z "$5" ]]; then
	echo "Error: API PASS MISSING"
    exit 1        
else
	apiPass=$(DecryptString "$5" '<salt>' '<passphrase>')
fi

# Script Variables
jssURL="https://your.jamf.pro/"
currUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}  ')
currUserUID=$(id -u "$currUser")
udid=$(/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Hardware UUID:/ { print $3 }')

# ID of the EA that is storing the password from the LAPS policy
EAID=60
xml=$(curl -s -u $apiUser:$apiPass -H "Accept: application/xml" $jssURL/JSSResource/computers/udid/$udid/subset/extension_attributes | xpath "//*[id=$EAID]/value/text()" 2>&1)
lapsPass=$(echo $xml | awk '{print $7}')

# Checks the lapsPass variable to see if the EA contains the local admin password, if not displays the message stating the password is not stored in the EA then exits
if [[ -z "$lapsPass" ]]; then
	lapsPass="Unable to find password in jamf."
lapsError=$(
/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<APPLESCRIPT
set getPass to do shell script "echo $lapsPass"
set showPass to display dialog " " & getPass & " " with title "Password Not Found" buttons {"Exit"} default button 1 giving up after 5
APPLESCRIPT
)
exit 0
fi

displayPass=$(
/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<APPLESCRIPT
set getPass to do shell script "echo \"$lapsPass\""
set showPass to display dialog "Password: " & getPass & " " with title "Password" buttons {"Copy"} default button 1 giving up after 10

if button returned of showPass equals "Copy"
	set the clipboard to getPass
end if

APPLESCRIPT
)

exit 0
