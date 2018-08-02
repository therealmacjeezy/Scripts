# [Jamf Pro] Health Check Script
This script uses several policies in the Jamf Pro Server based off various information *(macOS Version, Hard Drive Type, etc..)*. Before using this script, make sure you have created the policies and assigned the custom triggers that will be used in this script. Once the check is completed it will output a log file onto the User's Desktop which will contain each of the checks performed and the results of that check.


### Policies Required

These policies will need to be created (along with any additional ones you may need) before this script is able to run successfully

**healthCheck\_changePass** 

		- Changes the password for the Management Account (macOS 10.12 and Non-APFS Only)

**healthCheck\_addFV** 
	
		- Enables the Management Account for FileVault (macOS 10.12 and Non-APFS Only)

**healthCheck\_randomPass** 
	
		- Changes the password for the Management Account back to random (macOS 10.12 and Non-APFS Only)



**Contact Info**
- josh[at]macjeezy.com
- JAMFnation - therealmacjeezy
