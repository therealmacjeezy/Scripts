#!/bin/zsh

#################################################
# macOS Catalina 10.15 Upgrade Script
# Josh Harvey | September 2019
# josh@macjeezy.com
#################################################

## Script Variables
# Change to GM when released to public
OS_STATE="Beta"

if [[ "$OS_STATE" == "Beta" ]]; then
  CATALINA_PATH="/Applications/Install macOS Catalina Beta.app"
else
  CATALINA_PATH="/Applications/Install macOS Catalina.app"
fi

####### Supported macOS Versions ##########################################################
# macOS 10.12.x, macOS 10.13.x, macOS 10.14.x
####### Script Overview ###################################################################
# This script will setup a plist for an authenticated reboot, check the disk type for the 
# computer, then run the startosinstall binary based on the disk type returned. Before the
# computer restarts, it will kill self service which is required due to the startosinstall
# performing a soft restart and is not able to force quit other applications
###########################################################################################

# Pulls the current logged in user and their UID
CURR_USER=$(scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}  ')
CURR_USER_UID=$(id -u $CURR_USER)

FV_PASS=$(
# Prompts the user to input their FileVault password using Applescript. This password is used for a one time authenticated reboot. Once the installation is started, the file that was used to reboot the system is deleted.
/bin/launchctl asuser "$CURR_USER_UID" sudo -iu "$CURR_USER" /usr/bin/osascript <<APPLESCRIPT

set validatedPass to false

repeat while (validatedPass = false)
-- Prompt the user to enter their filevault password
display dialog "Enter your Filevault 2 Password to allow a one time authenticated reboot, which is used to start the macOS 10.15 upgrade" with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:FileVaultIcon.icns" default answer "" buttons {"Continue"} with text and hidden answer default button "Continue"

set fvPass to (text returned of result)

display dialog "Re-enter the Filevault 2 Password to verifed it was entered correctly" with text and hidden answer buttons {"Continue"} with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:FileVaultIcon.icns" default answer "" default button "Continue"

if text returned of result is equal to fvPass then
	set validatedPass to true
	fvPass
else
	display dialog "The passwords you have entered do not match. Please enter matching passwords." with title "FileVault Password Validation Failed" buttons {"Re-Enter Password"} default button "Re-Enter Password" with icon file messageIcon
end if
end repeat

APPLESCRIPT
)

# Sets the comptuer up for an authenticated restart using a temp account
/usr/bin/fdesetup authrestart -delayminutes 3 -verbose -inputplist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Username</key>
	<string>$CURR_USER</string>
	<key>Password</key>
	<string>"$FV_PASS"</string>
</dict>
</plist>
EOF

# Implement a self-deleting launch daemon to perform a Jamf Pro recon on first boot
createReconAfterUpgradeLaunchDaemon (){
# This launch daemon will self-delete after successfully completing a Jamf recon
# Launch Daemon Label and Path
local launch_daemon="com.therealmacjeezy.postinstall.jamfrecon"
local launch_daemon_path="/Library/LaunchDaemons/$launch_daemon".plist

# Creating launch daemon
echo "<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$launch_daemon</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/zsh</string>
		<string>-c</string>
		<string>if [[ \"\$(/usr/bin/mdfind -onlyin /System/Library/CoreServices/ '((kMDItemFSName = \"SystemVersion.plist\") &amp;&amp; InRange(kMDItemDateAdded,\$time.today,\$time.today(+1)))' -count)\" == 1 ]]; then /usr/local/bin/jamf recon &amp;&amp; /bin/rm -f /Library/LaunchDaemons/$launch_daemon.plist; /bin/launchctl bootout system/$launch_daemon; fi;</string>
	</array>
	<key>RunAtLoad</key>
		<true/>
	<key>StartInterval</key>
		<integer>60</integer>
</dict>
</plist>" > "$launch_daemon_path"
    
# Set proper permissions on launch daemon
if [[ -e "$launch_daemon_path" ]]; then
    /usr/sbin/chown root:wheel "$launch_daemon_path"
    /bin/chmod 644 "$launch_daemon_path"
fi
}

# Create launch daemon to update inventory post-OS upgrade
createReconAfterUpgradeLaunchDaemon

# Starts the install of macOS Catalina
"$CATALINA_PATH/Contents/Resources/startosinstall" --rebootdelay 0 --nointeraction --agreetolicense

# Kills self service to allow the installer to continue with the update
/bin/launchctl asuser "$CURR_USER_UID" sudo -iu "$CURR_USER" killall "Self Service"

# Exits the script
exit 0
