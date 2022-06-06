# Ruby Gems
> Note: This README.md is still in the process of being written. (6/6/22)

## `InstallRubyGems.sh`
**Version:** 0.1
**Last Updated:** 06/06/2022

An easy way to install Ruby Gems on macOS systems via Jamf Pro.

This script will create the following log files:
 - `/private/var/log/InstallHomebrewPackages.log`
   - This is the logfile for the InstallHomebrewPackages Script
 - `/private/var/log/Homebrew.log`
   - This is the logfile for when the script updates Homebrew

----
## Requirements
 - [swiftDialog](https://github.com/bartreardon/swiftDialog)

----
## Setup
This script uses Jamf Pro script parameters to install Ruby Gems. When adding this script to a policy, you will need to enter the list of Ruby Gems to install in **script parameter #4** seperated by commas.