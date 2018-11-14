#!/bin/bash

#################################################
# AD Account Migration Script
# Joshua Harvey | October 2018
# joshua.harvey[at]nasa.gov
# NASA Goddard Space Flight Center
#################################################

# Variables for use later in the script
currUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}')
currUserUID=$(id -u "$currUser")
checkBinding=$(/usr/bin/dscl localhost -list . | grep "Active Directory")

removeAD(){
	# This function force-unbinds the Mac from the existing Active Directory domain
	# and updates the search path settings to remove references to Active Directory 

	searchPath=$(/usr/bin/dscl /Search -read . CSPSearchPath | grep Active\ Directory | sed 's/^ //')

	# Force unbind from Active Directory

	/usr/sbin/dsconfigad -remove -force -u none -p none
	
	# Deletes the Active Directory domain from the custom /Search
	# and /Search/Contacts paths
	
	/usr/bin/dscl /Search/Contacts -delete . CSPSearchPath "$searchPath"
	/usr/bin/dscl /Search -delete . CSPSearchPath "$searchPath"
	
	# Changes the /Search and /Search/Contacts path type from Custom to Automatic
	
	/usr/bin/dscl /Search -change . SearchPolicy dsAttrTypeStandard:CSPSearchPath dsAttrTypeStandard:NSPSearchPath
	/usr/bin/dscl /Search/Contacts -change . SearchPolicy dsAttrTypeStandard:CSPSearchPath dsAttrTypeStandard:NSPSearchPath
}

convertAccount() {
	# Preserving the account password by backing up the password hash
	shadowHash=$(/usr/bin/dscl -plist . -read /Users/"$i" AuthenticationAuthority | xmllint --xpath 'string(//string[contains(text(),"ShadowHash")])' -)

	# Remove account attributes that identify it as an Active Directory mobile account
	/usr/bin/dscl . -delete /users/"$i" cached_groups
	/usr/bin/dscl . -delete /users/"$i" cached_auth_policy
	/usr/bin/dscl . -delete /users/"$i" CopyTimestamp
	/usr/bin/dscl . -delete /users/"$i" SMBPrimaryGroupSID
	/usr/bin/dscl . -delete /users/"$i" OriginalAuthenticationAuthority
	/usr/bin/dscl . -delete /users/"$i" OriginalNodeName
	/usr/bin/dscl . -delete /users/"$i" AuthenticationAuthority
	/usr/bin/dscl . -create /users/"$i" AuthenticationAuthority "$shadowHash"
	/usr/bin/dscl . -delete /users/"$i" SMBSID
	/usr/bin/dscl . -delete /users/"$i" SMBScriptPath
	/usr/bin/dscl . -delete /users/"$i" SMBPasswordLastSet
	/usr/bin/dscl . -delete /users/"$i" SMBGroupRID
	/usr/bin/dscl . -delete /users/"$i" PrimaryNTDomain
	/usr/bin/dscl . -delete /users/"$i" AppleMetaRecordName
	/usr/bin/dscl . -delete /users/"$i" PrimaryNTDomain
	/usr/bin/dscl . -delete /users/"$i" MCXSettings
	/usr/bin/dscl . -delete /users/"$i" MCXFlags

	sleep 10

	# Verify the account was sucessfully converted
	accountVerify=$(/usr/bin/dscl . -read /Users/"$i" AuthenticationAuthority | head -2 | awk -F'/' '{print $2}' | tr -d '\n')

	if [[ "$accountVerify" == "Active Directory" ]]; then
		echo "The account for "$i" is still a mobile account. Conversion failed."
		exit 1
	else
		echo "The account for "$i" has been successfully converted to a local account"
	fi

	# Change home directory ownership
	homeDir=$(/usr/bin/dscl . -read /Users/"$i" NFSHomeDirectory  | awk '{print $2}')

	# Add the user to the staff group locally
	/usr/sbin/dseditgroup -o edit -a "$i" -t user staff

# Create log file in the user's home directory to reflect when the account was migrated
cat > /Users/"$i"/migrationNotes.log << EOF
This account was converted from a mobile account to a local account on:
`date`

User and Group Information:
`/usr/bin/id $i`
EOF

	leaveDomain="Yes"
}

if [[ -z "$checkBinding" ]]; then
    echo "Computer is not bound to Active Directory. Exiting."
    exit 0
fi

# Account Section

userList=$(dscl /Local/Default -list /Users uid | awk '$2 >= 100 && $0 !~ /^_/ { print $1 }')

for i in $userList; do
	echo $i
	accountType=$(/usr/bin/dscl . -read /Users/"$i" AuthenticationAuthority | head -2 | awk -F'/' '{print $2}' | tr -d '\n')
	if [[ "$accountType" = "Active Directory" ]]; then
		echo "Active Directory account found for "$i". Verifying account is a Mobile Account"
		mobileCheck=$(/usr/bin/dscl . -read /Users/"$i" AuthenticationAuthority | head -2 | awk -F'/' '{print $1}' | tr -d '\n' | sed 's/^[^:]*: //' | sed s/\;/""/g)
		if [[ "$mobileCheck" == "LocalCachedUser" ]]; then
			echo ""$i" is a mobile account, starting conversion to a local account"
	        convertAccount
		else
			echo ""$i" is not a mobile account. Exiting"
		fi
	fi
done

if [[ "$leaveDomain" == "Yes" ]]; then
    removeAD
    # Performs a recon to the Jamf Pro server. Comment out if not needed
    /usr/local/bin/jamf recon
/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<APPLESCRIPT
display dialog "This computer has been unbound successfully. Any mobile account has also been converted to a local account." with title "Account Migration Complete" with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:Sync.icns" giving up after 10 buttons {"Ok"} default button 1
APPLESCRIPT
fi

exit 0
