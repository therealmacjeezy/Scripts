# `InstallRubyGems.sh`

An easy way to install Ruby Gems on macOS system via Jamf Pro.

----
## Requirements
  - [swiftDialog](https://github.com/bartreardon/swiftDialog) installed.
    - **Note:** This script will download and install swiftDialog if it's not found.

----
## Setup
 1. Add script to Jamf Pro Server
 1. Create a new policy and add the `InstallRubyGems.sh` script
 1. Enter the list of Ruby Gems to install in Script Parameter #4 as a Comma Seperated List
   - **Example:** `fastlane,cocoapods,slather,xcpretty,xcode-install,bundler,jazzy`

> Be sure to set the trigger and scope correctly. This will vary based on how you want to deploy it. 

----
## Logging
This script creates a logfile at `/private/var/log/installRubyGemsLog.log`