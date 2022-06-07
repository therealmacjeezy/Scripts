# Homebrew

> This repository also contains Extension Attributes that can be used to help scope and return the Homebrew and Xcode Command Line Tools versions. Those can be found within the **Extension Attributes** folder.

## `InstallHomebrew.sh`

An easy way to install Homebrew on macOS systems via Jamf Pro.

----
## Requirements
  - Xcode Command Line Tools Package uploaded to Jamf Pro
    - *Requires a free Developer Account for [developer.apple.com](https://developer.apple.com)*
  - A policy in Jamf Pro to install XcodeCLI with a custom trigger
  - [swiftDialog](https://github.com/bartreardon/swiftDialog) installed.
    - **Note:** This script will download and install swiftDialog if it's not found.

----
## Setup
 1. Add script to Jamf Pro Server
 1. Create a new policy and add the `InstallHomebrew.sh` script
 1. Enter the custom trigger for the Install Xcode Command Line Tools Policy in Script Parameter #4

> Be sure to set the trigger and scope correctly. This will vary based on how you want to deploy it. 

----
## Logging
This script creates the following log files:
 - `/private/var/log/InstallHomebrew.log`
   - This is the logfile for the `InstallHomebrew` script.
 - `/private/var/log/Homebrew.log`
   - This is the logfile for when the script updates Homebrew.
 - `/Users/Shared/xcodecliversion`
   - This is the logfile that contains the Xcode Command Line Tools version

----

## `InstallHomebrewPackages.sh`

An easy way to install Homebrew Packages on macOS systems via Jamf Pro

----
## Requirements
  - [swiftDialog](https://github.com/bartreardon/swiftDialog) installed.
    - **Note:** This script will download and install swiftDialog if it's not found.

----
## Setup
 1. Add script to Jamf Pro Server
 1. Create a new policy and add the `InstallHomebrewPackages.sh` script
 1. Enter the list of Homebrew Packages to install in Script Parameter #4 as a Comma Seperated List
   - **Example:** `jq,wget,git,python,mint,carthage`

> Be sure to set the trigger and scope correctly. This will vary based on how you want to deploy it. 

----
## Logging
This script creates the following log files:
 - `/private/var/log/InstallHomebrewPackages.log`
   - This is the logfile for the `InstallHomebrewPackages` script.
 - `/private/var/log/Homebrew.log`
   - This is the logfile for when the script updates Homebrew.