#!/bin/bash

#################################################
# Elevate User Account [No Smartcard Version]
# Joshua Harvey | May 2022
# josh[at]macjeezy.com
# GitHub - github.com/therealmacjeezy    
# JAMFnation - therealmacjeezy
#################################################

# Verify the TRMJ Scripts directory exists, change the location to a location you want to use
if [[ ! -d /Library/Scripts/TRMJ ]]; then
	echo "Creating TRMJ Scripts folder"
	/bin/mkdir -p /Library/Scripts/TRMJ
fi

# Check to see if the user account has been set in Script Parameter 4. If not it will pull the current user
if [[ ! -z "$4" ]];then
	echo "User Account has been found in policy."
	userAccount="$4"
else
	userAccount=$(scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}  ')
fi

START_ACCOUNT_ELEVATION() {
## Add the group account to the admin and wheel groups
/usr/sbin/dseditgroup -o edit -a $userAccount -t user admin
/usr/sbin/dseditgroup -o edit -a $userAccount -t user wheel

## Create the LaunchDaemon to remove the elevated priviliges after 30 minutes
## Testing at 120 seconds.. change to 1600 after finished with testing
## Remove the StandardErrorPath and StandardOutPath when testing is finished to avoid additonal logs going on the system
echo "Creating Launchd item"
/bin/cat > "/Library/LaunchDaemons/com.therealmacjeezy.remove-elevation.plist" <<'Remove_Daemon'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.therealmacjeezy.remove-elevation</string>
	<key>ProgramArguments</key>
	<array>
		<string>sh</string>
		<string>-c</string>
		<string>/Library/Scripts/TRMJ/Remove_Elevation.sh</string>
	</array>
	<key>StandardErrorPath</key>
	<string>/Users/Shared/NewError.log</string>
	<key>StandardOutPath</key>
	<string>/Users/Shared/NewOutput.log</string>
	<key>StartInterval</key>
	<integer>120</integer>
</dict>
</plist>
Remove_Daemon

sudo /bin/chmod 0644 "/Library/LaunchDaemons/com.therealmacjeezy.remove-elevation.plist"
sudo /bin/launchctl load "/Library/LaunchDaemons/com.therealmacjeezy.remove-elevation.plist"

## Create the script to remove the elevated access
cat > /Library/Scripts/TRMJ/Remove_Elevation.sh <<REMOVE_ACCESS
#!/bin/bash

#################################################
# Remove Elevated Priviliges for Group Account
# Joshua Harvey | November 2019
# josh[at]macjeezy.com
# GitHub - github.com/therealmacjeezy    
# JAMFnation - therealmacjeezy
#################################################

# Check to see if the group account is a member of the admin group, remove if found
CHECK_ADMIN=$(/usr/sbin/dseditgroup -o checkmember -m $userAccount admin | grep yes)
if [[ -z "$CHECK_ADMIN" ]]; then
	echo "Group account is a member of the admin group. Removing now."
	/usr/sbin/dseditgroup -o edit -d $userAccount admin
else
	echo "Group account is not a member of the admin group."
fi

# Check to see if the group account is a member of the wheel group, remove if found
CHECK_WHEEL=$(/usr/sbin/dseditgroup -o checkmember -m $userAccount wheel | grep yes)
if [[ -z "$CHECK_WHEEL" ]]; then
	echo "Group account is a member of the wheel group. Removing now."
	/usr/sbin/dseditgroup -o edit -d $userAccount wheel
else
	echo "Group account is not a member of the wheel group."
fi

# Unload and remove the LaunchDaemon if found

CHECK_LOADED_LD=$(launchctl list | grep "com.therealmacjeezy.remove-elevation")

if [[ -z "$CHECK_LOADED_LD" ]]; then
	echo "LaunchDaemon is loaded. Unloading now."
	launchctl unload /Library/LaunchDaemons/com.therealmacjeezy.remove-elevation.plist
else
	echo "LaunchDaemon not loaded. Checking if on system."
fi

if [[ -a /Library/LaunchDaemons/com.therealmacjeezy.remove-elevation.plist ]]; then
	echo "LaunchDaemon found removing now."
	rm -f /Library/LaunchDaemons/com.therealmacjeezy.remove-elevation.plist
else
	echo "LaunchDaemon not present. Exiting."
fi

exit 0
REMOVE_ACCESS

chmod a+x /Library/Scripts/TRMJ/Remove_Elevation.sh
}

REMOVE_ACCOUNT_ELEVATION() {
	# Check to see if the group account is a member of the admin group, remove if found
	CHECK_ADMIN=$(/usr/sbin/dseditgroup -o checkmember -m $userAccount admin | grep yes)
	if [[ -z "$CHECK_ADMIN" ]]; then
		echo "Group account is a member of the admin group. Removing now."
		/usr/sbin/dseditgroup -o edit -d $userAccount admin
	else
		echo "Group account is not a member of the admin group."
	fi
	# Check to see if the group account is a member of the wheel group, remove if found
	CHECK_WHEEL=$(/usr/sbin/dseditgroup -o checkmember -m $userAccount wheel | grep yes)
	if [[ -z "$CHECK_WHEEL" ]]; then
		echo "Group account is a member of the wheel group. Removing now."
		/usr/sbin/dseditgroup -o edit -d $userAccount wheel
	else
		echo "Group account is not a member of the wheel group."
	fi
}

# Pull the current logged in user
currUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}  ')
currUserUID=$(id -u "$currUser")

# Ask user what they want to do (add / remove)
# Applescript prompt
SCRIPT_OPTIONS=$(
/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<APPLESCRIPT
set PROMPT_ICON to "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:HelpIcon.icns"

set APPROVING_USER to do shell script "cat /tmp/user_receipt"

set USER_NAME to short user name of (system info)

set userPrompt to display dialog "The following user is accepting responsiblity for the temporary elevation request:

Requested By: " & APPROVING_USER & "
Requested For: " & USER_NAME & "

Please select an option" with title "Elevated Account Priviliges" with icon file PROMPT_ICON buttons {"I Agree - Elevate", "Remove", "Cancel"}

if button returned of userPrompt is "I Agree - Elevate" then
	set SELECTED_OPTION to "elevate"
else if button returned of userPrompt is "Remove" then
	set SELECTED_OPTION to "remove"
end if

SELECTED_OPTION
APPLESCRIPT
)

if [[ "$SCRIPT_OPTIONS" == "elevate" ]]; then
	echo "Starting account elevation"
	echo "$UPN - Elevation Requested for $currUser - `date`" >> /Users/Shared/ElevationRequests.log
	chflags hidden "/Users/Shared/ElevationRequests.log"
	START_ACCOUNT_ELEVATION
elif [[ "$SCRIPT_OPTIONS" == "remove" ]]; then
	echo "Removing account elevation"
	REMOVE_ACCOUNT_ELEVATION
else
	echo "Cancel selected"
	exit 0
fi
