## Temporary User Account Elevation

This script will temporarily elevate a user's account. The user's account can either be set in a script parameter (#4) or pull the user account of the user that runs the policy via Self Service.

When the script runs, the user will be prompted to insert their smartcard into their card reader and then prompted to select one of the following options:
 - Elevate
 - Remove Privileges
 - Cancel

If the **Elevate** option is selected, the script will perform the following actions:
1. Create an entry in the local log file with the user's UPN (which is pulled from their smartcard, this ensures that the user being logged is actually in front of the computer) and the type of request being made
2. Uses the chflags command to hide the log file
3. Adds the user to the groups "admin" and "wheel"
4. Creates a LaunchDaemon that runs the "RemoveElevation" script after the number of seconds set (default is 120 for testing, 10 minutes for prod)
5. Creates the RemoveElevation script which is used to revert the user back to standard

If the **Remove Privileges** option is selected, the script will perform the following actions:
1. Check if the user is a member of the "admin" and "wheel" groups
2. If present in those groups, it will remove the user from them and revert them back to a standard user

If the **Cancel** option is selected, the script will exit

**Note:** 
> This script pulls information from a smartcard, to use this script without a smartcard, you will need to comment out the **Prompt_For_Smartcard** and **getUPN** functions (Lines 137-158) and remove the *$UPN* variable that is used when creating the log (Line 189, in the if statement at the end of the script)
