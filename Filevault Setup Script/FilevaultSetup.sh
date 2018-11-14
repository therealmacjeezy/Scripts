#!/bin/bash

#################################################
# Create and Setup FileVault User (All macOS Versions)
# Enrollment
# Joshua Harvey | June 2018
# joshua.harvey[at]nasa.gov
#################################################

########################################## NOTES ##########################################
####### Parameters (Required for macOS 10.13 and 10.14w/ APFS) #####################################
# 4 - SecureToken Account Username Hash (Do Not Touch)
# 5 - SecureToken Account Password Hash (Do Not Touch)
####### Supported macOS Versions ##########################################################
# macOS 10.12, macOS 10.13, macOS 10.14
####### Supported Disk Types ##############################################################
# HFS+ (Journaled), APFS
####### Script Overview ###################################################################
# This script will be used during the Jamf Pro enrollment process to create and setup the
# User's FileVault account. Based on the macOS verions running and the disk type, other
# tasks may be run during this script.
###### All macOS Versions #################################################################
# 1) The user will be prompted to enter the email for the user being assigned the computer.
# This gets stored as a variable which is used later to create the account.
###### macOS 10.12 & macOS 10.13 (Fusion Drive's Only / HFS+) ############################# 
# 1) A plist gets created and stored locally on the computer which will be used to add the 
# user to FileVault during the Post-Enrollment process
###### macOS 10.13 APFS Only ##############################################################
# 1) The user will get prompted to enter the password they created for the user created 
# while setting up the mac
# 2) The password then gets validiated and if it passes, creates the SecureToken account and
# issues SecureToken's to the Managment Account and the SecureToken account. Once this is 
# completed, the SecureToken account is then used to remove the SecureToken from the setup 
# account.
# 3) The prompt for the user's email address will now appear.
# 4) The sysadminctl binary is used to create the user's FileVault account and once it is 
# created, it then is issued a SecureToken
############################################################################################

# This script was built around the computer being bound to Active Directory and using Centrify. You will have to modify it to meet your company needs.

# Get the version of macOS installed
osVersion=$(/usr/bin/sw_vers -productVersion)

# Set variable to be used in the script based off the macOS version
if [[ "$osVersion" =~ "10.12" ]]; then
	echo "Running macOS Sierra 10.12"
	macOS="10.12"
elif [[ "$osVersion" =~ "10.13" ]]; then
	echo "Running macOS High Sierra 10.13"
	macOS="10.13"
elif [[ "$osVersion" =~ "10.14" ]]; then
	echo "Running macOS Mojave 10.14"
	macOS="10.14"
fi

# If running macOS 10.13 or 10.14, checks if the volume is using APFS or HFS+
diskCheck=$(/usr/sbin/diskutil list | grep "Fusion Drive")

# Set variable based off the disk type to be used later on in the script
if [[ -z "$diskCheck" ]]; then
	echo "No Fusion Drive Found."
	if [[ "$macOS" == "10.12" ]]; then
		echo "Solid State Found with macOS 10.12 Installed."
		diskType="hfs"
	else
		diskType="apfs"
	fi
else
	echo "Fusion Drive Found, Using HFS+"
	diskType="hfs"
fi

# Captures the current logged in username and their UID
currUser=$(ls -l /dev/console | awk '{print $3}')
currUserUID=$(id -u "$currUser")

# Script Parameters Check
# Decrypt String
DecryptString() {
	# Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
	echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
}

# SecureToken Account Variables
if [[ -z "$4" ]]; then
	echo "Missing String"
	errorMessage="Parameter 4 is missing"
	exit 1
else
	stUser=$(DecryptString "$4" '<SALT>' '<PASSPHRASE>')
	echo "Username String Found"
fi

if [[ -z "$5" ]]; then
	echo "Missing String"
	errorMessage="Parameter 5 is missing"
	exit 1
else
	stPass=$(DecryptString "$5" '<SALT>' '<PASSPHRASE>')
	echo "Password String Found"
