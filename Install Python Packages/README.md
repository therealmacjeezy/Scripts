# installPythonPackages.py

An easy way to install python3 packages on macOS systems via Jamf Pro.

----
## Requirements
 - Python3 *(Tested with 3.9.13)*
 - List of packages as a Comma Seperated List in Script Parameter #4

----
## Setup
 1. Add script to Jamf Pro Server
 1. Create a new policy and add the `installPythonPackages.py` script
 1. Enter the list of python3 packages to install in Script Parameter #4 as a Comma Seperated List
   - **Example:** `requests, virtualenv, slack_sdk, tinydb`

> Be sure to set the trigger and scope correctly. This will vary based on how you want to deploy it. 

----
## Logging
This script creates a log file at `/private/var/log/installPythonPackages.log`