# Homebrew
> Note: This README.md is still in the process of being written. (6/1/22)

## `InstallHomebrew.sh`
**Version:** 0.2
**Last Update:** 06/02/2022

An easy way to install Homebrew on macOS systems via Jamf Pro.

This script will do the following items when run:
 - Check to see if the **xcodeCLITrigger** is empty or not, *if empty the script will exit*.
 - Next, the **requirements_check** function will run and check the following items:
   - Xcode Command Line Tools is installed
    - If Xcode Command Line Tools is not installed, it will use the Policy within Jamf Pro to install it. This will reduce the install time by a ton.
   - User is a member of the **_developer** group
    - If the user is not a memeber, it will add them to the group and continue on
 - The **install_homebrew** function will run and install Homebrew in the correct location based on the system architecture.

This script will create the following log files:
 - `/private/var/log/InstallHomebrew.log`
   - This is the logfile for the InstallHomebrew Script
 - `/private/var/log/Homebrew.log`
   - This is the logfile for when the script updates Homebrew

----
## Requirements
 - Policy to install Xcode Command Line tools with a custom trigger
   - Download Xcode Command Line Tools from [developer.apple.com](https://developer.apple.com) and upload to your Jamf Pro Distribution Point.
 - [swiftDialog](https://github.com/bartreardon/swiftDialog)

----
## `InstallHomebrewPackages.sh`
**Version:** 0.2
**Last Update:** 06/02/2022

An easy way to install Homebrew Packages on macOS systems via Jamf Pro.

This script will create the following log files:
 - `/private/var/log/InstallHomebrewPackages.log`
   - This is the logfile for the InstallHomebrewPackages Script
 - `/private/var/log/Homebrew.log`
   - This is the logfile for when the script updates Homebrew

----
## Requirements
 - Policy to install Xcode Command Line tools with a custom trigger
 - [swiftDialog](https://github.com/bartreardon/swiftDialog)

----
## Setup
This script uses Jamf Pro script parameters to install Homebrew Packages. When adding this script to a policy, you will need to enter the list of Homebrew Packages to install in **script parameter #4** seperated by commas.