fi


# SecureToken Account Creation (macOS 10.13 APFS Only)
createToken() {
stPhoto="/Library/User Pictures/Nature/Earth.png"
stName="SecureToken Account"

# Gets the current user's password to be used later in the script to issue the management and secureToken account secureTokens
capturePass() {
currUser=$(ls -l /dev/console | awk '{print $3}')
currUserUID=$(id -u "$currUser")

userPass=$(
/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<'APPLESCRIPT'
-- Sets the message icon
set messageIcon to "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:LockedIcon.icns"

-- Runs a shell script to pull the current logged in user and sets it to a variable
set currUser to do shell script "ls -l /dev/console | awk '{print $3}'"

-- Prompts the user to enter the password for the account created during the setup assistant
set capturePass to display dialog "Enter the password for the user listed below

" & currUser & " " with title "Enter Password for " & currUser & "" default answer "" buttons {"Continue"} default button 1 with icon file messageIcon

-- Sets the input to a variable for use later
set newPass to (text returned of capturePass)

-- Runs a shell script to output the password entered to a file to display the input entered if the password is incorrect
do shell script "echo " & newPass & "> /tmp/setupAccount"

newPass
APPLESCRIPT
)
}

invalidPass() {
currUser=$(ls -l /dev/console | awk '{print $3}')
currUserUID=$(id -u "$currUser")

/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<'APPLESCRIPT'
-- Sets the message icon
set messageIcon to "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertStopIcon.icns"

-- Runs a shell script to pull the current logged in user and sets it to a variable
set currUser to do shell script "ls -l /dev/console | awk '{print $3}'"

-- Runs a shell script to read the incorrect password entered and set it to a varaible
set incorrectPass to do shell script "cat /tmp/setupAccount"

-- Informs the user that the password entered is incorrect
display dialog "The password you entered for " & currUser & " is incorrect. 

Password entered: " & incorrectPass & "

Please try again" with title "Incorrect Password" with icon file messageIcon buttons {"Try Again"}
APPLESCRIPT
}

capturePass

# Validates the password to make sure it was entered correctly and is valid
dscl /Local/Default authonly "$currUser" "$userPass"

# Checks the success code of the above dscl command and will prompt the user to re-enter the password if it fails validation
until [[ $? -eq 0 ]]; do
	invalidPass
	capturePass
	dscl /Local/Default authonly "$currUser" "$userPass"
done

# Creates SecureToken Account
sudo /usr/sbin/sysadminctl -adminUser "$currUser" -adminPassword "$userPass" -addUser "$stUser" -fullName "$stName" -shell "/usr/bin/false" -password "$stPass" -home "/var/$stUser/"  -admin -picture "$stPhoto" 

# Issues the SecureToken account a SecureToken from the credentials captured above
/usr/sbin/sysadminctl -adminUser "$currUser" -adminPassword "$userPass" -secureTokenOn "$stUser" -password "$stPass"

# Issues the Management Account (JAMFMANAGEMENTACCOUNT) a SecureToken using the SecureToken Account to enable FileVault
/usr/sbin/sysadminctl -adminUser "$stUser" -adminPassword "$stPass" -secureTokenOn JAMFMANAGEMENTACCOUNT -password JAMFMANAGEMENTPASS

# Disables the SecureToken for the setup account (user 501)
/usr/sbin/sysadminctl -adminUser "$stUser" -adminPassword "$stPass" -secureTokenOff "$currUser" -password "$userPass"

## Function Note
# FileVault is not enabled at this point so we do not have to remove the user account from FileVault. With the disable of the setup user's SecureToken before turning on FileVault, it should not get added to the FileVault user list once it is enabled at the end of this script.
}

# User Information Section (All OS Versions)
getEmail() {
currUser=$(ls -l /dev/console | awk '{print $3}')
currUserUID=$(id -u "$currUser")

userEmail=$(
/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<'APPLESCRIPT'
set emailCheck to true
set userCheck to missing value
set errorNumber to 0
set correctUser to no

-- Sets the message icons
set messageIcon to "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:Accounts.icns"
set confirmIcon to "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:GenericQuestionMarkIcon.icns"

repeat while (correctUser = no)
	--repeat statement to run the validation
	repeat while (emailCheck = true)
		
		if errorNumber is equal to 3 then
			display dialog "The maximum number of attempts have been reached. Please try enrolling again using the correct user information." buttons {"Ok"} default button "Ok" with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertCautionIcon.icns" giving up after 5
			do shell script "echo \"errorFound\" > /tmp/error"
			error number -128
		end if
		
		set emailPrompt to display dialog "Please enter the Work email address for the user you are deploying the computer to. 
	
This will be used create the user's FileVault Account." with title "Enter Work Email" buttons {"Continue"} default answer "" default button {"Continue"} with icon file messageIcon
		set getUserEmail to (text returned of emailPrompt)
		
		--if statement to check email address entered
		try
			if text returned of emailPrompt ends with "@email.gov" then
				set userCheck to do shell script "/usr/local/bin/adquery user " & getUserEmail & " -M"
			end if
		end try
		
		if userCheck is equal to missing value then
			display dialog "Please enter a valid va.gov email address 
(eg: johnny.appleseed@email.gov)" buttons {"Re-Enter Email Address"} default button "Re-Enter Email Address" with title "Invalid / Missing Email Address" with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertCautionIcon.icns"
			set errorNumber to errorNumber + 1
		else
			set userInfo to userCheck
            -- uses the centrify binary to get user info
			set realName to do shell script "/usr/local/bin/adquery user " & userInfo & " -A | grep 'displayName' | cut -f2- -d:"
			set emailCheck to false
			set validUser to true
		end if
	end repeat
	
	repeat while (validUser = true)
		set confirmUser to display dialog "This computer will be assigned and used by:

 - Username: 
 " & userInfo & " 
 - Full Name: 
 " & realName & "
 
Is this correct?" with title "Confirm User" buttons {"Yes", "No"} with icon file confirmIcon
		
		if button returned of confirmUser is "Yes" then
			--display dialog "ok" giving up after 2
			set validUser to yes
			set correctUser to yes
			do shell script "rm -rf /tmp/error"
			do shell script "echo " & userInfo & " > /Users/Shared/adname"
			do shell script "echo " & quoted form of realName & " > /Users/Shared/fulluser"
			getUserEmail
		end if
		
		if button returned of confirmUser is "No" then
			display dialog "enter again" giving up after 2
			set validUser to true
			set errorNumber to errorNumber + 1
			errorNumber
		end if
		
		if errorNumber is equal to 3 then
			display dialog "The maximum number of attempts have been reached. Please try enrolling again using the correct user information." buttons {"Ok"} default button "Ok" with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertCautionIcon.icns" giving up after 10
			do shell script "echo \"errorFound\" > /tmp/error"
			error number -128
		end if
	end repeat
end repeat
userCheck
APPLESCRIPT
)

# Takes the output from the getEmail function and switches it to all lowercase instead of camelcase
userEmail=$(echo "$userEmail" | awk '{print tolower($0)}')
}

# Create User's FileVault Account Section
userCreation_nonAPFS() {
# Variable for user's full name
sudo /System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount -n "$userEmail"

# Random number variable
randUID=$(awk -v min=503 -v max=520 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')

# Function to create user account for FileVault 2
sudo dscl . -create /Users/"FV-$userEmail"
sudo dscl . -create /Users/"FV-$userEmail" UserShell /usr/bin/false
sudo dscl . -create /Users/"FV-$userEmail" RealName "$userEmail (FileVault)"
sudo dscl . -create /Users/"FV-$userEmail" UniqueID $randUID
sudo dscl . -create /Users/"FV-$userEmail" PrimaryGroupID 20
sudo dscl . -create /Users/"FV-$userEmail" NFSHomeDirectory /var/"FV-$userEmail"
sudo dscl . -passwd /Users/"FV-$userEmail" "$userEmail"
#sudo mkdir -p /var/"FV-$userEmail"
sudo dscl . -create /Users/JAMFMANAGEMENTACCOUNT RealName "Admin Unlock"
#sudo dscl . -delete /Users/JAMFMANAGEMENTACCOUNT Picture
sudo dscl . -create /Users/JAMFMANAGEMENTACCOUNT Picture "/Path/To/Image.png"
sudo dscl . -create /Users/"FV-$userEmail" Picture "/Path/To/Image.png"


# Creates the plist and fixes the permissions to it
sudo touch /tmp/fvsetup.plist
sudo chmod ugo+rwx /tmp/fvsetup.plist

cat > /tmp/fvsetup.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Username</key>
<string>JAMFMANAGEMENTACCOUNT</string>
<key>Password</key>
<string>JAMFMANAGEMENTPASS</string>
<key>AdditionalUsers</key>
<array>
	<dict>
		<key>Username</key>
		<string>FV-$userEmail</string>
		<key>Password</key>
		<string>$userEmail</string>
	</dict>
</array>
</dict>
</plist>
EOF
}

# Creates the user's FileVault Account (macOS 10.13 APFS Volumes Only)
userCreation_APFS() {
# Creates the user's FileVault account using the sysadminctl binary
sudo /usr/sbin/sysadminctl -adminUser "$stUser" -adminPassword "$stPass" -addUser "FV-$userEmail" -fullName "$userEmail (FileVault)" -shell "/usr/bin/false"  -home "/var/FV-$userEmail/" -picture "/Path/To/Image.png" -password "$userEmail"

# Issues a SecureToken to the user's FileVault account to allow them to unlock it at startup
sudo /usr/sbin/sysadminctl -adminUser "$stUser" -adminPassword "$stPass" -secureTokenOn "FV-$userEmail" -password "$userEmail"

# Updates the PreBoot volume so the user's FileVault account gets added to the plist which allows FileVault to be unlocked
/usr/sbin/diskutil apfs updatePreboot /
}

# Checks the version of macOS that is installed and runs the function(s) above that match

if [[ "$macOS" == "10.12" ]]; then
	echo "Running macOS 10.12"
	# Gets the user's email address
	getEmail
	# Creates the user's FileVault account using the 10.12/non apfs function
	userCreation_nonAPFS
elif [[ "$macOS" == "10.13" ]]; then
 	echo "Running macOS 10.13"
	touch /Users/Shared/postUpdate.done
	if [[ "$diskType" == "hfs" ]]; then
		echo "Disk type is HFS+/Fusion Drive"
		# Gets the user's email address
		getEmail
		# Creates the user's FileVault account using the 10.12/non apfs function
		userCreation_nonAPFS
	elif [[ "$diskType" == "apfs" ]]; then
		echo "Disk type is APFS/Non Fusion Drive, SecureToken setup required first"
		# Calls the function to perform the required setup for SecureToken
		createToken
		# Gets the user's email address
		getEmail
		# Creates the user's FileVault account using the 10.13/apfs function
		userCreation_APFS
	fi
elif [[ "$macOS" == "10.14" ]]; then
 	echo "Running macOS 10.14"
	touch /Users/Shared/postUpdate.done
	if [[ "$diskType" == "hfs" ]]; then
		echo "Disk type is HFS+/Fusion Drive"
		# Gets the user's email address
		getEmail
		# Creates the user's FileVault account using the 10.12/non apfs function
		userCreation_nonAPFS
	elif [[ "$diskType" == "apfs" ]]; then
		echo "Disk type is APFS/Non Fusion Drive, SecureToken setup required first"
		# Calls the function to perform the required setup for SecureToken
		createToken
		# Gets the user's email address
		getEmail
		# Creates the user's FileVault account using the 10.14/apfs function
		userCreation_APFS
	fi
fi
